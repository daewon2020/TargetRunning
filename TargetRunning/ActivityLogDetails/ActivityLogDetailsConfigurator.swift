//
//  ActivityLogDetailsConfigurator.swift
//  TargetRunning
//
//  Created by Константин Андреев on 26.06.2022.
//

import Foundation

protocol ActivityLogDetailsConfiguratorProtocol {
    func configure(with viewController: ActivityLogDetailsVC, and activity: Activity)
}

class ActivityLogDetailsConfigurator: ActivityLogDetailsConfiguratorProtocol {
    func configure(with viewController: ActivityLogDetailsVC, and activity: Activity) {
        let presenter = ActivityLogDetailsPresenter(view: viewController)
        let interactor = ActivityLogDetailsInteractor(presenter: presenter, activity: activity)
        
        viewController.presenter = presenter
        presenter.interactor = interactor
    }
}
