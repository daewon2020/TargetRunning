//
//  ActivityLogTableViewCell.swift
//  TargetRunning
//
//  Created by Константин Андреев on 27.06.2022.
//

import UIKit

class ActivityLogTableViewCell: UITableViewCell {
    var viewModel: ActivityLogCellViewModel? {
        didSet {
            updateView()
        }
    }
    
    private func updateView() {
        guard let viewModel = viewModel else { return }
        var content = defaultContentConfiguration()
        content.text = viewModel.paramName
        content.secondaryText = viewModel.paramValue
        contentConfiguration = content
    }
}
