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
    func reloadData(with cellData: [ActivityLogCellViewModel])
}

protocol ActivityLogDetailsViewOutputProtocol: AnyObject {
    func viewDidAppear()
    func viewDidLoad()
}

class ActivityLogDetailsVC: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var activityParamsTableView: UITableView!
    
    
    var presenter: ActivityLogDetailsViewOutputProtocol!
    var configurator = ActivityLogDetailsConfigurator()
    
    private var reusableCell = [ActivityLogCellViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        activityParamsTableView.dataSource = self
        presenter.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presenter.viewDidAppear()
        
    }
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
    func reloadData(with cellData: [ActivityLogCellViewModel]) {
        reusableCell = cellData
        activityParamsTableView.reloadData()
    }
    
    func displayRoute(for route: MKPolyline) {
        mapView.addOverlay(route)
    }
    
    func setMapRegion(with region: MKCoordinateRegion) {
        mapView.setRegion(region, animated: true)
    }
}

//MARK: - TableViewDataSource
extension ActivityLogDetailsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reusableCell.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = reusableCell[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.cellID, for: indexPath) as? ActivityLogTableViewCell else { return UITableViewCell() }
        cell.viewModel = cellViewModel
        return cell
    }

}

