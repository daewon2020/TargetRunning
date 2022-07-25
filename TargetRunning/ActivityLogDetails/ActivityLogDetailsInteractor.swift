//
//  ActivityLogDetailsInteractor.swift
//  TargetRunning
//
//  Created by Константин Андреев on 26.06.2022.
//

import Foundation

protocol ActivityLogDetailsInteractorInputProtocol: AnyObject {
    init(presenter: ActivityLogDetailsInteractorOutputProtocol, activity: Activity)
    func fetchActivityData()
}

protocol ActivityLogDetailsInteractorOutputProtocol: AnyObject {
    func routeDidRecieve(route: [RouteCoordinate])
    func activityDidRecieve(activity: Activity)
    func paceDidRecieve(pace: [Pace])
}

class ActivityLogDetailsInteractor: ActivityLogDetailsInteractorInputProtocol {
    unowned let presenter: ActivityLogDetailsInteractorOutputProtocol
    private var activity: Activity
    
    required init(presenter: ActivityLogDetailsInteractorOutputProtocol, activity: Activity) {
        self.presenter = presenter
        self.activity = activity
    }
 
    func fetchActivityData() {
        fetchRoute()
        fetchPace()
        presenter.activityDidRecieve(activity: activity)
    }
    
    private func fetchPace() {
        let request = Pace.fetchRequest()
        request.predicate = NSPredicate(format: "ANY activity = %@", activity)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        do {
            let pace = try StorageManager.shared.persistentContainer.viewContext.fetch(request)
            presenter.paceDidRecieve(pace: pace)
        } catch let error {
            print("Failed to fetch data", error)
        }
    }
    
    private func fetchRoute() {
        let request = RouteCoordinate.fetchRequest()
        request.predicate = NSPredicate(format: "ANY activity = %@", activity)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        do {
            let route = try StorageManager.shared.persistentContainer.viewContext.fetch(request)
            presenter.routeDidRecieve(route: route)
        } catch let error {
            print("Failed to fetch data", error)
        }
    }
}
