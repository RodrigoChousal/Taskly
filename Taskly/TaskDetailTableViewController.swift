//
//  TaskDetailTableViewController.swift
//  Taskly
//
//  Created by Development on 8/31/16.
//  Copyright © 2016 Rodrigo Chousal. All rights reserved.
//

import UIKit

class TaskDetailTableViewController: UITableViewController {
    
    var name: String?
    var desc: String?
    var time: Double = 0.0
    var on: Bool = true
    
    var newTask: Task?

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var nameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.becomeFirstResponder()
        
        // Disables while field is empty
        saveButton.enabled = false
        NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: nameField, queue: NSOperationQueue.mainQueue()) { (notification) in
            self.saveButton.enabled = self.nameField.text != ""
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            nameField.becomeFirstResponder()
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "saveSegue" && nameField.text! != "" {
            newTask = Task(name: nameField.text!, desc: "oh si", length: 0)
            
        }
    }

}






