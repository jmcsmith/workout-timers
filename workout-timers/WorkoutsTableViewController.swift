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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = defaults?.data(forKey: "workoutData"),
            let workout = try? Workouts.init(data: data) {
            workouts = workout
        }


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

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let renameAction = UIContextualAction(style: .normal, title: "Edit") { (contextaction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in

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
