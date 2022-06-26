//
//  ActivityListRouter.swift
//  TargetRunning
//
//  Created by Константин Андреев on 22.06.2022.
//

import Foundation

protocol ActivityListRouterInputProtocol {
    init(viewController: ActivityListVC)
    func openActivityDetailsVC(with activity: Activity)
}

class ActivityListRouter: ActivityListRouterInputProtocol {
    unowned let viewController: ActivityListVC
    required init(viewController: ActivityListVC) {
        self.viewController = viewController
    }
    
    func openActivityDetailsVC(with activity: Activity) {
        viewController.performSegue(withIdentifier: "activityDetails", sender: activity)
    }
}
