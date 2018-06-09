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
    
    var workouts: Workouts = [Workout(timers: [], name: "Test")]

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    
        workoutsTable.setNumberOfRows(workouts.count, withRowType: "WorkoutRowType")
        for (index, workout) in workouts.enumerated() {
            let controller = workoutsTable.rowController(at: index) as! WorkoutRowController
            controller.workoutName.setText(workout.name)
            controller.workoutSubTitle.setText("\(workout.timers.count) timers")
          
        }
    }
    
}
