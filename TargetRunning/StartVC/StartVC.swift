//
//  StartVC.swift
//  TargetRunning
//
//  Created by Константин Андреев on 31.05.2022.
//

import UIKit

class StartVC: UIViewController {

    @IBOutlet var goalTextField: UITextField!
    @IBOutlet var goalValueButton: UIButton!
    @IBOutlet var weatherIcon: UIImageView!
    @IBOutlet var tempetatureLabel: UILabel!
    @IBOutlet var weatherDescriptionLabel: UILabel!
    @IBOutlet var locationName: UILabel!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var weatherStackView: UIStackView!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var goalButton: UIButton!
    
    lazy var toolBar: UIToolbar = {
        let toolBar = UIToolbar()
        
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        let cancelButton = UIBarButtonItem(
            title: "Cancel",
            style: .done,
            target: self,
            action: #selector(cancelTabBarButtonTapped)
        )
        
        let space = UIBarButtonItem(systemItem: .flexibleSpace)
        
        let setButton = UIBarButtonItem(
            title: "Set",
            style: .done,
            target: self,
            action: #selector(setTabBarButtonTapped)
        )
        
        toolBar.setItems([cancelButton,space,setButton], animated: true)
        
        return toolBar
    }()
    
    lazy var goalPickerView: UIPickerView = {
        let goalPickerView = UIPickerView()
        
        return goalPickerView
    }()
    
    private var viewModel: StartViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator.startAnimating()
        
        viewModel = StartViewModel()
        viewModel.runGoal.bind { runGoal in
            switch self.viewModel.runGoal.value {
                case .Distance:
                    self.goalValueButton.setTitle("00,0", for: .normal)
                    self.goalValueButton.configuration?.subtitle = "kilometers"
                    self.goalButton.setTitle("Distance", for: .normal)
                case .Time:
                    self.goalValueButton.setTitle("00:00", for: .normal)
                    self.goalValueButton.configuration?.subtitle = "hourse:minutes"
                    self.goalButton.setTitle("Time", for: .normal)
            }
        }
        
        viewModel.weather.bind { weather in
            self.setWeatherData(with: weather)
        }
        
        viewModel.weatherIcon.bind { image in
            guard let image = image else { return }
            self.setWeatherIcon(with: image)
        }
        
        goalValueButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer({ inConf in
            var outConf = inConf
            outConf.font = UIFont.systemFont(ofSize: 70)
            return outConf
        })
        
        goalTextField.inputAccessoryView = toolBar
        goalTextField.inputView = goalPickerView
        
        goalPickerView.dataSource = self
        goalPickerView.delegate = self
        
        view.addSubview(startButton)
        view.addSubview(goalButton)
        
    }
    
    @IBAction func goalValueButtonTapped(_ sender: Any) {
        goalTextField.becomeFirstResponder()
    }

    private func setWeatherData(with weather: Weather) {
        weatherDescriptionLabel.text = viewModel.weatherDescription
        tempetatureLabel.text = viewModel.temperature
        locationName.text = viewModel.weatherLocationName
    }
    
    private func setWeatherIcon(with image: UIImage) {
        weatherIcon.image = image
        loadingIndicator.stopAnimating()
        weatherStackView.isHidden = false
    }
    
    @objc private func setTabBarButtonTapped() {
        viewModel.setGoalValue(
            for: goalPickerView.selectedRow(inComponent: 0),
            and: goalPickerView.selectedRow(inComponent: 1)
        ) { goalValueString in
            self.goalValueButton.setTitle(goalValueString, for: .normal)
        }
        
        goalTextField.resignFirstResponder()
    }
    
    @objc private func cancelTabBarButtonTapped() {
        goalTextField.resignFirstResponder()
    }
    
    @IBAction func startButtonTapped() {
        if let wrongGoalAlert = viewModel.startButtonTapped() {
            present(wrongGoalAlert, animated: true)
        }
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "currentActivity") as? CurrentActivityVC else { return }
        vc.modalPresentationStyle = .fullScreen
        vc.viewModel =  CurrentActivityViewModel(startParametes: viewModel.getStartParameters())
        present(vc, animated: true)
    }
    
    @IBAction func goalButtonTapped() {
        goalPickerView.selectRow(0, inComponent: 0, animated: true)
        goalPickerView.selectRow(0, inComponent: 1, animated: true)
        present(viewModel.showTargetList(), animated: true)
    }
    
    
}

// MARK: - DatePicker Delegate and DataSource
extension StartVC: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch viewModel.runGoal.value {
            case .Distance:
                return viewModel.distancePickerData.count
            case .Time:
                return viewModel.timePickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch viewModel.runGoal.value {
            case .Distance:
                return viewModel.distancePickerData[component].count
            case .Time:
                return viewModel.timePickerData[component].count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch viewModel.runGoal.value {
            case .Distance:
                switch component {
                    case 0: return "\(viewModel.distancePickerData[component][row]) km"
                    case 1: return "\(viewModel.distancePickerData[component][row]) m"
                    default: return nil
                }
            case .Time:
                switch component {
                    case 0: return "\(viewModel.timePickerData[component][row]) hourse"
                    case 1: return "\(viewModel.timePickerData[component][row]) min"
                    default: return nil
                }
        }
    }
}
