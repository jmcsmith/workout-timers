//
//  AddWorkoutViewController.swift
//  workout-timers
//
//  Created by Joseph Smith on 6/21/18.
//  Copyright © 2018 Robotic Snail Software. All rights reserved.
//

import UIKit

class AddWorkoutViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var workoutName: UITextField!
    @IBOutlet weak var workoutColor: UISegmentedControl!
    @IBOutlet weak var workoutType: UISegmentedControl!
    
    var workoutTableViewController: WorkoutsTableViewController? = nil
    var coverView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(adjustViewSize), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        workoutName.becomeFirstResponder()
        updateSegmentedControlColor(for: workoutColor.selectedSegmentIndex)
        workoutName.delegate = self
        // Do any additional setup after loading the view.
    }
    @objc func hideKeyboard(_ notification: Notification){
        self.view.sizeToFit()
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            var newFrame = self.view.frame
            newFrame.origin.y = 162
            // add 100 to y's current value
            DispatchQueue.main.async {
                self.view.frame = newFrame
                self.view.setNeedsLayout()
                self.view.layoutSubviews()
            }
        }
    }
    @objc func adjustViewSize(_ notification: Notification){
        self.view.sizeToFit()
        print(self.view.frame.size)
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            print("height: \(keyboardHeight)")
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
        //create workout
        let workout = Workout(timers: [], name: workoutName.text!, type: workoutType.titleForSegment(at: workoutType.selectedSegmentIndex)!, color: workoutColor.titleForSegment(at: workoutColor.selectedSegmentIndex)!)
        //save data
        workoutTableViewController?.workouts.append(workout)
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
    
    func updateSegmentedControlColor(for selectedIndex: Int){
        switch selectedIndex {
        case 0:
            workoutColor.tintColor = UIColor.WorkoutGreen
        case 1:
            workoutColor.tintColor = UIColor.WorkoutPink
        case 2:
            workoutColor.tintColor = UIColor.WorkoutBlue
        case 3:
            workoutColor.tintColor = UIColor.WorkoutYellow
        case 4:
            workoutColor.tintColor = UIColor.WorkoutOrange
        default:
            workoutColor.tintColor = UIColor.gray
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
