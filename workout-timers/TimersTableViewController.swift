//
//  TimersTableViewController.swift
//  workout-timers
//
//  Created by Joseph Smith on 5/18/18.
//  Copyright © 2018 Robotic Snail Software. All rights reserved.
//

import UIKit
import AVFoundation

class TimersTableViewController: UITableViewController, AVSpeechSynthesizerDelegate {
    let defaults: UserDefaults = UserDefaults.standard
    @IBOutlet weak var playPauseButton: UIBarButtonItem!
    @IBOutlet weak var randomButton: UIBarButtonItem!
    var workout: Workout?
    var workoutController: WorkoutsTableViewController = WorkoutsTableViewController()
    var isWorkoutPlaying = false
    var workoutIsPaused = false
    var currentTimer = CurrentTimer()
    var timer: UIKit.Timer!
    var randoms: [Int] = []
    let audioSession = AVAudioSession.sharedInstance()
    let speechSynthesizer = AVSpeechSynthesizer()
    @IBOutlet weak var toolbar: UIToolbar!
    var playButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.play, target: self, action: #selector(play))
    var pauseButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.pause, target: self, action: #selector(pause))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speechSynthesizer.delegate = self
        if isWorkoutPlaying {
            toolbar.items?.insert(pauseButton, at: 2)
        } else {
            toolbar.items?.insert(playButton, at: 2)
        }
        if workout?.timers.count == 0 {
            toolbar.items?[2].isEnabled = false
            randomButton.isEnabled = false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (workout?.timers.count)!
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "timerCell", for: indexPath) as! TimerTableViewCell
        // swiftlint:enable force_cast
        cell.timerName.text = workout?.timers[indexPath.row].name
        cell.timerTime.text = "\(workout?.timers[indexPath.row].time.description ?? "0.0")s"
        cell.progressView.layer.cornerRadius = 10
        cell.progressView.clipsToBounds = true
        var backgroundColor = UIColor.lightGray
        switch workout?.timers[indexPath.row].color {
        case "Orange":
            backgroundColor = UIColor.WorkoutOrange
        case "Blue":
            backgroundColor = UIColor.WorkoutBlue
        case "Pink":
            backgroundColor = UIColor.WorkoutPink
        case "Yellow":
            backgroundColor = UIColor.WorkoutYellow
        case "Green":
            backgroundColor = UIColor.WorkoutGreen
        default:
            backgroundColor = UIColor.lightGray
        }
        cell.progressView.trackTintColor = backgroundColor
        cell.progressView.progressTintColor = UIColor.lightGray
        return cell
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.workout?.timers.remove(at: indexPath.row)
            self.workoutController.saveWorkoutsData()
            self.workoutController.tableView.reloadData()
            tableView.deleteRows(at: [indexPath], with: .fade)
            WorkoutContext.sharedInstance.sendChangedOnPhoneNotification()
            if workout?.timers.count == 0 {
                toolbar.items?[2].isEnabled = false
                randomButton.isEnabled = false
            }
        }
    }
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let renameAction = UIContextualAction(style: .normal, title: "Rename") { (contextaction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            
            let screenRect = UIScreen.main.bounds
            //create a new view with the same size
            let coverView = UIView(frame: screenRect)
            // change the background color to black and the opacity to 0.6
            coverView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            // add this new view to your main view
            let navigationController = self.navigationController?.view
            navigationController?.addSubview(coverView)
            if let referenceViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddTimer") as? AddTimerViewController {
                referenceViewController.coverView = coverView
                referenceViewController.timerTableViewController = self
                referenceViewController.isEdit = true
                referenceViewController.timerIndex = indexPath.row
                referenceViewController.transitioningDelegate = self
                referenceViewController.modalPresentationStyle = .custom
                self.present(referenceViewController, animated: true, completion: {
                    self.randomButton.isEnabled = true
                    self.toolbar.items?[2].isEnabled = true
                })
                
            }
            completionHandler(true)
        }
        renameAction.backgroundColor = UIColor.gray
        return UISwipeActionsConfiguration(actions: [renameAction])
    }
    
    @IBAction func shareWorkout(_ sender: UIBarButtonItem) {
        do {
            let filename = "\(workout?.name.description ?? "workout").wt"
            let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
            let content = try workout?.jsonString()
            try content?.write(to: path, atomically: true, encoding: String.Encoding.utf8)
            let activityViewController = UIActivityViewController(activityItems: [path], applicationActivities: [])
            self.present(activityViewController, animated: true) {
            }
        } catch {
            //print(error)
        }
    }
    @IBAction func random(_ sender: Any) {
        randoms = []
        DispatchQueue.main.async {
            self.resetTimers()
            self.playPauseButton.isEnabled = false
            self.randomButton.isEnabled = false
        }
        setTimerToRandom()
    }
    func setTimerToRandom() {
        if let size = (workout?.timers.count) {
            var index = Int(arc4random_uniform(UInt32(size)))
            while randoms.contains(index) {
                index = Int(arc4random_uniform(UInt32(size)))
            }
            randoms.append(index)
            if let time = workout?.timers[index].time {
                if defaults.bool(forKey: "speakTimers") == true {
                    speakWorkout(forIndex: index)
                }
                let notification = UIImpactFeedbackGenerator(style: .heavy)
                notification.impactOccurred()
                currentTimer.startTime = time
                currentTimer.currentTime = time
                currentTimer.timerIndex = index
            }
            timer = UIKit.Timer.scheduledTimer(timeInterval: 1,
                                               target: self,
                                               selector: (#selector(updateTimerRandom)),
                                               userInfo: nil,
                                               repeats: true)
        }
    }
    @IBAction func addTimer(_ sender: UIBarButtonItem) {
        let screenRect = UIScreen.main.bounds
        //create a new view with the same size
        let coverView = UIView(frame: screenRect)
        // change the background color to black and the opacity to 0.6
        coverView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        // add this new view to your main view
        let navigationController = self.navigationController?.view
        navigationController?.addSubview(coverView)
        if let referenceViewController = storyboard?.instantiateViewController(withIdentifier: "AddTimer") as? AddTimerViewController {
            referenceViewController.coverView = coverView
            referenceViewController.timerTableViewController = self
            referenceViewController.transitioningDelegate = self
            referenceViewController.modalPresentationStyle = .custom
            self.present(referenceViewController, animated: true, completion: {
                self.randomButton.isEnabled = true
                self.toolbar.items?[2].isEnabled = true
            })
        }
    }
    @IBAction func playPause(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            self.resetTimers()
            //self.playPauseButton.isEnabled = false
            self.toolbar.items?.remove(at: 2)
            self.toolbar.items?.insert(self.pauseButton, at: 2)
            self.randomButton.isEnabled = false
        }
        setTimerToIndex(index: 0)
    }
    @objc func play() {
        if workoutIsPaused {
            resumeCurrentTimer()
            workoutIsPaused = false
            DispatchQueue.main.async {
                self.toolbar.items?.remove(at: 2)
                self.toolbar.items?.insert(self.pauseButton, at: 2)
                self.randomButton.isEnabled = false
            }
        } else {
            DispatchQueue.main.async {
                self.resetTimers()
                self.toolbar.items?.remove(at: 2)
                self.toolbar.items?.insert(self.pauseButton, at: 2)
                self.randomButton.isEnabled = false
            }
            setTimerToIndex(index: 0)
        }
    }
    @objc func pause() {
        workoutIsPaused = true
        timer.invalidate()
        DispatchQueue.main.async {
            self.toolbar.items?.remove(at: 2)
            self.toolbar.items?.insert(self.playButton, at: 2)
            self.workoutIsPaused = true
        }
    }
    func resetTimers() {
        if let count = workout?.timers.count {
            for iterator in 0...count {
                let indexPath = IndexPath(row: iterator, section: 0)
                let cell = tableView.cellForRow(at: indexPath) as? TimerTableViewCell
                cell?.progressView.setProgress(0, animated: false)
            }
        }
    }
    @objc func updateTimer() {
        if currentTimer.currentTime > 0 {
            currentTimer.currentTime -= 1
            let cell = tableView.cellForRow(at: IndexPath(row: currentTimer.timerIndex, section: 0)) as? TimerTableViewCell
            cell?.timerTime?.text = currentTimer.currentTime.description
            cell?.progressView.setProgress(Float((currentTimer.startTime - currentTimer.currentTime) / currentTimer.startTime), animated: true)
            print(currentTimer.currentTime)
        } else {
            timer.invalidate()
            print("end timer")
            if currentTimer.timerIndex < (workout?.timers.count)! - 1 {
                setTimerToIndex(index: (currentTimer.timerIndex + 1))
            } else {
                DispatchQueue.main.async {
                    self.toolbar.items?.remove(at: 2)
                    self.toolbar.items?.insert(self.playButton, at: 2)
                    self.randomButton.isEnabled = true
                }
            }
        }
    }
    @objc func updateTimerRandom() {
        if currentTimer.currentTime > 0 {
            currentTimer.currentTime -= 1
            let cell = tableView.cellForRow(at: IndexPath(row: currentTimer.timerIndex, section: 0)) as? TimerTableViewCell
            cell?.timerTime?.text = currentTimer.currentTime.description
            cell?.progressView.setProgress(Float((currentTimer.startTime - currentTimer.currentTime) / currentTimer.startTime), animated: true)
        } else {
            timer.invalidate()
            if randoms.count < (workout?.timers.count)! {
                setTimerToRandom()
            } else {
                DispatchQueue.main.async {
                    self.toolbar.items?.remove(at: 2)
                    self.toolbar.items?.insert(self.playButton, at: 2)
                    self.randomButton.isEnabled = true
                }
            }
        }
    }
    func setTimerToIndex(index: Int) {
        if let time = workout?.timers[index].time {
            if defaults.bool(forKey: "speakTimers") == true {
                speakWorkout(forIndex: index)
            }
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.success)
            currentTimer.startTime = time
            currentTimer.currentTime = time
            currentTimer.timerIndex = index
        }
        timer = UIKit.Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    func resumeCurrentTimer() {
        timer = UIKit.Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    func speakWorkout(forIndex: Int) {
        let speechUtterance = AVSpeechUtterance(string: (workout?.timers[forIndex].name)!)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.duckOthers)
            try audioSession.setActive(true)
            speechSynthesizer.speak(speechUtterance)
        } catch {
            print("Uh oh!")
        }
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        do {
            try audioSession.setActive(false)
        } catch {
            print("Uh oh!")
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        timer?.invalidate()
        DispatchQueue.main.async {
            self.toolbar.items?.remove(at: 2)
            self.toolbar.items?.insert(self.pauseButton, at: 2)
            self.randomButton.isEnabled = false
        }
        setTimerToIndex(index: indexPath.row)
    }
}
extension TimersTableViewController: UIViewControllerTransitioningDelegate {
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController)
        -> UIPresentationController? {
            return AddTimerPresentationController(
                presentedViewController: presented, presenting: presenting)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}
