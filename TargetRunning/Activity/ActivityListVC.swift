//
//  ActivityListVC.swift
//  TargetRunning
//
//  Created by Константин Андреев on 26.05.2022.
//

import UIKit
import CoreData

class ActivityListVC: UITableViewController {
    private var activities = [Activity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewController = segue.destination as? ActivityVC else { return }
        if let indexPath = tableView.indexPathForSelectedRow?.row {
            viewController.activity = activities[indexPath]
        }
    }
    
    private func fetchData() {
        let fetchRequest = Activity.fetchRequest()
        do {
            fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "date", ascending: false)]
            activities = try StorageManager.shared.persistentContainer.viewContext.fetch(fetchRequest)
        } catch let error {
            print("Failed to fetch data", error)
        }
    }
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        activities.count
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchData()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let activity = activities[indexPath.row]
        let distance = String(format: "%0.2f", (activity.distance / 1000))
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let time = getTimeString(from: Int(activity.time))
        let avgPaceDistance = getTimeString(from: Int(activity.avgPace))
        
        content.text = distance + "km in " + time + ", " + avgPaceDistance + " /km"
        if let date = activity.date {
            content.secondaryText = dateFormatter.string(from: date)
        }
        cell.contentConfiguration = content
        
        return cell
    }
    
    private func getTimeString(from seconds: Int) -> String {
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
