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
        if let data = defaults?.data(forKey: "workoutData"), let wo = try? Workouts.init(data: data) {
            workouts = wo
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.workouts.remove(at: indexPath.row)
            self.saveWorkoutsData()
            tableView.deleteRows(at: [indexPath], with: .fade)
            WorkoutContext.sharedInstance.sendChangedOnPhoneNotification()
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "workoutcell", for: indexPath) as! WorkoutTableViewCell 
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
        let referenceViewController = storyboard?.instantiateViewController(withIdentifier: "AddWorkout") as! AddWorkoutViewController
        referenceViewController.coverView = coverView
        referenceViewController.workoutTableViewController = self
        referenceViewController.transitioningDelegate = self
        referenceViewController.modalPresentationStyle = .custom
        
        self.present(referenceViewController, animated: true, completion: nil)

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
    
//    @IBAction func addWorkout(_ sender: UIBarButtonItem) {
//        let alert = UIAlertController(title: "New Workout", message: nil, preferredStyle: .alert)
//        alert.isModalInPopover = true
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//
//        alert.addTextField(configurationHandler: { textField in
//            textField.placeholder = "Workout Name"
//        })
//        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { action in
//
//            if let name = alert.textFields?.first?.text {
//
//                //self.workouts.append(Workout(timers: [], name: name))
//                //self.tableView.reloadData()
//                //self.saveWorkoutsData()
//                //(UIApplication.shared.delegate as? AppDelegate)?.sendTimersToWatch()
//            }
//        }))
//
//        self.present(alert, animated: true)
//
//
//    }
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
