//
//  TimersInterfaceController.swift
//  workout-timers-watch Extension
//
//  Created by Joseph Smith on 6/12/18.
//  Copyright © 2018 Robotic Snail Software. All rights reserved.
//

import WatchKit
import Foundation


class TimersInterfaceController: WKInterfaceController {
    
    @IBOutlet var timersTable: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if let workout = context as? Workout {
            self.setTitle(workout.name)
            let rows = timersTable.numberOfRows
            let itemRows = NSIndexSet(indexesIn: NSRange(location: 0, length: workout.timers.count))
            timersTable.insertRows(at: itemRows as IndexSet, withRowType: "TimerRowType")
            for i in rows..<timersTable.numberOfRows {
                // 1
                let c = timersTable.rowController(at: i)
                // 2
                if let controller = c as? TimerRowController {
                    controller.timerName.setText(workout.timers[i].name)
                    controller.timerTime.setText(workout.timers[i].time.description)
                    // 3
                }
            }
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
