//
//  StartViewModel.swift
//  TargetRunning
//
//  Created by Константин Андреев on 01.06.2022.
//

import Foundation
import UIKit

protocol StartViewModelProtocol {
    var distancePickerData: [[Int]] { get }
    var timePickerData: [[Int]] { get }
    var runGoal: Box<RunGoal> { get }
    var minutes: Int { get }
    var hours: Int { get }
    var kilometers: Int { get }
    var meters: Int { get }
    
    func showTargetList() -> UIAlertController
    func getStartParameters() -> StartParameters
    func setGoalValue(for firstRowIndex: Int, and secondRowIndex: Int, completion: (String) -> ())
}

class StartViewModel: StartViewModelProtocol {
    
    var minutes = 0
    var hours = 0
    var kilometers = 0
    var meters = 0
    var runGoal = Box(value: StartDataManager.shared.runGoal)
    
    var distancePickerData: [[Int]] {
        get {
            StartDataManager.shared.distancePickerData
        }
    }
    var timePickerData: [[Int]] {
        get {
            StartDataManager.shared.timePickerData
        }
    }
    
    func showTargetList() -> UIAlertController {
        let alertControler = UIAlertController(title: nil , message: nil, preferredStyle: .actionSheet)
        let distanceAction = UIAlertAction(title: "Distance", style: .default) { action in
            StartDataManager.shared.runGoal = .Distance
            self.runGoal.value = .Distance
        }
        let timeAction = UIAlertAction(title: "Time", style: .default) { action in
            StartDataManager.shared.runGoal = .Time
            self.runGoal.value = .Time
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            StartDataManager.shared.runGoal = .Time
            self.runGoal.value = .Time
        }
        alertControler.addAction(distanceAction)
        alertControler.addAction(timeAction)
        alertControler.addAction(cancelAction)
        return alertControler
    }
    
    func getStartParameters() -> StartParameters {
        let startParameter = StartParameters(
            goal: StartDataManager.shared.runGoal,
            minutes: minutes,
            hourse: hours,
            kilometers: kilometers,
            meters: meters
        )
        return startParameter
    }
    
    func setGoalValue(for firstRowIndex: Int, and secondRowIndex: Int, completion: (String) -> ()) {
        switch runGoal.value {
            case .Distance:
                kilometers = StartDataManager.shared.distancePickerData[0][firstRowIndex]
                meters = StartDataManager.shared.distancePickerData[1][secondRowIndex]
                let goalValueString =  meters == 0 ? "\(kilometers)" : "\(kilometers),\(meters)"
                completion(goalValueString)
            case .Time:
                hours = StartDataManager.shared.timePickerData[0][firstRowIndex]
                minutes = StartDataManager.shared.timePickerData[1][secondRowIndex]
                let goalValueString = String(format: "%02i", hours) + ":" + String(format: "%02i", minutes)
                completion(goalValueString)
        }
    }
}
