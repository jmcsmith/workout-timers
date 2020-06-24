//
//  Notifications.swift
//  workout-timers
//
//  Created by Joseph Smith on 5/12/20.
//  Copyright © 2020 Robotic Snail Software. All rights reserved.
//

import Foundation
import UserNotifications
import AVFoundation

class Notifications: NSObject, UNUserNotificationCenterDelegate {
    func notificationRequest() {
        let nc = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound]
        nc.requestAuthorization(options: options) { (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
    }
    func scheduleNotification(notificationType: String) {
        let nc = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = notificationType
        content.body = "This is example how to create " + notificationType + "Notifications"
        content.sound = UNNotificationSound.default
        content.badge = 1
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        nc.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    func scheduleNotification(currentIndex: Int){
        print(currentIndex)
        
        if let workout = WorkoutContext.sharedInstance.currentWorkout {
            if currentIndex < workout.timers.count {
                let currentTimer = workout.timers[currentIndex]
                let nextTimer = workout.timers[currentIndex + 1]
                let nc = UNUserNotificationCenter.current()
                let content = UNMutableNotificationContent()
                content.title = ""
                content.body = "Time to start \(nextTimer.name) for \(currentTimer.time) seconds."
                content.sound = UNNotificationSound.default
                content.badge = 1
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: nextTimer.time, repeats: false)
                let identifier = "Local Notification"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                nc.add(request) { (error) in
                    if let error = error {
                        print("Error \(error.localizedDescription)")
                    }
                }
                WorkoutContext.sharedInstance.currentTimerIndex = currentIndex + 1
            }
        }
    }
    func scheduleNotifications(workout: Workout){
        var startOffset = 0.0
        for index in 1...(workout.timers.count - 1) {
            startOffset += workout.timers[index].time
            scheduleTimer(offset: startOffset, timer: workout.timers[index])
        }
    }
    func scheduleTimer(offset: Double, timer: Timer){
        let nc = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = ""
        content.body = "Time to start \(timer.name) for \(timer.time) seconds."
        //
        let targetURL = try? FileManager.default.soundsLibraryURL(for: "\(timer.name).caf")
        if let targetURL = targetURL {
            let speechUtterance = AVSpeechUtterance(string: timer.name)
            speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            try? saveAVSpeechUtteranceToFile(utterance: speechUtterance, fileURL: targetURL)
             content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(timer.name).caf"))
//            let fileManager = FileManager()
//            if fileManager.fileExists(atPath: targetURL.path) {
//                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(timer.name).caf"))
//            } else {
//                content.sound = UNNotificationSound.default
//            }
        }
        //


        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: offset, repeats: false)
        let identifier = "\(timer.name) - \(timer.time)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        nc.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    func saveAVSpeechUtteranceToFile(utterance: AVSpeechUtterance, fileURL: URL) throws {
        let synthesizer = AVSpeechSynthesizer()
        
        var output: AVAudioFile?
        do {
               try FileManager.default.removeItem(at: fileURL)
        } catch {
            print(error)
        }
     
        if #available(iOS 13.0, *) {
            synthesizer.write(utterance) { buffer in
                guard let pcmBuffer = buffer as? AVAudioPCMBuffer else {
                    
                    return
                }
                if pcmBuffer.frameLength == 0 {
                    // no length
                }else{
                    if output == nil {
                        do {
                            output = try AVAudioFile(forWriting: fileURL, settings: pcmBuffer.format.settings, commonFormat: .pcmFormatInt16, interleaved: false)
                        } catch  {
                            print(error)
                        }
                        
                    }
                    do {
                        try output!.write(from: pcmBuffer)
                    } catch {
                        print(error)
                    }
                    
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
extension FileManager {
    
    func soundsLibraryURL(for filename: String) throws -> URL {
        let libraryURL = try url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let soundFolderURL = libraryURL.appendingPathComponent("Sounds", isDirectory: true)
        if !fileExists(atPath: soundFolderURL.path) {
            try createDirectory(at: soundFolderURL, withIntermediateDirectories: true)
        }
        return soundFolderURL.appendingPathComponent(filename, isDirectory: false)
    }
}

