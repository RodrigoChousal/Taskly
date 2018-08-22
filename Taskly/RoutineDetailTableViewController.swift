//
//  RoutineDetailTableViewController.swift
//  Taskly
//
//  Created by Development on 8/16/16.
//  Copyright © 2016 Rodrigo Chousal. All rights reserved.
//

import UIKit
import RealmSwift

class RoutineDetailTableViewController: UITableViewController, UITextFieldDelegate {
    
    let realm = try! Realm()
    
    // Data management
    var primaryCount: Int = 0
    var newRoutine = Routine()
    var temporaryName: String?
    var inEdit: Bool = false
    
    // Constants
    let tasklyOrange = UIColor(red: 253/255, green: 157/255, blue: 0/255, alpha: 1.0)
    let entireWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    // View management
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var nameCell: UITableViewCell!
    @IBOutlet weak var timeCell: UITableViewCell!
    @IBOutlet weak var repeatCell: UITableViewCell!
    @IBOutlet weak var remindCell: UITableViewCell!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var remindSwitch: UISwitch!
    @IBOutlet weak var remindTimePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()

        nameField.delegate = self
        
        view.setBackground()
        
        drawSeparator(forCell: nameCell)
        drawSeparator(forCell: timeCell)
        drawSeparator(forCell: repeatCell)
        
        //Looks for single or multiple taps
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // If new routine, start from scratch
        if !inEdit {
            newRoutine = Routine(name: "", timeOfDay: .None, reps: [], id: 0)
        }
        
        if UIScreen.main.bounds.size.height == 568 {
            remindTimePicker.frame.size.height = 115
        }
        
        initialPrep()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkForChanges()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        nameField.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        footer.contentView.backgroundColor = UIColor.clear
        footer.textLabel?.textColor = UIColor.white
        footer.alpha = 1.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            nameField.becomeFirstResponder()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Limits character count in name field to 40
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
            let time = DayTime(rawValue: (timeCell.textLabel?.text)!)!
            
            var reps = newRoutine.reps

            if reps.isEmpty {
                reps = entireWeek
            }

            if inEdit {
                // Edit routine
                newRoutine = Routine(name: name, timeOfDay: time, reps: reps, id: primaryCount)
                
            } else {
                // New routine
                newRoutine = Routine(name: name, timeOfDay: time, reps: reps, id: primaryCount + 1)
            }
            
            if remindSwitch.isOn {
                newRoutine.remind = remindTimePicker.countDownDuration as Double
                newRoutine.shouldRemind = true
            } else {
                newRoutine.remind = 0.0
                newRoutine.shouldRemind = false
            }
            
        } else if segue.identifier == "changeRoutineTime" {
                        
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
            // Save nameField changes
            temporaryName = nameField.text!

            let destinationVC = segue.destination as! RoutineTimeTableViewController
            
            switch (timeCell.textLabel?.text)! {
                case "Morning": destinationVC.lastSelectedIndexPath = IndexPath(row: 0, section: 0)
                case "Afternoon": destinationVC.lastSelectedIndexPath = IndexPath(row: 1, section: 0)
                case "Evening": destinationVC.lastSelectedIndexPath = IndexPath(row: 2, section: 0)
                case "None": destinationVC.lastSelectedIndexPath = IndexPath(row: 3, section: 0)
                
                default: print("Error! Unknown time found!") // Create error?
            }
        } else if segue.identifier == "changeRoutineRep" {
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
            // Save nameField changes
            temporaryName = nameField.text!
            
            let destinationVC = segue.destination as! RepeatRoutineTableViewController
            
            if newRoutine.reps.isEmpty {
                destinationVC.selectedCategories = entireWeek
            } else {
                destinationVC.selectedCategories = newRoutine.reps
            }
            
            print("Incoming reps: \(destinationVC.selectedCategories) \n \n")
        }
    }
    
    // MARK: - Actions
    
    @IBAction func saveAction(_ sender: AnyObject?) {
    }
    
    @IBAction func cancelAction(_ sender: AnyObject?) {
        // Resets properties
        newRoutine = Routine(name: "", timeOfDay: .None, reps: [], id: 0)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func remindAction(_ sender: AnyObject) {
        
        let animationDuration = 0.2
        
        if remindSwitch.isOn == true {
            nameField.resignFirstResponder()
            
            remindTimePicker.becomeFirstResponder()
            remindTimePicker.transform = remindTimePicker.transform.scaledBy(x: 0.001, y: 0.001)
            
            UIView.animate(withDuration: animationDuration, animations: { () -> Void in
                self.remindTimePicker.transform = CGAffineTransform.identity
                self.remindTimePicker.isHidden = false
            })
            
        } else {
            UIView.animate(withDuration: animationDuration, animations: { () -> Void in
                self.remindTimePicker.transform = self.remindTimePicker.transform.scaledBy(x: 0.001, y: 0.001)
            }) { (completion) -> Void in
                
                self.remindTimePicker.isHidden = true
            }
        }
    }
    
    @IBAction func pickerDidChange(_ sender: AnyObject) {
        print(newRoutine.remind)
        if remindTimePicker.countDownDuration != newRoutine.remind as TimeInterval && nameField.text != "" {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    // MARK: - Helper
    
    func initialPrep() {
        
        tableView.backgroundView?.backgroundColor = UIColor.clear
        tableView.backgroundColor = UIColor.clear
        
        tableView.separatorStyle = .none
        
        nameCell.backgroundColor = UIColor.clear
        timeCell.backgroundColor = UIColor.clear
        timeCell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "white_disclosure"))
        
        repeatCell.backgroundColor = UIColor.clear
        repeatCell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "white_disclosure"))
        
        remindCell.backgroundColor = UIColor.clear
        
        remindSwitch.onTintColor = tasklyOrange
        saveButton.isEnabled = false
        
        remindTimePicker.setValue(UIColor.white, forKeyPath: "textColor")
        
        if inEdit {
            navigationItem.title = newRoutine.name
            nameField.text = newRoutine.name
            timeCell.textLabel?.text = newRoutine.timeOfDay
            repeatCell.textLabel?.text = newRoutine.repDescription
            
            if newRoutine.remind != 0 {
                remindSwitch.setOn(true, animated: true)
                remindSwitch.addTarget(self, action: #selector(self.switchValueChanged), for: UIControlEvents.valueChanged)
                remindTimePicker.alpha = 1.0
                remindTimePicker.countDownDuration = newRoutine.remind as TimeInterval
            }
        }
    }
    
    func checkForChanges() {
        if !inEdit {
            nameField.text = temporaryName ?? ""
            
        } else if newRoutine.timeOfDay != timeCell.textLabel?.text || newRoutine.repDescription != repeatCell.textLabel?.text {
            saveButton.isEnabled = true
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: nameField, queue: OperationQueue.main) { (notification) in
            self.saveButton.isEnabled = self.nameField.text != self.newRoutine.name
        }
    }
    
    func drawSeparator(forCell cell: UITableViewCell) {
        
        let separator = UIView(frame: CGRect(x: cell.frame.size.width * 0.04, y: cell.frame.size.height - 1, width: cell.frame.size.width, height: 1))
        separator.backgroundColor = UIColor.white
        cell.addSubview(separator)
    }
    
    func switchValueChanged() {
        if remindSwitch.isOn != newRoutine.shouldRemind {
            self.saveButton.isEnabled = true
        } else {
            self.saveButton.isEnabled = false
        }
    }
    
    func dismissKeyboard() {
        if nameField.isFirstResponder {
            nameField.resignFirstResponder()
        }
    }
}
