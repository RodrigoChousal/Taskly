//
//  TaskDetailTableViewController.swift
//  Taskly
//
//  Created by Development on 8/31/16.
//  Copyright © 2016 Rodrigo Chousal. All rights reserved.
//

import UIKit

class TaskDetailTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var primaryCount: Int = 0
    
    var name: String?
    var desc: String?
    var time: Double = 0.0
    var on: Bool = true
    
    var newTask: Task?
    
    var lineCount = 1
    var descCount = 0
    
    var inEdit = false

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descField: UITextView!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    @IBOutlet weak var selectTrackCell: UITableViewCell!
    @IBOutlet weak var activeCell: UITableViewCell!
    
    @IBOutlet weak var activeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.delegate = self
        descField.delegate = self
        
        prepareView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        nameField.resignFirstResponder()
    }
    
    func prepareView() {
        
        activeCell.accessoryView = activeSwitch
        
        // Disables while field is empty
        saveButton.isEnabled = false
        
        if inEdit {
            self.navigationItem.title = newTask?.name
            self.nameField.text = newTask?.name
            self.descField.text = newTask?.desc
            self.timePicker.countDownDuration = (newTask?.length)! as TimeInterval
            
            activeSwitch.addTarget(self, action: #selector(self.switchValueChanged), for: UIControlEvents.valueChanged)
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextViewTextDidChange, object: descField, queue: OperationQueue.main) { (notification) in
                self.saveButton.isEnabled = self.descField.text != self.newTask?.desc
            }
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
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        
        if range.length + range.location > currentCharacterCount {
            return false
        }
        
        let newLength = currentCharacterCount + string.characters.count - range.length
        
        return newLength <= 40
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" { // Line added
            lineCount += 1
            
            if lineCount == 5 {
                print("Oops! lineCount at \(lineCount)")
                lineCount -= 1
                textView.deleteBackward()
            }
            
        } else if !text.isEmpty { // Character added
            descCount += 1
            
        } else if range.length == 1 && textView.text.characters.last == "\n" { // Line deleted
            lineCount -= 1
            
        } else if text == "" && descCount != 0 { // Character deleted
            descCount -= 1
        }
        
        let newLength = descCount + text.characters.count - range.length - lineCount
        
        return newLength <= 202 // Arbitrary number
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveSegue" && nameField.text! != "" {

            let name = nameField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let desc = descField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let length = getHourFromDatePicker(timePicker) as Double
            
            // Editing task
            if inEdit {
                newTask = Task(name: name, desc: desc, length: length, id: primaryCount)
                
            // New task
            } else {
                print("New task has id \(primaryCount + 1)")
                newTask = Task(name: name, desc: desc, length: length, id: primaryCount + 1)
            }
        }
    }
    
    func getHourFromDatePicker(_ datePicker:UIDatePicker) -> Double {

        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([NSCalendar.Unit.hour, NSCalendar.Unit.minute] , from: datePicker.date)
        
        return Double(components.minute! + components.hour! * 60)
    }
    
    func switchValueChanged() {
        if inEdit {
            self.saveButton.isEnabled = true
        }
    }
}
