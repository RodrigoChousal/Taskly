//
//  RoutineDetailTableViewController.swift
//  Taskly
//
//  Created by Development on 8/16/16.
//  Copyright © 2016 Rodrigo Chousal. All rights reserved.
//

import UIKit

class RoutineDetailTableViewController: UITableViewController, UITextFieldDelegate {
    
    var primaryCount: Int = 0
    
    var newRoutine: Routine?
    
    var temporaryName: String?
    
    var inEdit: Bool = false
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var timeCell: UITableViewCell!
    @IBOutlet weak var repeatCell: UITableViewCell!
    @IBOutlet weak var remindCell: UITableViewCell!
    
    @IBOutlet weak var remindSwitch: UISwitch!
    
    @IBOutlet weak var remindTimePicker: UIDatePicker!
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.delegate = self
        
        initialPrep()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkForChanges()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        nameField.resignFirstResponder()
    }
    
    func initialPrep() {
        
        remindCell.accessoryView = remindSwitch
        saveButton.isEnabled = false
        
        if inEdit {
            navigationItem.title = newRoutine?.name
            nameField.text = newRoutine?.name
            timeCell.detailTextLabel?.text = newRoutine?.timeOfDay
            repeatCell.detailTextLabel?.text = newRoutine?.reps
            
            if newRoutine?.remind != 0 {
                remindSwitch.setOn(true, animated: true)
                remindSwitch.addTarget(self, action: #selector(self.switchValueChanged), for: UIControlEvents.valueChanged)
                remindTimePicker.alpha = 1.0
                remindTimePicker.countDownDuration = (newRoutine?.remind)! as TimeInterval
            }
        }
    }
    
    func checkForChanges() {
        
        if !inEdit {
            
            nameField.text = temporaryName ?? ""
            
        } else if newRoutine?.name != nameField.text || newRoutine?.timeOfDay != timeCell.detailTextLabel?.text || newRoutine?.reps != repeatCell.detailTextLabel?.text || newRoutine?.remind != remindTimePicker.countDownDuration as Double {
            saveButton.isEnabled = true
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: nameField, queue: OperationQueue.main) { (notification) in
            self.saveButton.isEnabled = self.nameField.text != ""
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            nameField.becomeFirstResponder()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.characters.count ?? 0
        
        if range.length + range.location > currentCharacterCount {
            return false
        }
        
        let newLength = currentCharacterCount + string.characters.count - range.length
        
        return newLength <= 40
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveSegue" && nameField.text! != "" {
            
            let name = nameField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let time = DayTime(rawValue: (timeCell.detailTextLabel?.text)!)!

            if inEdit {
                // Edit routine
                newRoutine = Routine(name: name, timeOfDay: time, id: primaryCount)
                
            } else {
                // New routine
                newRoutine = Routine(name: name, timeOfDay: time, id: primaryCount + 1)
            }
            
            if remindSwitch.isOn {
                newRoutine?.remind = remindTimePicker.countDownDuration as Double
            } else {
                newRoutine?.remind = 0.0
            }
            
            newRoutine?.reps = (repeatCell.detailTextLabel?.text)! as String
            
        } else if segue.identifier == "changeRoutineTime" {
            
            // Save nameField changes
            temporaryName = nameField.text!

            let destinationVC = segue.destination as! RoutineTimeTableViewController
            
            switch (timeCell.detailTextLabel?.text)! {
                case "Morning": destinationVC.lastSelectedIndexPath = IndexPath(row: 0, section: 0)
                case "Afternoon": destinationVC.lastSelectedIndexPath = IndexPath(row: 1, section: 0)
                case "Evening": destinationVC.lastSelectedIndexPath = IndexPath(row: 2, section: 0)
                case "None": destinationVC.lastSelectedIndexPath = IndexPath(row: 3, section: 0)
                
                default: print("Error! Unknown time found!") // Create error?
            }
        } else if segue.identifier == "changeRoutineRep" {
            let destinationVC = segue.destination as! RepeatRoutineTableViewController
            
            switch (repeatCell.detailTextLabel?.text)! {
                case "Every Day": destinationVC.lastSelectedIndexPath = IndexPath(row: 0, section: 0)
                case "Every Week": destinationVC.lastSelectedIndexPath = IndexPath(row: 1, section: 0)
                case "Every Month": destinationVC.lastSelectedIndexPath = IndexPath(row: 2, section: 0)
            
                default: print("Error! Unknown repetition found!") // Create error?
            }
        }
        
    }
    
    @IBAction func saveAction(_ sender: AnyObject?) {
    }
    
    @IBAction func cancelAction(_ sender: AnyObject?) {
        // Resets properties
        newRoutine = Routine(name: "", timeOfDay: .None, id: 0)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func remindAction(_ sender: AnyObject) {
        if remindSwitch.isOn == true {
            nameField.resignFirstResponder()
            remindTimePicker.alpha = 1.0
            remindTimePicker.becomeFirstResponder()
        } else {
            remindTimePicker.alpha = 0.0
        }
    }
    
    @IBAction func pickerDidChange(_ sender: AnyObject) {
        if inEdit {
            self.saveButton.isEnabled = true
        }
    }
    
    func switchValueChanged() {
        if inEdit {
            self.saveButton.isEnabled = true
        }
    }
}
