//
//  RoutineTimeTableViewController.swift
//  Taskly
//
//  Created by Development on 8/18/16.
//  Copyright © 2016 Rodrigo Chousal. All rights reserved.
//

import UIKit

class RoutineTimeTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    var lastSelectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    let categories = ["Morning", "Afternoon", "Evening", "None"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "categoryCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if let controller = viewController as? RoutineDetailTableViewController {
            controller.timeCell.detailTextLabel?.text = categories[lastSelectedIndexPath.row]
            controller.time = DayTime(rawValue: categories[lastSelectedIndexPath.row])!
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("categoryCell", forIndexPath: indexPath) as UITableViewCell
        cell.accessoryType = (lastSelectedIndexPath.row == indexPath.row) ? .Checkmark : .None
        cell.textLabel?.text = categories[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row != lastSelectedIndexPath.row {
            let oldCell = tableView.cellForRowAtIndexPath(lastSelectedIndexPath)
            oldCell?.accessoryType = .None
            
            let newCell = tableView.cellForRowAtIndexPath(indexPath)
            newCell?.accessoryType = .Checkmark
            
            lastSelectedIndexPath = indexPath
        }
    }

}
