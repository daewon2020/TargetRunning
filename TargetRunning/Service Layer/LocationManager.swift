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
    private var listenerLocation: Listener?
    private var listenerRoughLocation: Listener?
    
    var currentLocation: CLLocation? {
        didSet {
            listenerLocation?(currentLocation)
        }
    }
    
    var roughLocation: CLLocation? {
        didSet {
            listenerRoughLocation?(roughLocation)
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
        guard let location = locations.last else { return }
        roughLocation = location
        guard location.horizontalAccuracy < 20 else { return }
        currentLocation = location
    }
    
    func start() {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    func bindLocation(listener: @escaping Listener) {
        self.listenerLocation = listener
        listener(currentLocation)
    }
    
    func bindRoughLocation(listener: @escaping Listener) {
        self.listenerRoughLocation = listener
        listener(roughLocation)
    }
}



