//
//  ExtensionDelegate.swift
//  workout-timers-watch Extension
//
//  Created by Joseph Smith on 6/7/18.
//  Copyright © 2018 Robotic Snail Software. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {

    let requestWorkoutsFromPhone = "requestWorkoutsFromPhone"
    lazy var notificationCenter: NotificationCenter = {
        return NotificationCenter.default
    }()

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        if let error = error {
            print("WC Session activation failed with error: \(error.localizedDescription)")
            return
        }
        print("WC Session activated with state: \(activationState.rawValue)")
    }

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        setupWatchConnectivity()
        setupNotificationCenter()
    }
    func setupWatchConnectivity() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    private func setupNotificationCenter() {
        var observer = notificationCenter.addObserver(forName: NSNotification.Name(rawValue: requestWorkoutsFromPhone),
                                                      object: nil, queue: nil) { (_: Notification) -> Void in
            print("Notification recieved")
            self.requestTimersFromPhone()
        }
    }
    func applicationDidBecomeActive() {

    }

    func applicationWillResignActive() {

    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            if #available(watchOSApplicationExtension 5.0, *) {
                switch task {
                case let backgroundTask as WKApplicationRefreshBackgroundTask:
                    // Be sure to complete the background task once you’re done.
                    backgroundTask.setTaskCompletedWithSnapshot(false)
                case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                    // Snapshot tasks have a unique completion call, make sure to set your expiration date
                    snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration:
                        Date.distantFuture, userInfo: nil)
                case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                    // Be sure to complete the connectivity task once you’re done.
                    connectivityTask.setTaskCompletedWithSnapshot(false)
                case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                    // Be sure to complete the URL session task once you’re done.
                    urlSessionTask.setTaskCompletedWithSnapshot(false)
                case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                    // Be sure to complete the relevant-shortcut task once you're done.
                    relevantShortcutTask.setTaskCompletedWithSnapshot(false)
                case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                    // Be sure to complete the intent-did-run task once you're done.
                    intentDidRunTask.setTaskCompletedWithSnapshot(false)
                default:
                    // make sure to complete unhandled task types
                    task.setTaskCompletedWithSnapshot(false)
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        print("Received")
        let defaults = UserDefaults(suiteName: "group.workouttimers")
        if let timers = applicationContext["timers"] as? String {
            print(timers)
            defaults?.set(timers, forKey: "workoutData")
            //            let t = try? Workouts.init(timers)
            //            if let w = t {
            //                WorkoutContext.sharedInstance.workouts = w
            //            }
            DispatchQueue.main.async {

                WKInterfaceController.reloadRootPageControllers(withNames: ["WorkoutsInterfaceController"],
                                                                contexts: nil,
                                                                orientation: WKPageOrientation.vertical,
                                                                pageIndex: 0)

            }

        }

    }
    func requestTimersFromPhone() {
        print("Request Timers")
        if WCSession.isSupported() {
            let session = WCSession.default
            do {
                let dictionary = ["request": "sendWorkouts"]
                try session.updateApplicationContext(dictionary as [String: Any])
            } catch {
                print("ERROR: \(error)")
            }
        }
    }

}
