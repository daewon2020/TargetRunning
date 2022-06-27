//
//  ActivityLogCellViewModel.swift
//  TargetRunning
//
//  Created by Константин Андреев on 27.06.2022.
//

import Foundation

class ActivityLogCellViewModel {
    let paramName: String
    let paramValue: String
    let cellID = "activityLogCellID"
    let cellHeight = 80
    
    init(paramName: String, paramValue: String) {
        self.paramName = paramName
        self.paramValue = paramValue
    }
}
