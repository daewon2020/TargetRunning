//
//  StartDataManager.swift
//  TargetRunning
//
//  Created by Константин Андреев on 01.06.2022.
//

import Foundation

enum RunGoal {
    case Distance
    case Time
}
class StartDataManager {
    static var shared = StartDataManager()
    
    let distancePickerData = [Array(0...50),Array(0...9)]
    let timePickerData = [Array(0...10),Array(0...59)]
    var runGoal = RunGoal.Time
    
    init() {}
}
