//
//  ActivityVC.swift
//  TargetRunning
//
//  Created by Константин Андреев on 27.05.2022.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class ActivityVC: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    
    var activity: Activity!
    private var route: [RouteCoordinate]!
    private var routeCoordinates = [CLLocationCoordinate2D]()
    private var context = StorageManager.shared.persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        fetchData()
        drawRoute()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setMapRegion()
    }
    
    private func setMapRegion() {
        let latitudes = route.map { $0.map { $0.latitude } }
        let longitudes = route.map { $0.map { $0.longitude } }
        
        guard let maxLat = latitudes?.max() else { return }
        guard let minLat = latitudes?.min() else { return }
        guard let maxLong = longitudes?.max() else { return }
        guard let minLong = longitudes?.min() else { return }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLong + maxLong) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.3,
            longitudeDelta: (maxLong - minLong) * 1.3
        )
        
        let region = MKCoordinateRegion.init(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    private func fetchData() {
        let request = RouteCoordinate.fetchRequest()
        request.predicate = NSPredicate(format: "ANY activity = %@", activity)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        do {
            route = try context.fetch(request)
        } catch let error {
            print("Failed to fetch data", error)
        }
    }

    private func drawRoute() {
        for coordinate in route {
            routeCoordinates.append(
                .init(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                )
            )
        }
        
        let polyline = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
        mapView.addOverlay(polyline)
    }
}

extension ActivityVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .green
            renderer.lineWidth = 2.0
            
            return renderer
        }
        fatalError("Polyline Renderer could not be initialized")
    }
}
