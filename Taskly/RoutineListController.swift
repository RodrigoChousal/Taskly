//
//  RoutineListController.swift
//  Taskly
//
//  Created by Development on 7/11/16.
//  Copyright © 2016 Rodrigo Chousal. All rights reserved.
//

import UIKit
import RealmSwift

class RoutineListController: UITableViewController {
    
    let realm = try! Realm()
    
    var allRoutines: [[Routine]] = [[]]
    var queriedRoutines: [Routine] = []
    
    var headers = [String](count: 4, repeatedValue: "")
    
    var selectedRoutine: String = ""
 
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadRoutines()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if allRoutines[section].isEmpty {
            return nil
        } else {
            return headers[section]
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return headers.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allRoutines[section].isEmpty {
            return 0
        } else {
            return allRoutines[section].count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RoutineCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = allRoutines[indexPath.section][indexPath.row].name
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        selectedRoutine = allRoutines[indexPath.section][indexPath.row].name
        return indexPath
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            try! realm.write {
                realm.delete(allRoutines[indexPath.section][indexPath.row])
            }
            allRoutines[indexPath.section].removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        }
        
        loadRoutines()
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
        if segue.identifier == "insideRoutine" {
            let destinationVC = segue.destinationViewController as! TaskListController
            destinationVC.routineName = self.selectedRoutine
        }
    }
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func save(segue:UIStoryboardSegue) {
        
        if let routineDetailTVC = segue.sourceViewController as? RoutineDetailTableViewController {
            
            if let routine = routineDetailTVC.newRoutine {
                
                try! self.realm.write {
                    self.realm.add(routine)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.loadRoutines()
                    self.tableView.reloadData()
                })
            }
        }
        
    }
    
    // MARK: - Content Load & Sort
    
    func loadRoutines() {
        let requestedRoutines = realm.objects(Routine.self)
        queriedRoutines = Array(requestedRoutines)
        
        sortRoutines()
    }
    
    func sortRoutines(){
        
        // Temporary arrays used for filtering
        let morningRoutines = Array(realm.objects(Routine.self).filter("timeOfDay = 'Morning'"))
        let afternoonRoutines = Array(realm.objects(Routine.self).filter("timeOfDay = 'Afternoon'"))
        let eveningRoutines = Array(realm.objects(Routine.self).filter("timeOfDay = 'Evening'"))
        let noTimeRoutines = Array(realm.objects(Routine.self).filter("timeOfDay = 'None'"))
        
        // Checks if a section should be created
        if morningRoutines.count != 0 {
            headers.removeAtIndex(0)
            headers.insert(morningRoutines[0].timeOfDay, atIndex: 0)
        }
        
        if afternoonRoutines.count != 0 {
            headers.removeAtIndex(1)
            headers.insert(afternoonRoutines[0].timeOfDay, atIndex: 1)
        }
        
        if eveningRoutines.count != 0 {
            headers.removeAtIndex(2)
            headers.insert(eveningRoutines[0].timeOfDay, atIndex: 2)
        }
        
        if noTimeRoutines.count != 0 {
            headers.removeAtIndex(3)
            headers.insert(noTimeRoutines[0].timeOfDay, atIndex: 3)
        }
        
        // Clean slate
        allRoutines.removeAll()
        
        // Repopulate
        allRoutines.append(morningRoutines)
        allRoutines.append(afternoonRoutines)
        allRoutines.append(eveningRoutines)
        allRoutines.append(noTimeRoutines)
        
        }
}
