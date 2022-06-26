//
//  ActivityListPresenter.swift
//  TargetRunning
//
//  Created by Константин Андреев on 22.06.2022.
//

import Foundation


class ActivityListPresenter: ActivityListViewOutputProtocol {
    
    unowned let view: ActivityListViewInputProtocol
    var interactor: ActivityListInteractorInputProtocol!
    var router: ActivityListRouter!
    
    required init(view: ActivityListViewInputProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
        interactor.fetchActivityList()
    }
    
    func didTapCell(for activity: Activity) {
        router.openActivityDetailsVC(with: activity)
    }
    
    func getTimeString(from seconds: Int) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) / 60 % 60
        let seconds = Int(seconds) % 60
        
        var times: [String] = []
        if hours > 0 {
            times.append(String(format: "%02i", hours))
        }
        if minutes >= 0 {
            times.append(String(format: "%02i", minutes))
        }
        times.append(String(format: "%02i", seconds))
        
        return times.joined(separator: ":")
    }
}

//MARK: - ActivityListInteractorOutputProtocol
extension ActivityListPresenter: ActivityListInteractorOutputProtocol {
    func activityListDidRecieve(_ activities: [Activity]) {
        view.reloadData(with: activities)
    }
}

