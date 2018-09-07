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

    let workoutsChangedOnPhone = "workoutsChangedOnPhone"
    let requestWorkoutsFromPhone = "requestWorkoutsFromPhone"
    var workouts: Workouts = []

    func sendChangedOnPhoneNotification() {
        DispatchQueue.main.async { () -> Void in
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(name: Notification.Name(rawValue: self.workoutsChangedOnPhone), object: nil)
        }
    }
    func sendRequestWorkoutsFromPhoneNotification() {
        DispatchQueue.main.async { () -> Void in
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(name: Notification.Name(rawValue: self.requestWorkoutsFromPhone), object: nil)
        }
    }
}
