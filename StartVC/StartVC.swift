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
    
    lazy var startButton: UIButton = {
        let startButton = UIButton()
        let buttonConfiguratin = startButton.configuration
        let buttonSide = 80.0
        startButton.heightAnchor.constraint(equalToConstant: buttonSide).isActive = true
        startButton.widthAnchor.constraint(equalToConstant: buttonSide).isActive = true
        startButton.layer.cornerRadius = buttonSide / 2
        startButton.setTitle("Start", for: .normal)
        
        startButton.layer.backgroundColor = UIColor.brown.cgColor
        startButton.layer.shadowColor = UIColor.black.cgColor
        startButton.layer.shadowOpacity = 0.7
        startButton.layer.shadowOffset = CGSize(width: 0.0, height: 3)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        return startButton
    }()
    
    lazy var goalButton: UIButton = {
        let startButton = UIButton()
        let buttonConfiguratin = startButton.configuration
        startButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        startButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        startButton.layer.cornerRadius = 8
        startButton.setTitle("set goal", for: .normal)
        
        startButton.layer.backgroundColor = UIColor.brown.cgColor

        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.addTarget(self, action: #selector(goalButtonTapped), for: .touchUpInside)
        return startButton
    }()
    
    lazy var toolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        toolBar.tintColor = .black
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
        viewModel = StartViewModel()
        viewModel.runGoal.bind { runGoal in
            switch self.viewModel.runGoal.value {
                case .Distance:
                    self.goalValueButton.setTitle("00,00", for: .normal)
                    self.goalValueButton.configuration?.subtitle = "kilometers"
                    self.goalButton.setTitle("distance", for: .normal)
                case .Time:
                    self.goalValueButton.setTitle("00:00", for: .normal)
                    self.goalValueButton.configuration?.subtitle = "hourse:minutes"
                    self.goalButton.setTitle("time", for: .normal)
            }
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
        
        setConstraints()
    }
    
    @IBAction func goalValueButtonTapped(_ sender: Any) {
        goalTextField.becomeFirstResponder()
    }
    
    private func fetchData() {
        
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate(
            [
                startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                goalButton.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -20),
                goalButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ]
        )
    }
    
    @objc private func goalButtonTapped(){
        goalPickerView.selectRow(0, inComponent: 0, animated: true)
        goalPickerView.selectRow(0, inComponent: 1, animated: true)
        present(viewModel.showTargetList(), animated: true)
    }
    
    @objc private func startButtonTapped() {
        if let wrongGoalAlert = viewModel.startButtonTapped() {
            present(wrongGoalAlert, animated: true)
        }
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "currentActivity") as? CurrentActivityVC else { return }
        vc.modalPresentationStyle = .fullScreen
        vc.viewModel =  CurrentActivityViewModel(startParametes: viewModel.getStartParameters())
        present(vc, animated: true)
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
                    case 1: return "\(viewModel.distancePickerData[component][row] * 100) m"
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
