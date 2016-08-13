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
        
        // BEGIN TESTING DUMMY OBJECTS
        
        let routine1 = Routine(name: "Morning", timeOfDay: .Morning)
        let routine2 = Routine(name: "Skills", timeOfDay: .Afternoon)
        let routine3 = Routine(name: "News", timeOfDay: .Evening)
        let routine4 = Routine(name: "Email", timeOfDay: .Morning)
        
        try! realm.write {
            realm.add(routine1)
            realm.add(routine2)
            realm.add(routine3)
            realm.add(routine4)
        }
        
        // END TESTING
        
        loadRoutines()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headers[section]
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return allRoutines.count - 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allRoutines[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RoutineCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = allRoutines[indexPath.section][indexPath.row].name

        return cell
    }

    // Override to support conditional editing of the table view.
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
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
    
    // MARK: - Content Load & Sort
    
    func loadRoutines() {
        let requestedRoutines = realm.objects(Routine.self)
        queriedRoutines = Array(requestedRoutines)
        
        sortRoutines()
    }
    
    func sortRoutines(){
        
        var morningRoutines: [Routine] = []
        var afternoonRoutines: [Routine] = []
        var eveningRoutines: [Routine] = []
        var noTimeRoutines: [Routine] = []
        
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
        
        allRoutines.removeAll()
        
        allRoutines.append(morningRoutines)
        allRoutines.append(afternoonRoutines)
        allRoutines.append(eveningRoutines)
        allRoutines.append(noTimeRoutines)
    }
}





