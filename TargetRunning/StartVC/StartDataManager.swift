//
//  StartDataManager.swift
//  TargetRunning
//
//  Created by Константин Андреев on 01.06.2022.
//

import Foundation

enum RunGoal {
    case distance
    case time
}
class StartDataManager {
    static var shared = StartDataManager()
    var distancePickerData: [Array<Int>] {
            [Array(0...50), meters]
    }
    let timePickerData = [Array(0...10),Array(0...59)]
    var runGoal = RunGoal.time
    
    private let meters = Array(0...9).map {$0 * 100}
    init() {}
}
