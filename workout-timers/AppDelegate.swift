//
//  AppDelegate.swift
//  workout-timers
//
//  Created by Joseph Smith on 5/18/18.
//  Copyright © 2018 Robotic Snail Software. All rights reserved.
//

import UIKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WC Session activation failed with errors: \(error.localizedDescription)")
            return
        }
        print("WC Session activated with state: \(activationState.rawValue)")
        setupWatchConnectivity()
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WC Session did become inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("WC Session did deactivate")
        WCSession.default.activate()
    }
    
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupWatchConnectivity()
        
        return true
    }
    func setupWatchConnectivity(){
        if WCSession.isSupported() {
            
            let session = WCSession.default
            session.delegate = self
            session.activate()
                sendTimersToWatch()
        }
    }
    func sendTimersToWatch() {
        if WCSession.isSupported() {
            var timers = ""
            var defaults = UserDefaults(suiteName: "group.workouttimers")
            if let data = defaults?.data(forKey: "workoutData"), let wo = try? Workouts.init(data: data), let timers = try? wo.jsonString() {
                let session = WCSession.default
                if session.isWatchAppInstalled {
                    do {
                        let dictionary = ["timers": timers]
                        print(timers)
                        try session.updateApplicationContext(dictionary)
                    }
                    catch{
                        print("ERROR: \(error)")
                    }
                }
            }
        }
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        guard url.pathExtension == "wt" else { return false }
        do {
            let content = try String.init(contentsOf: url)
            let workout = try Workout.init(content)
            guard let navigationController = window?.rootViewController as? UINavigationController,
                let workoutsTableViewController = navigationController.viewControllers.first as? WorkoutsTableViewController else {
                    return true
            }
            let defaults = UserDefaults(suiteName: "group.workouttimers")
            var currentWorkouts: Workouts
            if let data = defaults?.data(forKey: "workoutData"), let wo = try? Workouts.init(data: data) {
                currentWorkouts = wo
                currentWorkouts.append(workout)
                try? defaults?.set(currentWorkouts.jsonData(), forKey: "workoutData")
                workoutsTableViewController.workouts = currentWorkouts
            }
            workoutsTableViewController.tableView.reloadData()
            return true
        } catch {
            print(error)
            return false
        }
    }
    
}

