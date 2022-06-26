//
//  ActivityLogDetailsPresenter.swift
//  TargetRunning
//
//  Created by Константин Андреев on 26.06.2022.
//

import Foundation
import MapKit
import CoreLocation

class ActivityLogDetailsPresenter: ActivityLogDetailsInteractorOutputProtocol {

    unowned let view: ActivityLogDetailsViewInputProtocol
    var interactor: ActivityLogDetailsInteractorInputProtocol!
    
    init(view: ActivityLogDetailsViewInputProtocol) {
        self.view = view
    }
    
    func routeDidRecieve(route: [RouteCoordinate]) {
        var routeCoordinates = [CLLocationCoordinate2D]()
        
        for coordinate in route {
            routeCoordinates.append(
                .init(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                )
            )
        }
        
        let polyline = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
        view.displayRoute(for: polyline)
        
        if let mapRegion = getMapRegion(from: route) {
            view.setMapRegion(with: mapRegion)
        }
    }
    
    private func getMapRegion(from route: [RouteCoordinate]) -> MKCoordinateRegion? {
        let latitudes = route.map { $0.latitude }
        let longitudes = route.map { $0.longitude }

        guard let maxLat = latitudes.max() else { return nil }
        guard let minLat = latitudes.min() else { return nil }
        guard let maxLong = longitudes.max() else { return nil }
        guard let minLong = longitudes.min() else { return nil }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLong + maxLong) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.3,
            longitudeDelta: (maxLong - minLong) * 1.3
        )

        return MKCoordinateRegion.init(center: center, span: span)
    }
}


extension ActivityLogDetailsPresenter: ActivityLogDetailsViewOutputProtocol {
    func viewDidAppear() {
        interactor.fetchRoute()
    }
}
