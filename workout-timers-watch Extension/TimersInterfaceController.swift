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
    var workout: Workout?
    var currentTimer = CurrentTimer()
    var timer: UIKit.Timer!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        
        
        if let workout = context as? Workout {
            self.setTitle(workout.name)
            self.workout = workout
            let headerRows = NSIndexSet(indexesIn: NSRange(location: 0, length: 1))
            timersTable.insertRows(at: headerRows as IndexSet, withRowType: "HeaderRowType")
            
            
            let rows = timersTable.numberOfRows
            let itemRows = NSIndexSet(indexesIn: NSRange(location: rows, length: workout.timers.count))
            timersTable.insertRows(at: itemRows as IndexSet, withRowType: "TimerRowType")
            for i in rows..<timersTable.numberOfRows {
                // 1
                let c = timersTable.rowController(at: i)
                // 2
                if let controller = c as? TimerRowController {
                    controller.timerName.setText(workout.timers[i - 1].name)
                    controller.timerTime.setText(workout.timers[i - 1].time.description)
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
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if rowIndex == 0 {
            print("play")
            playTimers()
        } else {
            WKInterfaceDevice.current().play(.notification)
        }
    }
    func playTimers() {
        setTimerToIndex(index: 0)
    }
    func setTimerToIndex(index: Int){
        if let time = workout?.timers[index].time {
            WKInterfaceDevice.current().play(.notification)
            self.timersTable.scrollToRow(at: index + 1)
            currentTimer.startTime = time
            currentTimer.currentTime = time
            currentTimer.timerIndex = index
            
        }
        
        timer = UIKit.Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    @objc func updateTimer(){
        if currentTimer.currentTime > 0 {
            currentTimer.currentTime -= 1
            let index = currentTimer.timerIndex
            let cell = timersTable.rowController(at: index + 1) as? TimerRowController
            cell?.timerTime?.setText(currentTimer.currentTime.description)
            //cell?.progressView.setProgress(Float((currentTimer.startTime - currentTimer.currentTime) / currentTimer.startTime), animated: true)
            //cell?.backgroundColor = UIColor.green
            print(currentTimer.currentTime)
        } else {
            timer.invalidate()
            print("end timer")
            if currentTimer.timerIndex < (workout?.timers.count)! - 1 {
                setTimerToIndex(index: (currentTimer.timerIndex + 1))
            } else {
                //                DispatchQueue.main.async {
                //                    self.playPauseButton.isEnabled = true
                //                    self.randomButton.isEnabled = true
                //                }
            }
        }
    }
}
