//
//  AddTimerViewController.swift
//  workout-timers
//
//  Created by Joseph Smith on 7/30/18.
//  Copyright © 2018 Robotic Snail Software. All rights reserved.
//

import UIKit

class AddTimerViewController: UIViewController, UITextFieldDelegate {

    var timerTableViewController: TimersTableViewController?
    @IBOutlet weak var timerName: UITextField!
    @IBOutlet weak var timerDuration: UITextField!
    @IBOutlet weak var timerColor: UISegmentedControl!

    var coverView: UIView?
    var keyboardDisplayed = false
    var oldKeyboardHeight: CGFloat = 0.0

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
        timerName.becomeFirstResponder()
        updateSegmentedControlColor(for: timerColor.selectedSegmentIndex)

        timerName.delegate = self
        timerDuration.delegate = self
        // Do any additional setup after loading the view.
    }
    @objc func adjustViewSize(_ notification: Notification) {
        self.view.sizeToFit()
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            var newFrame = self.view.frame

                newFrame.origin.y += oldKeyboardHeight
                newFrame.origin.y -= keyboardHeight
                keyboardDisplayed = true
                oldKeyboardHeight = keyboardHeight

            DispatchQueue.main.async {
                self.view.frame = newFrame
                self.view.setNeedsLayout()
                self.view.layoutSubviews()
            }
        }
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.add(self)
        return true
    }
    @IBAction func cancel(_ sender: Any) {
        timerName.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
        coverView?.removeFromSuperview()
    }
    @IBAction func add(_ sender: Any) {
        //create timer
        let timer = Timer(name: timerName.text!,
                          time: Double.init( timerDuration.text!) ?? 0.0,
                          color: timerColor.titleForSegment(at: timerColor.selectedSegmentIndex)!)
        //save data
        timerTableViewController?.workout?.timers.append(timer)
        timerTableViewController?.workoutController.saveWorkoutsData()
        timerTableViewController?.workoutController.tableView.reloadData()
        timerTableViewController?.tableView.reloadData()
        //save
        timerTableViewController?.tableView.reloadData()
        timerName.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
        coverView?.removeFromSuperview()
    }
    @IBAction func colorValueChanged(_ sender: UISegmentedControl) {

        updateSegmentedControlColor(for: sender.selectedSegmentIndex)

    }
    func updateSegmentedControlColor(for selectedIndex: Int) {
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
