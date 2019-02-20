//
//  UISegmentedControl+Utils.swift
//  workout-timers
//
//  Created by Joseph Smith on 2/20/19.
//  Copyright © 2019 Robotic Snail Software. All rights reserved.
//

import Foundation
import UIKit

extension UISegmentedControl {
    func indexFor(title: String) -> Int {
        var foundIndex = 0
        for index in 0..<self.numberOfSegments {
            if self.titleForSegment(at: index) == title {
                foundIndex = index
                break
            }
        }
        return foundIndex
    }
}
