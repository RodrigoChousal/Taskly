//
//  RoutineDetailTableViewController.swift
//  Taskly
//
//  Created by Development on 8/16/16.
//  Copyright © 2016 Rodrigo Chousal. All rights reserved.
//

import UIKit

class RoutineDetailTableViewController: UITableViewController {

    var name: String?
    var time: DayTime = .None
    var willRepeat: String = ""
    var willRemind: Bool = false
    
    var newRoutine: Routine?
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var timeCell: UITableViewCell!
    @IBOutlet weak var repeatCell: UITableViewCell!
    @IBOutlet weak var remindCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disables while field is empty
        saveButton.enabled = false
        NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: nameField, queue: NSOperationQueue.mainQueue()) { (notification) in
            self.saveButton.enabled = self.nameField.text != ""
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "saveSegue" && nameField.text! != "" {
            newRoutine = Routine(name: nameField.text!, timeOfDay: time)
            
        } else if segue.identifier == "changeRoutineTime" {
            let destinationVC = segue.destinationViewController as! RoutineTimeTableViewController
            switch (timeCell.detailTextLabel?.text)! {
                case "Morning": destinationVC.lastSelectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                case "Afternoon": destinationVC.lastSelectedIndexPath = NSIndexPath(forRow: 1, inSection: 0)
                case "Evening": destinationVC.lastSelectedIndexPath = NSIndexPath(forRow: 2, inSection: 0)
                case "None": destinationVC.lastSelectedIndexPath = NSIndexPath(forRow: 3, inSection: 0)
            default: print("Error! Unknown time found!") // Create error?
            }
        } else if segue.identifier == "changeRoutineRep" {
            let destinationVC = segue.destinationViewController as! RepeatRoutineTableViewController
            switch (repeatCell.detailTextLabel?.text)! {
                case "Every Day": destinationVC.lastSelectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                case "Every Week": destinationVC.lastSelectedIndexPath = NSIndexPath(forRow: 1, inSection: 0)
                case "Every Month": destinationVC.lastSelectedIndexPath = NSIndexPath(forRow: 2, inSection: 0)
            default: print("Error! Unknown repetition found!") // Create error?
            }
        }

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            nameField.becomeFirstResponder()
        }
    }
    
    @IBAction func saveAction(sender: AnyObject?) {

    }
    
    @IBAction func cancelAction(sender: AnyObject?) {
        
    }

}
