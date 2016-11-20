//
//  RoutineTimeTableViewController.swift
//  Taskly
//
//  Created by Development on 8/18/16.
//  Copyright © 2016 Rodrigo Chousal. All rights reserved.
//

import UIKit

class RoutineTimeTableViewController: UITableViewController, UINavigationControllerDelegate { // Podría ser una class con repeat
    
    var lastSelectedIndexPath = IndexPath(row: 0, section: 0)
    let categories = ["Morning", "Afternoon", "Evening", "None"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        navigationController?.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "categoryCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let controller = viewController as? RoutineDetailTableViewController {
            controller.timeCell.detailTextLabel?.text = categories[(lastSelectedIndexPath as NSIndexPath).row]
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as UITableViewCell
        cell.accessoryType = ((lastSelectedIndexPath as NSIndexPath).row == (indexPath as NSIndexPath).row) ? .checkmark : .none
        cell.textLabel?.text = categories[(indexPath as NSIndexPath).row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath as NSIndexPath).row != (lastSelectedIndexPath as NSIndexPath).row {
            let oldCell = tableView.cellForRow(at: lastSelectedIndexPath)
            oldCell?.accessoryType = .none
            
            let newCell = tableView.cellForRow(at: indexPath)
            newCell?.accessoryType = .checkmark
            
            lastSelectedIndexPath = indexPath
        }
    }

}
