//
//  Utils.swift
//  TheArcXPtv
//
//  Created by Mahesh Venkateswarlu on 10/6/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import Foundation

// swiftlint:disable large_tuple
func secondsToHoursMinutesSeconds(_ seconds: Double) -> (hours: Int, minutes: Int, seconds: Int) {
    return (Int(seconds) / 3600, (Int(seconds) % 3600) / 60, (Int(seconds) % 3600) % 60)
}

func formatTimeFor(seconds: Double) -> String {
    let result = secondsToHoursMinutesSeconds(seconds)
    let hoursString = "\(result.hours)"
    var minutesString = "\(result.minutes)"
    if minutesString.count == 1 {
        minutesString = "0\(result.minutes)"
    }
    var secondsString = "\(result.seconds)"
    if secondsString.count == 1 {
        secondsString = "0\(result.seconds)"
    }
    var time = "\(hoursString):"
    if result.hours >= 1 {
        time.append("\(minutesString):\(secondsString)")
    } else {
        time = "\(minutesString):\(secondsString)"
    }
    return time
}
