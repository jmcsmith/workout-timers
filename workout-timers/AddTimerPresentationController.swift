//
//  AddTimerPresentationController.swift
//  workout-timers
//
//  Created by Joseph Smith on 7/30/18.
//  Copyright © 2018 Robotic Snail Software. All rights reserved.
//

import UIKit

class AddTimerPresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        get {
            guard let theView = containerView else {
                return CGRect.zero
            }
               return CGRect(x: 0, y: theView.bounds.height-162, width: theView.bounds.width, height: 162)
        }
    }
    
}
