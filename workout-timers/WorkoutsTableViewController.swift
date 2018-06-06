//
//  WorkoutsTableViewController.swift
//  workout-timers
//
//  Created by Joseph Smith on 5/18/18.
//  Copyright © 2018 Robotic Snail Software. All rights reserved.
//

import UIKit

class WorkoutsTableViewController: UITableViewController {
    let defaults:UserDefaults = UserDefaults.standard
    
    var workouts: [Workout] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = defaults.data(forKey: "workoutData"), let wo = try? Workouts.init(data: data) {
            workouts = wo
        }
        
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
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "workoutcell", for: indexPath) as! WorkoutTableViewCell 
        cell.title?.text = workouts[indexPath.row].name
        cell.subtitle?.text = "\(workouts[indexPath.row].timers.count) timers"
        // Configure the cell...
        cell.view.layer.cornerRadius = 10
        cell.view.clipsToBounds = true
        cell.view.backgroundColor = UIColor.lightGray
        return cell
        
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
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        let destination = segue.destination as? TimersTableViewController
        if let index = tableView.indexPathForSelectedRow?.row {
            destination?.title = workouts[index].name
            destination?.workout = workouts[index]
            destination?.workoutController = self
        }
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func addWorkout(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Workout", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Workout Name"
        })
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { action in
            
            if let name = alert.textFields?.first?.text {
                
                self.workouts.append(Workout(timers: [], name: name))
                self.tableView.reloadData()
                self.saveWorkoutsData()
            }
        }))
        
        self.present(alert, animated: true)
        
        
    }
    func saveWorkoutsData() {
        try? self.defaults.set(self.workouts.jsonData(), forKey: "workoutData")
    }
}
