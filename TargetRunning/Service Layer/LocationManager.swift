//
//  LocationManager.swift
//  TargetRunning
//
//  Created by Константин Андреев on 23.05.2022.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    static var shared = LocationManager()
    typealias Listener = (CLLocation?) -> Void
    private var listener: Listener?
    
    var currentLocation: CLLocation? {
        didSet {
            listener?(currentLocation)
        }
    }
    
    private var locationManager =  CLLocationManager()
    
    override init() {
        super.init()
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 5
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            guard let location = locations.last else { return }
            currentLocation = location
        }
    }
    
    func start() {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    func bind(listener: @escaping Listener) {
        self.listener = listener
        listener(currentLocation)
    }
    
    func getCurrentLocation() -> CLLocationCoordinate2D? {
        start()
        let location = locationManager.location?.coordinate
        stop()
        return location
    }
}



