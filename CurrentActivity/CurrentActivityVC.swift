//
//  TextParametersViewController.swift
//  TargetRunning
//
//  Created by Константин Андреев on 23.05.2022.
//

import UIKit
import MapKit

class CurrentActivityVC: UIViewController {

    @IBOutlet var mainButton: UIButton!
    @IBOutlet var topLeftButton: UIButton!
    @IBOutlet var topCenterButton: UIButton!
    @IBOutlet var topRightButton: UIButton!
    @IBOutlet var finishButton: UIButton!
    @IBOutlet var paramView: UIView!
    @IBOutlet var mapButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var stopResumeButton: UIButton!
    
    @IBOutlet var paramViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var paramViewTrailingConstraint: NSLayoutConstraint!
    
    var viewModel: CurrentActivityProtocol!
    private var circleProgressBar: CircleProgressBar!
    private var paramIsHide = false
    private var isAnimated = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        setupButtonsUI()
        
        viewModel.time.bind { _ in
            self.setTime()
            self.setDistance()
            self.setAvgDistancePace()
            self.setSplitPace()
        }
        
        viewModel.lineCoordinates.bind { coordinates in
            self.drawRoute(with: coordinates)
        }
        createCircleProgressBar()
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
        
        finishButton.layer.cornerRadius = finishButton.frame.height / 2
        finishButton.layer.backgroundColor = UIColor.brown.cgColor
        finishButton.layer.shadowColor = UIColor.black.cgColor
        finishButton.layer.shadowOpacity = 0.7
        finishButton.layer.shadowOffset = CGSize(width: 0.0, height: 3)
        
        stopResumeButton.layer.cornerRadius = finishButton.frame.height / 2
        stopResumeButton.layer.backgroundColor = UIColor.brown.cgColor
        stopResumeButton.layer.shadowColor = UIColor.black.cgColor
        stopResumeButton.layer.shadowOpacity = 0.7
        stopResumeButton.layer.shadowOffset = CGSize(width: 0.0, height: 3)
        
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
    
    private func createCircleProgressBar() {
        circleProgressBar = CircleProgressBar(
            frame: CGRect(x: 0, y: 0, width: view.frame.width - 20, height: view.frame.width - 20)
        )
        circleProgressBar.center = view.center
        view.addSubview(circleProgressBar)
    }
    
    @IBAction func finishButtonPressed(_ sender: UIButton) {
        viewModel.startButtonPressed { title in
            finishButton.setTitle(title, for: .normal)
        }
    }
    @IBAction func stopResumeButtonPressed() {
        circleProgressBar.increaseProgressValue(for: 0.01)
    }
}

//MARK: - MKMapViewDelegate
extension CurrentActivityVC: MKMapViewDelegate {
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
