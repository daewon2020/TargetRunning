//
//  StartViewModel.swift
//  TargetRunning
//
//  Created by Константин Андреев on 01.06.2022.
//

import Foundation
import UIKit
import CoreLocation

protocol StartViewModelProtocol {
    var distancePickerData: [[Int]] { get }
    var timePickerData: [[Int]] { get }
    var runGoal: Box<RunGoal> { get }
    var minutes: Int { get }
    var hours: Int { get }
    var kilometers: Int { get }
    var meters: Int { get }
    var weather: Box<Weather> { get }
    var temperature: String { get }
    var weatherDescription: String { get }
    var weatherIcon: Box<UIImage> { get }
    var getLocation: Bool { get }
    var currentLocation: CLLocation? { get }
    
    func showTargetList() -> UIAlertController
    func getStartParameters() -> StartParameters
    func setGoalValue(for firstRowIndex: Int, and secondRowIndex: Int, completion: (String) -> ())
    func startButtonTapped() -> UIAlertController?
    func getWeatherData()
    init()
    
}

class StartViewModel: StartViewModelProtocol {

    var minutes = 0
    var hours = 0
    var kilometers = 0
    var meters = 0
    var runGoal = Box(value: StartDataManager.shared.runGoal)
    var weather: Box<Weather>  = Box(value: Weather.init(weather: nil, main: nil))
    var weatherIcon: Box<UIImage> = Box(value: UIImage())
    var getLocation = false
    var currentLocation: CLLocation? = nil {
        didSet {
            if !getLocation && currentLocation != nil {
                getWeatherData()
            }
        }
    }
    
    

    var temperature: String {
        get {
            if let temperature = weather.value.main?.temp {
                return String(format: "%0.1f", temperature) + " C"
            }
            else {
                return ""
            }
        }
    }
    
    var weatherDescription: String {
        get {
            if let temperature = weather.value.weather?.first?.description {
                return temperature
            }
            else {
                return ""
            }
        }
    }

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
    
    required init() {
        LocationManager.shared.bind { currentLocation in
            self.currentLocation = currentLocation
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
    
    func startButtonTapped() -> UIAlertController? {
        if !checkGoal() {
            let alertControler = UIAlertController(
                title: nil ,
                message: "Please set goal for your run",
                preferredStyle: .alert
            )
            let action = UIAlertAction(title: "OK", style: .default)
            alertControler.addAction(action)
            return alertControler
        }
        return nil
    }
    
    func getWeatherData() {
                
                getLocation = true
                
                let lon = currentLocation!.coordinate.longitude
                let lat = currentLocation!.coordinate.latitude
                
                NetworkManager.shared.fetchWeatherData(lon: lon , lat: lat) { result in
                    switch result {
                        case .success(let weather):
                            self.weather.value = weather
                            
                            if let iconName = weather.weather?.first?.icon {
                                NetworkManager.shared.fetchWeatherIcon(iconName: iconName) { data in
                                    if let image = UIImage(data: data) {
                                        self.weatherIcon.value = image
                                    } else {
                                        self.weatherIcon.value = UIImage(systemName: "icloud.slash")!
                                    }
                                }
                            }
                            
                        case .failure( let error):
                            print(error.localizedDescription)
                    }
                }
        //LocationManager.shared.stop()

    }
    
    private func checkGoal() -> Bool {
        switch runGoal.value {
            case .Distance:
                return kilometers == 0 && meters == 0 ? false : true
            case .Time:
                return hours == 0 && minutes == 0 ? false : true
        }
    }
}
