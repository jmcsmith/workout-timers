//
//  WorkoutContext.swift
//  workout-timers-watch Extension
//
//  Created by Joseph Smith on 6/9/18.
//  Copyright © 2018 Robotic Snail Software. All rights reserved.
//

import Foundation

class WorkoutContext {
    
     static let sharedInstance = WorkoutContext()
    
        let WorkoutsChangedOnPhone = "workoutsChangedOnPhone"
    var workouts: Workouts = []
    
    func sendChangedOnPhoneNotification() {
        DispatchQueue.main.async { () -> Void in
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(name: Notification.Name(rawValue: self.WorkoutsChangedOnPhone), object: nil)
        }
    }
}
