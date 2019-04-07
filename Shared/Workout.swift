//
//  Workout.swift
//  workout-timers
//
//  Created by Joseph Smith on 5/18/18.
//  Copyright © 2018 Robotic Snail Software. All rights reserved.
//

//   let workouts = try Workouts(json)

// To parse the JSON, add this file to your project and do:
//
//   let workouts = try Workouts(json)

import Foundation

typealias Workouts = [Workout]

class Workout: Codable, NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        var timerDuplicates: [Timer] = []
        for timer in timers {
            if let timer = timer.copy() as? Timer {
                timerDuplicates.append(timer)
            }
        }
        let duplicate = Workout(timers: timerDuplicates, name: self.name, type: self.type, color: self.color)
        return duplicate
    }
    
    
    var timers: [Timer]
    var name: String
    var type: String
    var color: String
    
    enum CodingKeys: String, CodingKey {
        case timers
        case name
        case type
        case color
    }
    
    init(timers: [Timer], name: String, type: String, color: String) {
        self.timers = timers
        self.name = name
        self.type = type
        self.color = color
    }
}

class Timer: Codable, NSCopying {
    
    var name: String
    var time: Double
    var color: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case time
        case color
    }
    
    init(name: String, time: Double, color: String) {
        self.name = name
        self.time = time
        self.color = color
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let duplicate = Timer(name: self.name, time: self.time, color: self.color)
        return duplicate
    }
}

// MARK: Convenience initializers

extension Workout {
    convenience init(data: Data) throws {
        let tempObject = try JSONDecoder().decode(Workout.self, from: data)
        self.init(timers: tempObject.timers, name: tempObject.name, type: tempObject.type, color: tempObject.color)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func jsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

extension Timer {
    convenience init(data: Data) throws {
        let tempObject = try JSONDecoder().decode(Timer.self, from: data)
        self.init(name: tempObject.name, time: tempObject.time, color: tempObject.color)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func jsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

extension Array where Element == Workouts.Element {
    init(data: Data) throws {
        self = try JSONDecoder().decode(Workouts.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func jsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
