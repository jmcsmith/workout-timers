//
//  AppDelegate.swift
//  workout-timers
//
//  Created by Joseph Smith on 5/18/18.
//  Copyright © 2018 Robotic Snail Software. All rights reserved.
//

import UIKit
import WatchConnectivity
import AVKit
import UserNotifications
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
    let workoutsChangedOnPhone = "workoutsChangedOnPhone"

    lazy var notificationCenter: NotificationCenter = {
        return NotificationCenter.default
    }()
    let notifications = Notifications()
    let nc = UNUserNotificationCenter.current()
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        if let error = error {
            print("WC Session activation failed with errors: \(error.localizedDescription)")
            return
        }
        print("WC Session activated with state: \(activationState.rawValue)")
    }
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WC Session did become inactive")
    }
    func sessionDidDeactivate(_ session: WCSession) {
        print("WC Session did deactivate")
        WCSession.default.activate()
    }
    var window: UIWindow?
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupWatchConnectivity()
        setupNotificationCenter()
        UIApplication.shared.isIdleTimerDisabled = true
        nc.delegate = self
        notifications.notificationRequest()
        return true
    }
    func setupWatchConnectivity() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            sendTimersToWatch()
        }
    }
    private func setupNotificationCenter() {
        _ = notificationCenter.addObserver(forName: NSNotification.Name(rawValue: workoutsChangedOnPhone),
                                           object: nil, queue: nil) { (_: Notification) -> Void in
                                            self.sendTimersToWatch()
        }
    }
    func sendTimersToWatch() {
        if WCSession.isSupported() {
            let defaults = UserDefaults(suiteName: "group.workouttimers")
            if let data = defaults?.data(forKey: "workoutData"),
                let workout = try? Workouts.init(data: data),
                let timers = ((try? workout.jsonString()) as String??) {
                let session = WCSession.default
                if session.isWatchAppInstalled {
                    do {
                        let dictionary = ["timers": timers]
                        try session.updateApplicationContext(dictionary as [String: Any])
                    } catch {
                        print("ERROR: \(error)")
                    }
                }
            }
        }
    }
    func applicationWillResignActive(_ application: UIApplication) {
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    func applicationWillTerminate(_ application: UIApplication) {
    }
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        guard url.pathExtension == "wt" else { return false }
        do {
            let content = try String.init(contentsOf: url)
            let workout = try Workout.init(content)
            guard let navigationController = window?.rootViewController as? UINavigationController,
                let workoutsTableViewController = navigationController.viewControllers.first as?
                WorkoutsTableViewController else {
                    return true
            }
            let defaults = UserDefaults(suiteName: "group.workouttimers")
            var currentWorkouts: Workouts = []
            if let data = defaults?.data(forKey: "workoutData"), let workout = try? Workouts.init(data: data) {
                currentWorkouts = workout
            }
            currentWorkouts.append(workout)
            ((try? defaults?.set(currentWorkouts.jsonData(), forKey: "workoutData")) as Void??)
            workoutsTableViewController.workouts = currentWorkouts
            workoutsTableViewController.tableView.reloadData()
            navigationController.popToRootViewController(animated: true)
            return true
        } catch {
            print(error)
            return false
        }
    }
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        print("Recieved context on phone")
        if let request = applicationContext["request"] as? String {
            if request == "sendWorkouts" {
                sendTimersToWatch()
            }
        }
    }
}
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        if UIApplication.shared.applicationState == .active {
//            completionHandler([])
//        }
        //

        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.identifier == "Local Notification" {
            print("Handling notifications with the Local Notification Identifier")
        }
        
        completionHandler()
    }


}
