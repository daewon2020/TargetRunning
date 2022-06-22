//
//  CurrentActivityViewModel.swift
//  TargetRunning
//
//  Created by Константин Андреев on 23.05.2022.
//

import Foundation
import CoreLocation
import CoreData
import MapKit

enum TimerState {
    case Start
    case Stop
}

protocol CurrentActivityProtocol {
    var paceSegment: Int { get }
    var paceSegmentString: String { get }
    var paceDistance: Double { get }
    var paceTime: Int { get }
    var avgPaceDistance: Int { get }
    var avgPaceDistanceString: String { get }
    var distance: Double { get }
    var distanceString: String { get }
    var time: Box<Int> { get }
    var timeString: String { get }
    var currentLocation: CLLocation? { get }
    var previousLocation: CLLocation? { get }
    var activity: Activity? { get }
    var routeCoordinate: RouteCoordinate? { get }
    var lineCoordinates: Box<[CLLocationCoordinate2D]> { get }
    var startResumeButtonImage: Box<UIImage?> { get }
    var stepValue: Double { get }
    var progressValue: Box<Double> { get }
    var goalLabel: String { get }
    var goalLabelColor: Box<UIColor> { get }
    var currentCounterString: String { get }
    var timeDistanceString: Box<String> { get }
    var timeDistanceSubtitle: String { get }
    var heartRate: Int { get }
    
    func getMKPolyline(with coordinates: [CLLocationCoordinate2D]) -> MKPolyline
    func setMapCenter(for mapView: MKMapView)
    func startActivity()
    func stopResumeButtonPressed()
    func finishButtonPressed()
    init(startParametes: StartParameters)
}

class CurrentActivityViewModel: NSObject, CurrentActivityProtocol {
    
    var heartRate = 0
    var stepValue = 0.0
    var progressValue = Box(value: 0.0)
    
    var startResumeButtonImage = Box(value: UIImage(systemName: "stop.fill"))
    
    var paceSegment: Int {
        get {
            paceDistance != 0
            ? Int(Double(paceTime) / paceDistance * 1000)
            : 0
        }
    }
    
    var paceDistance: Double {
        didSet {
            if paceDistance >= 1000 {
                addPaceInfo()
                paceTime = 0
                paceDistance = 0
            }
        }
    }
    
    var paceTime = 0
    var paceSegmentString: String {
        get {
            getTimeString(from: paceSegment)
        }
    }
    
    var avgPaceDistance: Int {
        get {
            distance != 0
            ? Int(Double(time.value) / distance * 1000)
            : 0
        }
    }
    
    var avgPaceDistanceString: String {
        getTimeString(from: avgPaceDistance)
    }

    var distance = 0.0
    var distanceString: String {
        String(format: "%0.2f", distance / 1000)
    }
    var time =  Box(value: 0)
    var previousLocation: CLLocation?
    var currentLocation: CLLocation? {
        didSet {
            calculateDistance()
        }
    }
    var timeString: String {
        getTimeString(from: time.value)
    }
    var activity: Activity?
    var routeCoordinate: RouteCoordinate?
    var lineCoordinates = Box(value: [CLLocationCoordinate2D]())
    
    var goalLabelColor = Box(value: UIColor.black)
    var goalLabel: String {
        get {
            let kilometers = startParameters.kilometers
            let meters = startParameters.meters
            let hours = startParameters.hourse
            let minutes = startParameters.minutes
            let seconds = hours * 3600 + minutes * 60
            switch startParameters.goal {
                case .Distance:
                    return "\(kilometers),\(meters / 100) km"
                case .Time:
                    return getTimeString(from: seconds)
            }
        }
    }
    
    var currentCounterString: String {
        switch startParameters.goal {
            case .Distance:
                return distanceString
            case .Time:
                return timeString
        }
    }
    
    var timeDistanceString = Box(value: "00,00")
    var timeDistanceSubtitle: String {
        get {
            switch startParameters.goal {
                case .Distance:
                    return "time"
                case .Time:
                    return "distance"
            }
        }
    }
    
    private var context = StorageManager.shared.persistentContainer.viewContext
    private var timerState: TimerState {
        didSet {
            switch timerState {
                case .Start:
                    self.startResumeButtonImage.value = UIImage(systemName: "play.fill")
                case .Stop:
                    self.startResumeButtonImage.value = UIImage(systemName: "stop.fill")
            }
        }
    }
    
    private var distanceGoal: Int {
        get {
            startParameters.kilometers * 1000 + startParameters.meters
        }
    }
    
    private let startParameters: StartParameters!
    
    required init(startParametes: StartParameters) {
        paceDistance = 0
        timerState = .Stop
        startParameters = startParametes

        super.init()
        
        TimeManager.shared.bind { time in
            self.time.value = time
            self.paceTime += 1
            self.addRouteCoordinate()
            
            switch self.startParameters.goal {
                case .Distance:
                    self.timeDistanceString.value = self.timeString
                case .Time:
                    self.progressValue.value += self.stepValue
            }
        }
        
        LocationManager.shared.bindLocation { currentLocation in
            self.currentLocation = currentLocation
        }
        
        HeartRateManager.shared.bindBPM { heartRate in
            if let heartRate = heartRate {
                self.heartRate = heartRate
            }
        }
        
        stepValue = self.calculateStepValue()
    }
    
