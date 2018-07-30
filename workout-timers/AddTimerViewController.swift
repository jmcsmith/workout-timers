//
//  AddTimerViewController.swift
//  workout-timers
//
//  Created by Joseph Smith on 7/30/18.
//  Copyright © 2018 Robotic Snail Software. All rights reserved.
//

import UIKit

class AddTimerViewController: UIViewController {
    
    var timerTableViewController: TimersTableViewController? = nil
    @IBOutlet weak var timerName: UITextField!
    @IBOutlet weak var timerDuration: UITextField!
    @IBOutlet weak var timerColor: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timerName.becomeFirstResponder()
        updateSegmentedControlColor(for: timerColor.selectedSegmentIndex)
        
        // Do any additional setup after loading the view.
    }
    @IBAction func cancel(_ sender: Any) {
        timerName.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func add(_ sender: Any) {
        //create timer
        let timer = Timer(name: timerName.text!, time: Double.init( timerDuration.text!) ?? 0.0, color: timerColor.titleForSegment(at: timerColor.selectedSegmentIndex)!)
        //save data
        timerTableViewController?.workout?.timers.append(timer)
        timerTableViewController?.workoutController.saveWorkoutsData()
        timerTableViewController?.workoutController.tableView.reloadData()
        timerTableViewController?.tableView.reloadData()
        //save
        timerTableViewController?.tableView.reloadData()
        timerName.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func colorValueChanged(_ sender: UISegmentedControl) {
        
        updateSegmentedControlColor(for: sender.selectedSegmentIndex)
        
        
    }
    func updateSegmentedControlColor(for selectedIndex: Int){
        switch selectedIndex {
        case 0:
            timerColor.tintColor = UIColor.WorkoutGreen
        case 1:
            timerColor.tintColor = UIColor.WorkoutPink
        case 2:
            timerColor.tintColor = UIColor.WorkoutBlue
        case 3:
            timerColor.tintColor = UIColor.WorkoutYellow
        case 4:
            timerColor.tintColor = UIColor.WorkoutOrange
        default:
            timerColor.tintColor = UIColor.gray
        }
    }
    
}
