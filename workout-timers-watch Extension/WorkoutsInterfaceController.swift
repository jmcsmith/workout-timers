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
    var workouts: Workouts = []
    override func awake(withContext context: Any?) {
        //var workouts = WorkoutContext.sharedInstance.workouts
        WorkoutContext.sharedInstance.requestWorkoutsFromPhone()
        if let json = defaults?.string(forKey: "workoutData"), let workout = try? Workouts.init(json) {
            workouts = workout
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
        for iterator in rows..<workoutsTable.numberOfRows {
            let rowController = workoutsTable.rowController(at: iterator)
            if let controller = rowController as? WorkoutRowController {
                controller.workoutName.setText(workouts[iterator].name)
                controller.workoutSubTitle.setText("\(workouts[iterator].timers.count) timers")
                // 3
            }
        }
    }
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable,
                                  rowIndex: Int) -> Any? {
        return workouts[rowIndex]
    }

}
