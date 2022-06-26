//
//  ActivityLogDetailsVC.swift
//  TargetRunning
//
//  Created by Константин Андреев on 27.05.2022.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

protocol ActivityLogDetailsViewInputProtocol: AnyObject {
    func displayRoute(for route: MKPolyline)
    func setMapRegion(with region: MKCoordinateRegion)
}

protocol ActivityLogDetailsViewOutputProtocol: AnyObject {
    func viewDidAppear()
}

class ActivityLogDetailsVC: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    
    var presenter: ActivityLogDetailsViewOutputProtocol!
    var configurator = ActivityLogDetailsConfigurator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presenter.viewDidAppear()
    }
    
//    private func setMapRegion() {
//        let latitudes = route.map { $0.map { $0.latitude } }
//        let longitudes = route.map { $0.map { $0.longitude } }
//
//        guard let maxLat = latitudes?.max() else { return }
//        guard let minLat = latitudes?.min() else { return }
//        guard let maxLong = longitudes?.max() else { return }
//        guard let minLong = longitudes?.min() else { return }
//
//        let center = CLLocationCoordinate2D(
//            latitude: (minLat + maxLat) / 2,
//            longitude: (minLong + maxLong) / 2
//        )
//        let span = MKCoordinateSpan(
//            latitudeDelta: (maxLat - minLat) * 1.3,
//            longitudeDelta: (maxLong - minLong) * 1.3
//        )
//
//        let region = MKCoordinateRegion.init(center: center, span: span)
//        mapView.setRegion(region, animated: true)
//    }
}

//MARK: - MKMapViewDelegate

extension ActivityLogDetailsVC: MKMapViewDelegate {
    
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

//MARK: - ActivityLogDetailsViewInputProtocol

extension ActivityLogDetailsVC: ActivityLogDetailsViewInputProtocol {
    func displayRoute(for route: MKPolyline) {
        mapView.addOverlay(route)
    }
    
    func setMapRegion(with region: MKCoordinateRegion) {
        mapView.setRegion(region, animated: true)
    }
}
