//
//  AddWorkoutViewController.swift
//  workout-timers
//
//  Created by Joseph Smith on 6/21/18.
//  Copyright © 2018 Robotic Snail Software. All rights reserved.
//

import UIKit

class AddWorkoutViewController: UIViewController {

    @IBOutlet weak var workoutName: UITextField!
    @IBOutlet weak var workoutColor: UISegmentedControl!
    @IBOutlet weak var workoutType: UISegmentedControl!
    
    var workoutTableViewController: WorkoutsTableViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
workoutName.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    @IBAction func cancel(_ sender: Any) {
              workoutName.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func add(_ sender: Any) {
        //create workout
        let workout = Workout(timers: [], name: workoutName.text!, type: workoutType.titleForSegment(at: workoutType.selectedSegmentIndex)!, color: workoutColor.titleForSegment(at: workoutColor.selectedSegmentIndex)!)
        //save data
        workoutTableViewController?.workouts.append(workout)
        workoutTableViewController?.saveWorkoutsData()
        workoutTableViewController?.tableView.reloadData()
        //send notification to reload table view
        workoutName.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
