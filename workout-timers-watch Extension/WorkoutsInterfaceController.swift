//
//  WorkoutsInterfaceController.swift
//  workout-timers-watch Extension
//
//  Created by Joseph Smith on 6/7/18.
//  Copyright © 2018 Robotic Snail Software. All rights reserved.
//

import WatchKit
import Foundation


class WorkoutsInterfaceController: WKInterfaceController {
    
    @IBOutlet var workoutsTable: WKInterfaceTable!
    let defaults = UserDefaults(suiteName: "group.workouttimers")
    //var workouts: Workouts = [Workout(timers: [], name: "Test"), Workout(timers: [Timer(name: "Plank", time: 4.0, color: "Green")], name: "Planks")]
    var workouts: Workouts = []
    override func awake(withContext context: Any?) {
        //var workouts = WorkoutContext.sharedInstance.workouts
        
        if let json = defaults?.string(forKey: "workoutData"), let wo = try? Workouts.init(json) {
            workouts = wo
        }
        
        super.awake(withContext: context)
        
        let rows = workoutsTable.numberOfRows
        let itemRows = NSIndexSet(indexesIn: NSRange(location: 0, length: workouts.count))
        workoutsTable.insertRows(at: itemRows as IndexSet, withRowType: "WorkoutRowType")
        
        //workoutsTable.setNumberOfRows(workouts.count, withRowType: "WorkoutRowType")
        print(workoutsTable.numberOfRows)
        //        for (index, workout) in workouts.enumerated() {
        //            let controller = workoutsTable.rowController(at: index) as! WorkoutRowController
        //            controller.workoutName.setText(workout.name)
        //            controller.workoutSubTitle.setText("\(workout.timers.count) timers")
        //
        //        }
        for i in rows..<workoutsTable.numberOfRows {
            // 1
            let c = workoutsTable.rowController(at: i)
            
            // 2
            if let controller = c as? WorkoutRowController {
                controller.workoutName.setText(workouts[i].name)
                controller.workoutSubTitle.setText("\(workouts[i].timers.count) timers")
                // 3
            }
        }
    }
    
}
