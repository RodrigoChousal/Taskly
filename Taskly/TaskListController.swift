//
//  TaskListController.swift
//  Taskly
//
//  Created by Development on 8/30/16.
//  Copyright © 2016 Rodrigo Chousal. All rights reserved.
//

import UIKit
import RealmSwift
import DZNEmptyDataSet

class TaskListController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    let realm = try! Realm()
    
    @IBOutlet weak var taskListView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var goButton: UIButton!
        
    var routine: Routine = Routine(name: "", timeOfDay: .None, id: 0)
    var selectedTask: Task = Task(name: "", desc: "", length: 0.0, id: 0)
    
    var idCount: Int = 1000 // terrible design lol
        
    var editingTask: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        taskListView.delegate = self
        taskListView.dataSource = self
        
        findPrimaryKey()
        taskListView.reloadData()
        
        editingTask = false
        
        if routine.tasks.isEmpty {
            goButton.isEnabled = false
        } else {
            goButton.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskListView.emptyDataSetSource = self
        taskListView.emptyDataSetDelegate = self
        self.taskListView.tableFooterView = UIView()
        
        self.navigationBar.title = routine.name
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routine.tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)

        cell.backgroundColor = UIColor.clear
        
        cell.textLabel?.text = routine.tasks[(indexPath as NSIndexPath).row].name
        cell.textLabel?.font = UIFont(name: "Avenir-Light", size: 24)
        cell.textLabel?.textColor = UIColor.white
        
        cell.detailTextLabel?.text = "\(Int(routine.tasks[(indexPath as NSIndexPath).row].length)) min"
        cell.detailTextLabel?.font = UIFont(name: "Avenir-Medium", size: 10)
        cell.detailTextLabel?.textColor = UIColor.white
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.editingTask = true
        self.selectedTask = self.routine.tasks[(indexPath as NSIndexPath).row]
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "taskDetail", sender: self)
        }
    }

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "You have no tasks in \(routine.name)"
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline).withSize(18.0), NSForegroundColorAttributeName: UIColor.white]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Tap the button above to add your first task."
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body).withSize(18.0), NSForegroundColorAttributeName: UIColor.white]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "")
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -view.frame.size.height / 4.0
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            self.deleteTask(indexPath: indexPath as NSIndexPath)
        }
        delete.backgroundColor = UIColor.red
        
        let edit = UITableViewRowAction(style: .default, title: "Edit") { action, index in
            
            self.editingTask = true
            self.selectedTask = self.routine.tasks[(indexPath as NSIndexPath).row]
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "taskDetail", sender: self)
            }
        }
        edit.backgroundColor = UIColor.orange
        
        return [ delete, edit ]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // RoutineList Loads routines?
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.characters.count ?? 0
        
        if range.length + range.location > currentCharacterCount {
            return false
        }
        
        let newLength = currentCharacterCount + string.characters.count - range.length
        
        return newLength <= 40
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startRoutine" {
            let destinationVC = segue.destination as! ActiveRoutineViewController
            
            destinationVC.routine = routine
            
        } else if segue.identifier == "taskDetail" {
            let navController = segue.destination as! UINavigationController
            let destinationVC = navController.viewControllers[0] as! TaskDetailTableViewController
            
            destinationVC.newTask = selectedTask
            destinationVC.inEdit = editingTask
            
            if editingTask {
                destinationVC.primaryCount = selectedTask.id
            } else {
                destinationVC.primaryCount = idCount
            }
        }

    }
    
    @IBAction func cancel(_ segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func save(_ segue:UIStoryboardSegue) {
        
        if let taskDetailTVC = segue.source as? TaskDetailTableViewController {
            if let newTask = taskDetailTVC.newTask {
                
                if taskDetailTVC.inEdit {
                    // Update all values
                    try! self.realm.write {
                        realm.add(newTask, update: true)
                    }
                } else {
                    // Write new task
                    try! realm.write {
                        routine.tasks.append(newTask)
                    }
                
                }
            }
        }
    }
    
    // Finds largest unique key
    func findPrimaryKey() {
        for task in routine.tasks {
            if task.id > idCount {
                idCount = task.id
            }
        }
    }
    
    func deleteTask(indexPath: NSIndexPath) {
        try! realm.write {
            // Remove item from persistent storage
            realm.delete(routine.tasks[(indexPath as NSIndexPath).row])
        }
        
        // Remove cell from tableView
        self.taskListView.deleteRows(at: [indexPath as IndexPath], with: .fade)
    }
}
