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

class Workout: Codable {
    var timers: [Timer]
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case timers = "timers"
        case name = "name"
    }
    
    init(timers: [Timer], name: String) {
        self.timers = timers
        self.name = name
    }
}

class Timer: Codable {
    var name: String
    var time: Double
    var color: String
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case time = "time"
        case color = "color"
    }
    
    init(name: String, time: Double, color: String) {
        self.name = name
        self.time = time
        self.color = color
    }
}

// MARK: Convenience initializers

extension Workout {
    convenience init(data: Data) throws {
        let me = try JSONDecoder().decode(Workout.self, from: data)
        self.init(timers: me.timers, name: me.name)
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
        let me = try JSONDecoder().decode(Timer.self, from: data)
        self.init(name: me.name, time: me.time, color: me.color)
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
