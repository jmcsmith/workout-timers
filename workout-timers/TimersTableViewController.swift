//
//  TimersTableViewController.swift
//  workout-timers
//
//  Created by Joseph Smith on 5/18/18.
//  Copyright © 2018 Robotic Snail Software. All rights reserved.
//

import UIKit
import AVFoundation

class TimersTableViewController: UITableViewController {
    
    let defaults:UserDefaults = UserDefaults.standard
    @IBOutlet weak var playPauseButton: UIBarButtonItem!
    @IBOutlet weak var randomButton: UIBarButtonItem!
    var workout: Workout?
    var workoutController: WorkoutsTableViewController = WorkoutsTableViewController()
    var isWorkoutPlaying = false
    var currentTimer = CurrentTimer()
    var timer: UIKit.Timer!
    
    var randoms : [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (workout?.timers.count)!
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timerCell", for: indexPath) as! TimerTableViewCell
        cell.timerName.text = workout?.timers[indexPath.row].name
        cell.timerTime.text = workout?.timers[indexPath.row].time.description
        cell.progressView.layer.cornerRadius = 10
        cell.progressView.clipsToBounds = true
        cell.bringSubview(toFront: cell.timerName)
        // Configure the cell...
        
        return cell
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.workout?.timers.remove(at: indexPath.row)
            self.workoutController.saveWorkoutsData()
            self.workoutController.tableView.reloadData()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    @IBAction func shareWorkout(_ sender: UIBarButtonItem) {
        do {
            let filename = "\(workout?.name.description ?? "workout").wt"
            let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
            let content = try workout?.jsonString()
            try content?.write(to: path, atomically: true, encoding: String.Encoding.utf8)
            let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
            self.present(vc, animated: true){
                
            }
        } catch {
            //print(error)
        }
    }
    
    @IBAction func random(_ sender: Any) {
        randoms = []
        DispatchQueue.main.async {
            self.playPauseButton.isEnabled = false
            self.randomButton.isEnabled = false
        }
        setTimerToRandom()
    }
    func setTimerToRandom() {
        if let size = (workout?.timers.count){
            var index = Int(arc4random_uniform(UInt32(size)))
            while randoms.contains(index){
                index = Int(arc4random_uniform(UInt32(size)))
            }
            print("Random index: \(index)")
            randoms.append(index)
            if let time = workout?.timers[index].time {
                if defaults.bool(forKey: "speakTimers") == true {
                    speakWorkout(forIndex: index)
                }
                
                currentTimer.startTime = time
                currentTimer.currentTime = time
                currentTimer.timerIndex = index
                
            }
            
            timer = UIKit.Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimerRandom)), userInfo: nil, repeats: true)
        }
    }
    @IBAction func addTimer(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add Timer to \(self.title ?? "Workout")", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Timer Name"
            textField.keyboardType = UIKeyboardType.alphabet
            textField.autocapitalizationType = UITextAutocapitalizationType.words
        })
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Timer Duration"
            textField.keyboardType = UIKeyboardType.numberPad
            
        })
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { action in
            
            if let name = alert.textFields?.first?.text, let duration = alert.textFields?[1].text {
                let d = Double.init(duration)
                self.workout?.timers.append(Timer(name: name, time: d!, color: "Blue"))
                
                self.workoutController.saveWorkoutsData()
                self.workoutController.tableView.reloadData()
                
                self.tableView.reloadData()
                
            }
        }))
        
        self.present(alert, animated: true)
        
    }
    @IBAction func playPause(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            self.playPauseButton.isEnabled = false
            self.randomButton.isEnabled = false
        }
        setTimerToIndex(index: 0)
    }
    @objc func updateTimer(){
        if currentTimer.currentTime > 0 {
            currentTimer.currentTime -= 1
            let cell = tableView.cellForRow(at: IndexPath(row: currentTimer.timerIndex, section: 0)) as? TimerTableViewCell
            cell?.timerTime?.text = currentTimer.currentTime.description
            cell?.progressView.setProgress(Float((currentTimer.startTime - currentTimer.currentTime) / currentTimer.startTime), animated: true)
            //cell?.backgroundColor = UIColor.green
            print(currentTimer.currentTime)
        } else {
            timer.invalidate()
            print("end timer")
            if currentTimer.timerIndex < (workout?.timers.count)! - 1 {
                setTimerToIndex(index: (currentTimer.timerIndex + 1))
            } else {
                DispatchQueue.main.async {
                    self.playPauseButton.isEnabled = true
                    self.randomButton.isEnabled = true
                }
            }
        }
    }
    @objc func updateTimerRandom(){
        if currentTimer.currentTime > 0 {
            currentTimer.currentTime -= 1
            let cell = tableView.cellForRow(at: IndexPath(row: currentTimer.timerIndex, section: 0)) as? TimerTableViewCell
            cell?.timerTime?.text = currentTimer.currentTime.description
            cell?.progressView.setProgress(Float((currentTimer.startTime - currentTimer.currentTime) / currentTimer.startTime), animated: true)
            //cell?.backgroundColor = UIColor.green
            //print(currentTimer.currentTime)
        } else {
            timer.invalidate()
            print("end timer")
            if randoms.count < (workout?.timers.count)! {
                setTimerToRandom()
            } else {
                DispatchQueue.main.async {
                    self.playPauseButton.isEnabled = true
                    self.randomButton.isEnabled = true
                }
            }
        }
    }
    func setTimerToIndex(index: Int){
        if let time = workout?.timers[index].time {
            if defaults.bool(forKey: "speakTimers") == true {
                speakWorkout(forIndex: index)
            }
            
            currentTimer.startTime = time
            currentTimer.currentTime = time
            currentTimer.timerIndex = index
            
        }
        
        timer = UIKit.Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    func speakWorkout(forIndex: Int)  {
        
        let speechSynthesizer = AVSpeechSynthesizer()
        let speechUtterance = AVSpeechUtterance(string: (workout?.timers[forIndex].name)!)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        speechSynthesizer.speak(speechUtterance)
    }
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.playPauseButton.isEnabled = false
            self.randomButton.isEnabled = false
        }
        setTimerToIndex(index: indexPath.row)
    }
}
