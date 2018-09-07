//
//  TimerTableViewCell.swift
//  workout-timers
//
//  Created by Joseph Smith on 6/5/18.
//  Copyright © 2018 Robotic Snail Software. All rights reserved.
//

import UIKit

class TimerTableViewCell: UITableViewCell {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var timerName: UILabel!
    @IBOutlet weak var timerTime: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
