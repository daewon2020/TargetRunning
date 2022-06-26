//
//  ActivityListVC.swift
//  TargetRunning
//
//  Created by Константин Андреев on 26.05.2022.
//

import UIKit
import CoreData

protocol ActivityListViewInputProtocol: AnyObject {
    func reloadData(with activities: [Activity])
}

protocol ActivityListViewOutputProtocol: AnyObject {
    init(view: ActivityListViewInputProtocol)
    func viewDidLoad()
    func didTapCell(for activity: Activity)
    func getTimeString(from seconds: Int) -> String 
}

class ActivityListVC: UITableViewController {
    
    var presenter: ActivityListViewOutputProtocol!
    private var activities = [Activity]()
    private let configurator = ActivityLlistConfigurator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurator.configure(with: self)
        presenter.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewController = segue.destination as? ActivityLogDetailsVC else { return }
        let configurator = ActivityLogDetailsConfigurator()
        guard let activity = sender as? Activity  else { return }
        configurator.configure(with: viewController, and: activity)
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        activities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let activity = activities[indexPath.row]
        let distance = String(format: "%0.2f", (activity.distance / 1000))
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let time = presenter.getTimeString(from: Int(activity.time))
        let avgPaceDistance = presenter.getTimeString(from: Int(activity.avgPace))
        
        content.text = distance + "km in " + time + ", " + avgPaceDistance + " /km"
        if let date = activity.date {
            content.secondaryText = dateFormatter.string(from: date)
        }
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didTapCell(for: activities[indexPath.row])
    }
}

// MARK: - ActivityListViewInputProtocol
extension ActivityListVC: ActivityListViewInputProtocol {
    func reloadData(with activities: [Activity]) {
        self.activities = activities
        tableView.reloadData()
    }
}
