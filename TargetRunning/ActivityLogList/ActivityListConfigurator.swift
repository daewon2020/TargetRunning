//
//  ActivityListConfigurator.swift
//  TargetRunning
//
//  Created by Константин Андреев on 22.06.2022.
//

import Foundation

protocol ActivityLlistConfiguratorProtocol {
    func configure(with viewController: ActivityListVC)
}

class ActivityLlistConfigurator: ActivityLlistConfiguratorProtocol {
    func configure(with viewController: ActivityListVC) {
        let presenter = ActivityListPresenter(view: viewController)
        let interactor = ActivityListInteractor(presenter: presenter)
        
        viewController.presenter = presenter
        presenter.interactor = interactor
        
    }
    
    
}
