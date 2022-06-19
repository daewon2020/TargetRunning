//
//  CircleProgressBarViewModel.swift
//  TargetRunning
//
//  Created by Константин Андреев on 07.06.2022.
//

import Foundation

protocol CircleProgressBarViewModelProtocol {
    var progressValue: Box<Double> { get }
    func setProgressValue(value: Double)
}

class CircleProgressBarViewModel: CircleProgressBarViewModelProtocol {
    
    var progressValue = Box(value: 0.0)
    
    func setProgressValue(value: Double) {
        progressValue.value = value
    }
}

