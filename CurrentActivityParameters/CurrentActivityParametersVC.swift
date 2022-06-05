//
//  TextParametersViewController.swift
//  TargetRunning
//
//  Created by Константин Андреев on 23.05.2022.
//

import UIKit
import MapKit

class CurrentActivityParametersVC: UIViewController {

    @IBOutlet var mainButton: UIButton!
    @IBOutlet var topLeftButton: UIButton!
    @IBOutlet var topCenterButton: UIButton!
    @IBOutlet var topRightButton: UIButton!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var paramView: UIView!
    @IBOutlet var mapButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var paramViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var paramViewTrailingConstraint: NSLayoutConstraint!
    
    var viewModel: CurrentActivityParametersProtocol!
    private var paramIsHide = false
    private var isAnimated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        setupButtonsUI()
        
        viewModel.time.bind { [weak self]_ in
            self?.setTime()
            self?.setDistance()
            self?.setAvgDistancePace()
            self?.setSplitPace()
        }
        
        viewModel.lineCoordinates.bind { [weak self] coordinates in
            self?.drawRoute(with: coordinates)
        }
    }
    
    @IBAction func mapButtomTapped(_ sender: Any) {
        if isAnimated {
            return
        }
        isAnimated = true
        if paramIsHide {
            paramViewLeadingConstraint.constant += paramView.frame.width
            paramViewTrailingConstraint.constant += paramView.frame.width
        } else {
            paramViewLeadingConstraint.constant -= paramView.frame.width
            paramViewTrailingConstraint.constant -= paramView.frame.width
            viewModel.setMapCenter(for: mapView)
        }
        UIView.animate(withDuration: 0.4, delay: 0, options: [.allowAnimatedContent]) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.paramIsHide.toggle()
            self.isAnimated = false
        }
    }
    
    private func setupButtonsUI() {
        
        startButton.layer.cornerRadius = startButton.frame.height / 2
        startButton.layer.backgroundColor = UIColor.brown.cgColor
        startButton.layer.shadowColor = UIColor.black.cgColor
        startButton.layer.shadowOpacity = 0.7
        startButton.layer.shadowOffset = CGSize(width: 0.0, height: 3)
        
        mapButton.layer.cornerRadius = mapButton.frame.height / 2
        mapButton.layer.backgroundColor = UIColor.brown.cgColor
        mapButton.layer.shadowColor = UIColor.black.cgColor
        mapButton.layer.shadowOpacity = 0.7
        mapButton.layer.shadowOffset = CGSize(width: 0.0, height: 3)
        
        if !paramIsHide {
            mapButton.tintColor = .lightGray
        } else {
            mapButton.tintColor = .systemBlue
        }
    }
    
    private func setTime() {
        topLeftButton.setTitle(viewModel.timeString, for: .normal)
    }
    
    private func setDistance() {
        mainButton.setTitle(viewModel.distanceString, for: .normal)
    }
    
    private func setAvgDistancePace() {
        topCenterButton.setTitle(viewModel.avgPaceDistanceString, for: .normal)
    }
    
    private func setSplitPace() {
        topRightButton.setTitle(viewModel.paceSegmentString, for: .normal)
    }
    
    private func drawRoute(with coordinates: [CLLocationCoordinate2D]) { 
        let line = viewModel.getMKPolyline(with: coordinates)
        mapView.addOverlay(line)
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        viewModel.startButtonPressed { title in
            startButton.setTitle(title, for: .normal)
        }
    }
}

//MARK: - MKMapViewDelegate
extension CurrentActivityParametersVC: MKMapViewDelegate {
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
