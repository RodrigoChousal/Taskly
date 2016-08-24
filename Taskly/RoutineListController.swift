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
    
    var headers: [String] = []
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadRoutines()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
        return allRoutines[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RoutineCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = allRoutines[indexPath.section][indexPath.row].name

        return cell
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
        
        // Temporary arrays used for sorting queried routines
        var morningRoutines: [Routine] = []
        var afternoonRoutines: [Routine] = []
        var eveningRoutines: [Routine] = []
        var noTimeRoutines: [Routine] = []
        
        // Going through queried routines and sorting, also creating necessary section headers: oops. func doing more than 1 thing
        for routine in queriedRoutines {
            switch routine.timeOfDay {
                case "Morning":
                    morningRoutines.append(routine)
                    if !headers.contains(routine.timeOfDay) {
                        headers.append(routine.timeOfDay)
                    }
                case "Afternoon":
                    afternoonRoutines.append(routine)
                    if !headers.contains(routine.timeOfDay) {
                        headers.append(routine.timeOfDay)
                    }
                case "Evening":
                    eveningRoutines.append(routine)
                    if !headers.contains(routine.timeOfDay) {
                        headers.append(routine.timeOfDay)
                    }
                default:
                    noTimeRoutines.append(routine)
                    if !headers.contains(routine.timeOfDay) {
                        headers.append(routine.timeOfDay)
                    }
            }
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
