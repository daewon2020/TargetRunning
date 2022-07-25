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
    @IBOutlet var activityPacesCollectionView: UICollectionView!
    
    var presenter: ActivityLogDetailsViewOutputProtocol!
    var configurator = ActivityLogDetailsConfigurator()
    
    private var reusableTableViewCell = [ActivityLogCellViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        activityParamsTableView.dataSource = self
        activityPacesCollectionView.dataSource = self
        activityPacesCollectionView.delegate = self
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
        reusableTableViewCell = cellData
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
        reusableTableViewCell.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = reusableTableViewCell[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.cellID, for: indexPath) as? ActivityLogTableViewCell else { return UITableViewCell() }
        cell.viewModel = cellViewModel
        return cell
    }
}


extension ActivityLogDetailsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40, height: collectionView.bounds.height)
    }
}

//MARK: - CollectionViewDataSource
extension ActivityLogDetailsVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "paceID", for: indexPath)
        let cellHeight = collectionView.bounds.height * Double.random(in: 0...1)
        let backgroundCellView = UIView(frame: CGRect(
            x: 0,
            y: collectionView.bounds.height - cellHeight,
            width: 40,
            height: cellHeight
        ))
        let paceText = UILabel.init(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        paceText.text = "\(Int(cellHeight))"
        paceText.font = UIFont.systemFont(ofSize: 10)
        paceText.textAlignment = .center
        backgroundCellView.backgroundColor = .yellow
        cell.contentView.addSubview(backgroundCellView)
        cell.contentView.addSubview(paceText)

        return cell
    }
    
}
