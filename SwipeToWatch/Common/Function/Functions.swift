//
//  Functions.swift
//  SwipeToWatch
//
//  Created by Bagas Ilham on 25/01/2025.
//

import Foundation

func formatSecondsToTimeString(seconds: Int, stringFormat: String = "%02d:%02d") -> String {
    let minutes = seconds / 60
    let remainingSeconds = seconds % 60
    return String(format: stringFormat, minutes, remainingSeconds)
}
