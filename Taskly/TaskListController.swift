//
//  TaskListController.swift
//  Taskly
//
//  Created by Development on 8/30/16.
//  Copyright © 2016 Rodrigo Chousal. All rights reserved.
//

import UIKit
import RealmSwift

class TaskListController: UITableViewController {
    
    let realm = try! Realm()
    
    var routineName: String = ""
    var queriedTasks: [Task] = []
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadTasks()
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queriedTasks.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TaskCell", forIndexPath: indexPath)

        cell.textLabel?.text = queriedTasks[indexPath.row].name
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            try! realm.write {
                realm.delete(queriedTasks[indexPath.row])
            }
            
            // Remove item from local storage
            queriedTasks.removeAtIndex(indexPath.row)
            
            // Remove cell from tableView
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        }
        
        loadTasks()
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func save(segue:UIStoryboardSegue) {
        
        if let taskDetailTVC = segue.sourceViewController as? TaskDetailTableViewController {
            
            if let task = taskDetailTVC.newTask {
                
                task.routineName = routineName
                
                try! self.realm.write {
                    self.realm.add(task)
                }
            }
        }
        
    }

    
    func loadTasks() {
        // Query relevant tasks from Realm
        let relevantTasks = Array(realm.objects(Task.self).filter("routineName = '\(routineName)'"))
        
        queriedTasks.removeAll()
        queriedTasks.appendContentsOf(relevantTasks)
    }
}
