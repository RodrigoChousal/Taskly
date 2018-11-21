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
    
    var inEdit = false
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descField: UITextView!
    
    @IBOutlet weak var timePicker: UIDatePicker!
    
    @IBOutlet weak var nameCell: UITableViewCell!
    @IBOutlet weak var notesCell: UITableViewCell!
    @IBOutlet weak var activeCell: UITableViewCell!
    @IBOutlet weak var labelCell: UITableViewCell!
    @IBOutlet weak var activeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.delegate = self
        descField.delegate = self
		
		DispatchQueue.main.async {
			self.view.setBackground()
		}
        
        drawSeparator(forCell: nameCell)
        drawSeparator(forCell: notesCell)
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        descField.textContainer.maximumNumberOfLines = 4
        descField.textContainer.lineBreakMode = .byClipping
        
        if UIScreen.main.bounds.size.height == 568 {
            timePicker.frame.size.height = 100
        }
        
        prepareView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        nameField.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            nameField.becomeFirstResponder()
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        footer.contentView.backgroundColor = UIColor.clear
        footer.textLabel?.textColor = UIColor.white
        footer.alpha = 1.0
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.count ?? 0
        
        if range.length + range.location > currentCharacterCount || currentCharacterCount == 16 && string != "" {
            return false
        }
        
        let newLength = currentCharacterCount + string.count - range.length
        
        return newLength <= 25
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
        
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if textView.text.count == 0 {
            lineCount = 1
        }
        
        // Still does not solve pasting...
        let textRect = textView.caretRect(for: textView.endOfDocument)
                
        //Maximum length of a character is about 10
        if textView.contentSize.width - textRect.maxX < 10 {
            
            // If user is already deleting, don't delete twice
            if text != "" {
                return false
            }
        }
        
        // Keeps track of new lines so not infinite amount
        if text == "\n" {
            
            if lineCount == 4 || textRect.maxX == 6.0 {
                textView.deleteBackward()
                self.dismissKeyboard()
                return false
            }
            
            lineCount += 1
        }
        
        // Changes lineCount if new line is deleted
        if text == "" && textRect.maxX == 6.0 && textView.text.count != 0 {
            lineCount -= 1
        }
        
        return true
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Helper
    
    func prepareView() {
        
        tableView.backgroundView?.backgroundColor = UIColor.clear
        tableView.backgroundColor = UIColor.clear
        
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        
        nameCell.backgroundColor = UIColor.clear
        notesCell.backgroundColor = UIColor.clear
        activeCell.backgroundColor = UIColor.clear
//        labelCell.backgroundColor = UIColor.clear
        
        descField.backgroundColor = UIColor.clear
        descField.isScrollEnabled = false
        
        timePicker.setValue(UIColor.white, forKeyPath: "textColor")
        
        // Disables while field is empty
        saveButton.isEnabled = false
        
        setDateToPicker(task: nil)
        
        if let newTask = newTask, inEdit {
            navigationItem.title = newTask.name
            nameField.text = newTask.name
            descField.text = newTask.desc
            activeSwitch.isOn = newTask.state
            
            setDateToPicker(task: newTask)
            
            activeSwitch.addTarget(self, action: #selector(self.switchValueChanged), for: UIControl.Event.valueChanged)
            
            NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: descField, queue: OperationQueue.main) { (notification) in
                self.saveButton.isEnabled = self.descField.text != newTask.desc
            }
        }
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: nameField, queue: OperationQueue.main) { (notification) in
            self.saveButton.isEnabled = self.nameField.text != self.newTask?.name && self.nameField.text != ""
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveSegue" && nameField.text! != "" {

            let name = nameField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let desc = descField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let length = getHourFromDatePicker(timePicker) as Double
            let state = activeSwitch.isOn
            
            self.dismissKeyboard()
            
            // Editing task
            if inEdit {
                newTask = Task(name: name, desc: desc, length: length, id: primaryCount)
                newTask?.state = state
                
            // New task
            } else {
                newTask = Task(name: name, desc: desc, length: length, id: primaryCount + 1)
                newTask?.state = state
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func timePickerDidChange(_ sender: Any) {
        
        if getHourFromDatePicker(timePicker) as Double != newTask?.length && nameField.text != "" {
            print("button should be enabled")
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    // MARK: - Helper
    
    func drawSeparator(forCell cell: UITableViewCell) {
        
        let separator = UIView(frame: CGRect(x: cell.frame.size.width * 0.04, y: cell.frame.size.height - 1, width: cell.frame.size.width, height: 1))
        separator.backgroundColor = UIColor.white
        cell.addSubview(separator)
    }
    
    func setDateToPicker(task: Task?) {
        var components = DateComponents()
        let calendar = Calendar.current
        
        if let task = task {
            
            let taskLength = Int(task.length)
            
            components.hour = taskLength / 60
            components.minute = taskLength % 60
            
            timePicker.setDate(calendar.date(from: components)!, animated: false)
        } else {
            components.hour = 0
            components.minute = 0
            
            timePicker.setDate(calendar.date(from: components)!, animated: false)
        }
    }
    
    func getHourFromDatePicker(_ datePicker:UIDatePicker) -> Double {

        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([NSCalendar.Unit.hour, NSCalendar.Unit.minute] , from: datePicker.date)
        
        print("timePicker was \(components.minute! + components.hour! * 60) minutes")
        return Double(components.minute! + components.hour! * 60)
    }
    
    @objc func switchValueChanged() {
        if inEdit && activeSwitch.isOn != newTask?.state {
            self.saveButton.isEnabled = true
        } else {
            self.saveButton.isEnabled = false
        }
    }
}
