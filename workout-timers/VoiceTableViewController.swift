//
//  VoiceTableViewController.swift
//  workout-timers
//
//  Created by Joseph Smith on 9/5/18.
//  Copyright © 2018 Robotic Snail Software. All rights reserved.
//

import UIKit
import AVFoundation

class VoiceTableViewController: UITableViewController {
 let voices = AVSpeechSynthesisVoice.speechVoices()
    override func viewDidLoad() {
        super.viewDidLoad()

        print(voices)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return voices.count
    }

     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "voice", for: indexPath)
     cell.textLabel?.text = voices[indexPath.row].name
     // Configure the cell...

     return cell
     }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
