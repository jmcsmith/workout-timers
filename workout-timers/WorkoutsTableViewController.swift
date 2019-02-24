//
//  WorkoutsTableViewController.swift
//  workout-timers
//
//  Created by Joseph Smith on 5/18/18.
//  Copyright © 2018 Robotic Snail Software. All rights reserved.
//

import UIKit

class WorkoutsTableViewController: UITableViewController {
    var defaults = UserDefaults(suiteName: "group.workouttimers")
    var workouts: [Workout] = []
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = defaults?.data(forKey: "workoutData"),
            let workout = try? Workouts.init(data: data) {
            workouts = workout
        }
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        tableView.addGestureRecognizer(longPressGesture)

        //WorkoutContext.sharedInstance.sendChangedOnPhoneNotification()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.workouts.remove(at: indexPath.row)
            self.saveWorkoutsData()
            tableView.deleteRows(at: [indexPath], with: .fade)
            WorkoutContext.sharedInstance.sendChangedOnPhoneNotification()
        }
    }
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
    }
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let renameAction = UIContextualAction(style: .normal, title: "Edit") {
            (contextaction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in

            // get your window screen size
            let screenRect = UIScreen.main.bounds
            //create a new view with the same size
            let coverView = UIView(frame: screenRect)
            // change the background color to black and the opacity to 0.6
            coverView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            // add this new view to your main view
            let navigationController = self.navigationController?.view
            navigationController?.addSubview(coverView)
            //self.view.addSubview(coverView)
            print("edit")
            if let referenceViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddWorkout")
                as? AddWorkoutViewController {
                referenceViewController.isEdit = true
                referenceViewController.workoutIndex = indexPath.row
                referenceViewController.coverView = coverView
                referenceViewController.workoutTableViewController = self
                referenceViewController.transitioningDelegate = self
                referenceViewController.modalPresentationStyle = .custom
                self.present(referenceViewController, animated: true, completion: nil)
            }
            completionHandler(true)
        }
        renameAction.backgroundColor = UIColor.gray
        return UISwipeActionsConfiguration(actions: [renameAction])
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "workoutcell", for: indexPath) as! WorkoutTableViewCell
        // swiftlint:enable force_cast
        cell.title?.text = workouts[indexPath.row].name
        cell.subtitle?.text = "\(workouts[indexPath.row].timers.count) timers"
        cell.timeLabel?.text = "\(String(format: "%.1f", workouts[indexPath.row].timers.reduce(0) { $0 + $1.time} / 60.0))m"
        // Configure the cell...
        cell.view.layer.cornerRadius = 10
        cell.view.clipsToBounds = true
        var backgroundColor = UIColor.lightGray
        switch workouts[indexPath.row].color {
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
        cell.view.backgroundColor = backgroundColor
        return cell
    }
    @IBAction func add(_ sender: Any) {
        // get your window screen size
        let screenRect = UIScreen.main.bounds
        //create a new view with the same size
        let coverView = UIView(frame: screenRect)
        // change the background color to black and the opacity to 0.6
        coverView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        // add this new view to your main view
        let navigationController = self.navigationController?.view
        navigationController?.addSubview(coverView)
        //self.view.addSubview(coverView)
        print("add")
        if let referenceViewController = storyboard?.instantiateViewController(withIdentifier: "AddWorkout")
            as? AddWorkoutViewController {
            referenceViewController.coverView = coverView
            referenceViewController.workoutTableViewController = self
            referenceViewController.transitioningDelegate = self
            referenceViewController.modalPresentationStyle = .custom
            self.present(referenceViewController, animated: true, completion: nil)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "timersSegue"{
            let destination = segue.destination as? TimersTableViewController
            if let index = tableView.indexPathForSelectedRow?.row {
                destination?.title = workouts[index].name
                destination?.workout = workouts[index]
                destination?.workoutController = self
            }
        } else if segue.identifier == "newWorkoutSegue" {
            let destination = segue.destination as? AddWorkoutViewController
            destination?.workoutTableViewController = self
        } else if segue.identifier == "test" {
            let destination = segue.destination as? AddWorkoutViewController
            destination?.workoutTableViewController = self
            destination?.modalPresentationStyle = .custom
            destination?.transitioningDelegate = self
        }
        // Pass the selected object to the new view controller.
    }
    func saveWorkoutsData() {
        try? self.defaults?.set(self.workouts.jsonData(), forKey: "workoutData")
    }
    func snapshopOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        let cellSnapshot: UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        let longPress = gesture as UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.location(in: self.tableView)
        var indexPath = self.tableView.indexPathForRow(at: locationInView)
        switch state {
        case .began:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            if indexPath != nil {
                Path.initialIndexPath = indexPath as IndexPath?
                if let cell = self.tableView.cellForRow(at: indexPath!) as? WorkoutTableViewCell {
                    My.cellSnapshot = snapshopOfCell(inputView: cell)
                    var center = cell.center
                    My.cellSnapshot!.center = center
                    My.cellSnapshot!.alpha = 0.0
                    self.tableView.addSubview(My.cellSnapshot!)
                    UIView.animate(withDuration: 0.25,
                                   animations: { () -> Void in
                                    center.y = locationInView.y
                                    My.cellSnapshot!.center = center
                                    My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                                    My.cellSnapshot!.alpha = 0.98
                                    cell.alpha = 0.0
                    }, completion: { (finished) -> Void in
                        if finished {
                            cell.isHidden = true
                        }
                    })
                }
            }
        case .changed:
            var center = My.cellSnapshot!.center
            center.y = locationInView.y
            My.cellSnapshot!.center = center
            if (indexPath != nil) && (indexPath != Path.initialIndexPath) {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                self.workouts.swapAt((indexPath?.row)!, (Path.initialIndexPath?.row)!)
                saveWorkoutsData()
                self.tableView.moveRow(at: Path.initialIndexPath!, to: indexPath!)
                Path.initialIndexPath = indexPath
            }
        default:
            if let cell = self.tableView.cellForRow(at: Path.initialIndexPath!) as? WorkoutTableViewCell {
                cell.isHidden = false
                cell.alpha = 0.0
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    My.cellSnapshot!.center = (cell.center)
                    My.cellSnapshot!.transform = CGAffineTransform.identity
                    My.cellSnapshot!.alpha = 0.0
                    cell.alpha = 1.0
                }, completion: { (finished) -> Void in
                    if finished {
                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                        generator.impactOccurred()
                        Path.initialIndexPath = nil
                        My.cellSnapshot!.removeFromSuperview()
                        My.cellSnapshot = nil
                    }
                })
            }
        }
    }
}
extension WorkoutsTableViewController: UIViewControllerTransitioningDelegate {
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController)
        -> UIPresentationController? {
            return AddWorkoutPresentationController(
                presentedViewController: presented, presenting: presenting)
    }
}
