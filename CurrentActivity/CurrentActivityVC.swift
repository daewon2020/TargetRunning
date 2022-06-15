//
//  TextParametersViewController.swift
//  TargetRunning
//
//  Created by Константин Андреев on 23.05.2022.
//

import UIKit
import MapKit

class CurrentActivityVC: UIViewController {

    @IBOutlet var goalButton: UIButton!
    @IBOutlet var topLeftButton: UIButton!
    @IBOutlet var topCenterButton: UIButton!
    @IBOutlet var topRightButton: UIButton!
    @IBOutlet var finishButton: UIButton!
    @IBOutlet var paramView: UIView!
    @IBOutlet var mapButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var stopResumeButton: UIButton!
    @IBOutlet var goalLabel: UILabel!
    @IBOutlet var goalStackView: UIStackView!
    
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
        createCircleProgressBar()
        
        viewModel.time.bind { _ in
            self.setTimeDistance()
            self.setCounterValue()
            self.setAvgDistancePace()
            self.setSplitPace()
        }
        
        viewModel.lineCoordinates.bind { coordinates in
            self.drawRoute(with: coordinates)
        }
        
        viewModel.startResumeButtonLabel.bind { label in
            self.setStartResumeButtonLabel(label: label)
        }
        
        viewModel.progressValue.bind { value in
            self.circleProgressBar.viewModel.setProgressValue(value: value)
        }
        
        viewModel.startActivity()
        goalLabel.text = viewModel.goalLabel
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
    
    private func setTimeDistance() {
        topLeftButton.setTitle(viewModel.timeDistanceString.value, for: .normal)
        topLeftButton.configuration?.subtitle = viewModel.timeDistanceSubtitle
    }
    
    private func setCounterValue() {
        goalButton.setTitle(viewModel.currentCounterString, for: .normal)
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
            frame: CGRect(
                x: 0,
                y: 0,
                width: paramView.frame.width,
                height: paramView.frame.width
            )
        )
        
        circleProgressBar.center = CGPoint(
            x: paramView.frame.width / 2,
            y: paramView.frame.height / 2
        )
        
        circleProgressBar.viewModel = CircleProgressBarViewModel()
        paramView.addSubview(circleProgressBar)
    }
    
    private func setStartResumeButtonLabel(label: String) {
        stopResumeButton.setTitle(label, for: .normal)
    }
    
    @IBAction func finishButtonPressed(_ sender: UIButton) {
        viewModel.finishButtonPressed()
        dismiss(animated: true)
    }
    
    @IBAction func stopResumeButtonPressed() {
        viewModel.stopResumeButtonPressed()
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