    func startActivity() {
        addRouteCoordinate()
        
        resetActivityParameters()
        TimeManager.shared.startTimer()
        LocationManager.shared.start()
        createNewActivity()
        
        timerState = .Stop
    }
    
    func stopResumeButtonPressed() {
        switch timerState {
            case .Start:
                TimeManager.shared.resumeTimer()
                LocationManager.shared.start()
                
                timerState = .Stop
            case .Stop:
                TimeManager.shared.stopTimer()
                LocationManager.shared.stop()
                StorageManager.shared.saveContext()
                previousLocation = nil
                timerState = .Start
        }
    }
    
    func finishButtonPressed() {
        TimeManager.shared.stopTimer()
        LocationManager.shared.stop()
        saveActivity()
        
        timerState = .Start
    }
    
    func getMKPolyline(with coordinates: [CLLocationCoordinate2D]) -> MKPolyline {
        MKPolyline(coordinates: coordinates, count: coordinates.count)
    }
    
    
    func setMapCenter(for mapView: MKMapView) {
        guard let location = currentLocation?.coordinate else { return }
            
        let span = MKCoordinateSpan.init(latitudeDelta: 0.0055, longitudeDelta: 0.0055)
        let region = MKCoordinateRegion.init(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
}

//MARK: - Private funcs

extension CurrentActivityViewModel {
    private func saveActivity() {
        if let activity = activity {
            activity.avgPace = Int64(avgPaceDistance)
            activity.time = Int64(time.value)
            StorageManager.shared.saveContext()
        }
    }

    private func createNewActivity() {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Activity", in: context) else { return }
        if let activity = NSManagedObject(entity: entityDescription, insertInto: context) as? Activity {
            activity.date = Date()
            self.activity = activity
        }
    }
    
    private func resetActivityParameters() {
        distance = 0.0
        paceTime = 0
        paceDistance = 0
        previousLocation = nil
        //currentLocation = nil
        lineCoordinates.value = [CLLocationCoordinate2D]()
    }
    
    private func getTimeString(from seconds: Int) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) / 60 % 60
        let seconds = Int(seconds) % 60
        
        var times: [String] = []
        if hours >= 0 {
            times.append(String(format: "%02i", hours))
        }
        if minutes >= 0 {
            times.append(String(format: "%02i", minutes))
        }
        times.append(String(format: "%02i", seconds))
        
        return times.joined(separator: ":")
    }
    
    private func calculateDistance() {
        guard let currentLocation = currentLocation else { return }
        if let previousLocation = previousLocation {
            
            let currentDistance = currentLocation.distance(from: previousLocation)
            
            distance += currentDistance
            paceDistance += currentDistance
            
            switch startParameters.goal {
                case .Distance:
                    if progressValue.value < 1 {
                        progressValue.value = distance / Double(distanceGoal)
                    } else {
                        if goalLabelColor.value != UIColor.systemGreen {
                            goalLabelColor.value = UIColor.systemGreen
                        }
                    }   
                case .Time:
                    timeDistanceString.value = distanceString
            }
            
            let startLineCoordinate = CLLocationCoordinate2D(
                latitude: previousLocation.coordinate.latitude,
                longitude: previousLocation.coordinate.longitude
            )
            
            let endLineCoordinate = CLLocationCoordinate2D(
                latitude: currentLocation.coordinate.latitude,
                longitude: currentLocation.coordinate.longitude
            )
            
            lineCoordinates.value = [startLineCoordinate, endLineCoordinate]
            
            if let activity = activity {
                activity.distance = distance
            }
            self.previousLocation = currentLocation
        } else {
            self.previousLocation = currentLocation
        }
    }
    
    private func addRouteCoordinate() {
        guard let currentLocation = currentLocation else { return }
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "RouteCoordinate", in: context) else { return }
        
        if let routeCoordinate = NSManagedObject(entity: entityDescription, insertInto: context) as? RouteCoordinate {
            routeCoordinate.latitude = currentLocation.coordinate.latitude
            routeCoordinate.longitude = currentLocation.coordinate.longitude
            routeCoordinate.date = Date()
            routeCoordinate.activity = activity
        }
    }
    
    private func addPaceInfo() {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Pace", in: context) else { return }
        if let pace = NSManagedObject(entity: entityDescription, insertInto: context) as? Pace {
            pace.time = Int64(paceSegment)
            pace.date = Date()
            pace.activity = activity
        }
    }
    
    private func calculateStepValue() -> Double {
        switch startParameters.goal {
            case .Distance:
                return 1.0 / Double(startParameters.meters + startParameters.kilometers * 1000)
            case .Time:
                return 1.0 / Double(startParameters.hourse * 3600 + startParameters.minutes * 60)
        }
    }
}
