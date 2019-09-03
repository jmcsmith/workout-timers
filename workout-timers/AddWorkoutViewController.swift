//
//  AddWorkoutViewController.swift
//  workout-timers
//
//  Created by Joseph Smith on 6/21/18.
//  Copyright © 2018 Robotic Snail Software. All rights reserved.
//

import UIKit

class AddWorkoutViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var workoutName: UITextField!
    @IBOutlet weak var workoutColor: UISegmentedControl!
    @IBOutlet weak var workoutType: UISegmentedControl!
    
    var workoutTableViewController: WorkoutsTableViewController?
    var coverView: UIView?
    @IBOutlet weak var windowTitle: UILabel!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var isEdit = false
    var workoutIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(adjustViewSize),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(hideKeyboard),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        workoutName.becomeFirstResponder()
        if isEdit {
            let workout = workoutTableViewController?.workouts[workoutIndex]
            workoutName.text = workout?.name
            //workoutColor.selectedSegmentIndex = workoutColor.segments
            if let color = workout?.color {
                workoutColor.selectedSegmentIndex = workoutColor.indexFor(title: color)
            }
            if let type = workout?.type {
                workoutType.selectedSegmentIndex = workoutType.indexFor(title: type)
            }
            windowTitle.text = "Edit Workout"
            addButton.title = "Save"
        }
        updateSegmentedControlColor(for: workoutColor.selectedSegmentIndex)
        workoutName.delegate = self
        
        // Do any additional setup after loading the view.
    }
    @objc func hideKeyboard(_ notification: Notification) {
        self.view.sizeToFit()
        
        var newFrame = self.view.frame
        newFrame.origin.y = 162
        // add 100 to y's current value
        DispatchQueue.main.async {
            self.view.frame = newFrame
            self.view.setNeedsLayout()
            self.view.layoutSubviews()
        }
        
    }
    @objc func adjustViewSize(_ notification: Notification) {
        self.view.sizeToFit()
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            var newFrame = self.view.frame
            newFrame.origin.y -= keyboardHeight
            // add 100 to y's current value
            DispatchQueue.main.async {
                self.view.frame = newFrame
                self.view.setNeedsLayout()
                self.view.layoutSubviews()
            }
        }
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        workoutName.resignFirstResponder()
        coverView?.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func add(_ sender: Any) {
        if !isEdit {
            //create workout
            let workout = Workout(timers: [],
                                  name: workoutName.text!,
                                  type: workoutType.titleForSegment(at: workoutType.selectedSegmentIndex)!,
                                  color: workoutColor.titleForSegment(at: workoutColor.selectedSegmentIndex)!)
            //save data
            workoutTableViewController?.workouts.append(workout)
        } else {
            let workout = workoutTableViewController?.workouts[workoutIndex]
            workout?.name = workoutName.text!
            workout?.type = workoutType.titleForSegment(at: workoutType.selectedSegmentIndex)!
            workout?.color = workoutColor.titleForSegment(at: workoutColor.selectedSegmentIndex)!
        }
        workoutTableViewController?.saveWorkoutsData()
        workoutTableViewController?.tableView.reloadData()
        workoutName.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
        coverView?.removeFromSuperview()
    }
    @IBAction func colorValueChanged(_ sender: UISegmentedControl) {
        
        updateSegmentedControlColor(for: sender.selectedSegmentIndex)
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.add(self)
        return true
    }
    
    func updateSegmentedControlColor(for selectedIndex: Int) {
        switch selectedIndex {
        case 0:
            if #available(iOS 13.0, *) {
                workoutColor.selectedSegmentTintColor = UIColor.WorkoutGreen
            } else {
                workoutColor.tintColor = UIColor.WorkoutGreen
            }
        case 1:
            if #available(iOS 13.0, *) {
                workoutColor.selectedSegmentTintColor = UIColor.WorkoutPink
            } else {
                workoutColor.tintColor = UIColor.WorkoutPink
            }
            
        case 2:
            if #available(iOS 13.0, *) {
                workoutColor.selectedSegmentTintColor = UIColor.WorkoutBlue
            } else {
                workoutColor.tintColor = UIColor.WorkoutBlue
            }
            
        case 3:
            if #available(iOS 13.0, *) {
                workoutColor.selectedSegmentTintColor = UIColor.WorkoutYellow
            } else {
                workoutColor.tintColor = UIColor.WorkoutYellow
            }
        case 4:
            if #available(iOS 13.0, *) {
                workoutColor.selectedSegmentTintColor = UIColor.WorkoutOrange
            } else {
                workoutColor.tintColor = UIColor.WorkoutOrange
            }
        default:
            if #available(iOS 13.0, *) {
                workoutColor.selectedSegmentTintColor = UIColor.gray
            } else {
                workoutColor.tintColor = UIColor.gray
            }
        }
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
