//
//  ActivityListInteractor.swift
//  TargetRunning
//
//  Created by Константин Андреев on 22.06.2022.
//

import Foundation
import CoreData

protocol ActivityListInteractorOutputProtocol: AnyObject {
    func activityListDidRecieve(_ activities: [Activity])
}

protocol ActivityListInteractorInputProtocol: AnyObject {
    init (presenter: ActivityListInteractorOutputProtocol)
    func fetchActivityList()
}

class ActivityListInteractor: ActivityListInteractorInputProtocol {
    unowned let presenter: ActivityListInteractorOutputProtocol
    
    required init(presenter: ActivityListInteractorOutputProtocol) {
        self.presenter = presenter
    }
    
    func fetchActivityList() {
        let fetchRequest = Activity.fetchRequest()
        do {
            fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "date", ascending: false)]
            let activities = try StorageManager.shared.persistentContainer.viewContext.fetch(fetchRequest)
            self.presenter.activityListDidRecieve(activities)
        } catch let error {
            print("Failed to fetch data", error)
        }
    }
}
