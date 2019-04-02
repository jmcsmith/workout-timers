//
//  SettingsTableViewController.swift
//  workout-timers
//
//  Created by Joseph Smith on 6/5/18.
//  Copyright © 2018 Robotic Snail Software. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var speakTimerNamesSwitch: UISwitch!
     let defaults: UserDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        let speak = defaults.bool(forKey: "speakTimers")
        speakTimerNamesSwitch.isOn = speak
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func speakTimerNamesChanged(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: "speakTimers")
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            return
        case 1:
            switch indexPath.row {
            case 0:
                if let url = URL(string: "https://www.workouttimers.app/privacy"){
                    UIApplication.shared.open(url, options:[:], completionHandler: nil)
                }
            case 1:
                if let url = URL(string: "https://www.workouttimers.app"){
                    UIApplication.shared.open(url, options:[:], completionHandler: nil)
                }
            case 2:
                if let url = URL(string: "https://www.roboticsnailsoftware.com"){
                    UIApplication.shared.open(url, options:[:], completionHandler: nil)
                }
  
            default:
                return
            }
        default:
            return
        }
    }
}
