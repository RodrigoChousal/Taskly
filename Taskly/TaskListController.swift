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
    
    var routine: Routine = Routine(name: "", timeOfDay: .None, reps: [], id: 0)
    var selectedTask: Task = Task(name: "", desc: "", length: 0.0, id: 0)
    var activeTasks: [Task] = []
    
    var idCount: Int = 0
        
    var editingTask = Bool()
    var hideCellAllowed: Bool = false
    
    var tasklyOrange = UIColor(red: 253/255, green: 157/255, blue: 0/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskListView.delegate = self
        taskListView.dataSource = self
        
        taskListView.emptyDataSetSource = self
        taskListView.emptyDataSetDelegate = self
        
        taskListView.backgroundView?.backgroundColor = UIColor.clear
        taskListView.backgroundColor = UIColor.clear
        taskListView.tableFooterView = UIView()
        
        view.setBackground()

        goButton.setImage(#imageLiteral(resourceName: "begin_btn_pressed"), for: UIControlState.highlighted)
        
        self.navigationBar.title = routine.name
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized(_:)))
        taskListView.addGestureRecognizer(longpress)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        findPrimaryKey()
        taskListView.reloadData()
        
        activeTasks = filterInactive(tasks: Array(routine.tasks))
        
        editingTask = false
        
        if activeTasks.isEmpty {
            goButton.isEnabled = false
        } else {
            goButton.isEnabled = true
        }
        
        for task in activeTasks {
            if task.name == "Journal" {
                try! realm.write {
                    print("wrote!")
                    task.averageTime = 590
                    task.completed = 27
                    routine.streak = 6
                }
            }
        }
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        
        cell.backgroundColor = UIColor.clear
        
        cell.nameLabel.text = routine.tasks[(indexPath as NSIndexPath).row].name
        cell.nameLabel.font = UIFont(name: "Avenir-Light", size: 24)
        cell.nameLabel.textColor = UIColor.white
        cell.nameLabel.adjustsFontSizeToFitWidth = true
        
        cell.timeLabel.font = UIFont(name: "Avenir-Medium", size: 10)
        cell.timeLabel.textColor = UIColor.white
        
        // If task is active
        if routine.tasks[indexPath.row].state == true {
            cell.timeLabel.text = "\(Int(routine.tasks[(indexPath as NSIndexPath).row].length)) min"
            cell.iconView.alpha = 1.0
            cell.iconView.image = UIImage(named: "time_shadow")
        } else {
            cell.timeLabel.text = "Inactive"
            cell.iconView.alpha = 0.0
        }
        
        return cell as UITableViewCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)! as! TaskCell
        
        editingTask = true
        selectedTask = self.routine.tasks[indexPath.row]
        
        cell.nameLabel.frame.size.width += 20
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "taskDetail", sender: self)
        }
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let taskToMove = routine.tasks[sourceIndexPath.row]
        
        try! realm.write {
            routine.tasks.remove(objectAtIndex: sourceIndexPath.row)
            routine.tasks.insert(taskToMove, at: sourceIndexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // Strange bug - need empty with clear background first: sets furthest background to this one
        let empty = UITableViewRowAction(style: .destructive, title: "") { action, index in
        }
        empty.backgroundColor = UIColor.clear
        
        let delete = UITableViewRowAction(style: .destructive, title: "       ") { action, index in
            self.deleteTask(indexPath: indexPath as NSIndexPath)
        }
        delete.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "transparent_delete"))
        
        let edit = UITableViewRowAction(style: .default, title: "          ") { action, index in
            
            self.editingTask = true
            self.selectedTask = self.routine.tasks[(indexPath as NSIndexPath).row]
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "taskDetail", sender: self)
            }
        }
        edit.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "transparent_edit"))
        
        return [ empty, delete, edit ]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.characters.count ?? 0
        
        if range.length + range.location > currentCharacterCount {
            return false
        }
        
        let newLength = currentCharacterCount + string.characters.count - range.length
        
        return newLength <= 40
    }
    
    // MARK: - Empty Data Management
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "You have no tasks in \"\(routine.name)\""
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline).withSize(18.0), NSForegroundColorAttributeName: UIColor.white]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Add a task to get started!"
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline).withSize(18.0), NSForegroundColorAttributeName: UIColor.white]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "checklist")
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -view.frame.size.height / 15
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startRoutine" {
            let destinationVC = segue.destination as! ActiveRoutineViewController
            
            activeTasks = filterInactive(tasks: Array(routine.tasks))
            
            destinationVC.routine = routine
            destinationVC.activeTasks = activeTasks
            
        } else if segue.identifier == "taskDetail" {
            let navController = segue.destination as! UINavigationController
            let destinationVC = navController.viewControllers[0] as! TaskDetailTableViewController
            
            print(editingTask)
            
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
            
            taskListView.reloadData()
        }
    }
    
    // MARK: - Helper
    
    // Finds largest unique key
    func findPrimaryKey() {
        
        idCount = routine.id * 1000 // Differentiates tasks in different routines in Realm
        
        for task in routine.tasks {
            if task.id > idCount {
                idCount = task.id
            }
        }
    }
    
    func filterInactive(tasks: [Task]) -> [Task] {
        
        var filteredTasks: [Task] = []
        
        for task in tasks {
            if task.state == true {
                filteredTasks.append(task)
            }
        }
        
        return filteredTasks
    }
    
    func deleteTask(indexPath: NSIndexPath) {
        try! realm.write {
            // Remove item from persistent storage
            realm.delete(routine.tasks[(indexPath as NSIndexPath).row])
        }
        
        // Remove cell from tableView
        self.taskListView.deleteRows(at: [indexPath as IndexPath], with: .fade)
        
        // Check if last task, disable Go! button
        if taskListView.visibleCells.count == 0 {
            goButton.isEnabled = false
        }
    }
    
    func snapshotOfCell(inputView: UIView) -> UIView {
        
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        
        UIGraphicsEndImageContext()
        
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        
        return cellSnapshot
    }
    
    func longPressGestureRecognized(_ gestureRecognizer: UIGestureRecognizer) {
        
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        
        let locationInView = longPress.location(in: taskListView)
        var indexPath = taskListView.indexPathForRow(at: locationInView)
        
        struct My {
            static var cellSnapshot : UIView? = nil
        }
        struct Path {
            static var initialIndexPath : NSIndexPath? = nil
        }
        
        switch state {
            
            case UIGestureRecognizerState.began:
                
                if let indexPath = indexPath {
                
                    Path.initialIndexPath = indexPath as NSIndexPath?
                    
                    let cell = taskListView.cellForRow(at: indexPath) as UITableViewCell!
                    My.cellSnapshot  = snapshotOfCell(inputView: cell!)
                    
                    var center = cell?.center
                    
                    My.cellSnapshot!.center = center!
                    My.cellSnapshot!.alpha = 0.0
                    
                    taskListView.addSubview(My.cellSnapshot!)
                
                    UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    
                        center?.y = locationInView.y
                        My.cellSnapshot!.center = center!
                        My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                        My.cellSnapshot!.alpha = 0.98
                        cell?.alpha = 0.0
                    
                    }, completion: { (finished) -> Void in
                        if finished && self.hideCellAllowed == true{
                            cell?.isHidden = true
                        }
                    })
                }
            
            case UIGestureRecognizerState.changed:
                
                if let indexPath = indexPath {
                    let cell = taskListView.cellForRow(at: indexPath) as UITableViewCell!
                    cell?.alpha = 0.0
                }
                
                var center = My.cellSnapshot!.center
                center.y = locationInView.y
                My.cellSnapshot!.center = center
                
                if indexPath != nil && indexPath?.row != Path.initialIndexPath?.row {
                    
                    try! self.realm.write {
                        swap(&routine.tasks[indexPath!.row], &routine.tasks[Path.initialIndexPath!.row])
                    }
                    
                    taskListView.moveRow(at: Path.initialIndexPath! as IndexPath, to: indexPath!)
                    Path.initialIndexPath = indexPath as NSIndexPath?
                }
            
            default:
                
                hideCellAllowed = false
                
                let cell = taskListView.cellForRow(at: Path.initialIndexPath! as IndexPath) as UITableViewCell!
                cell?.isHidden = false
                cell?.alpha = 0.0
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    
                    My.cellSnapshot!.center = (cell?.center)!
                    My.cellSnapshot!.transform = CGAffineTransform.identity
                    
                }, completion: { (finished) -> Void in
                    
                    if finished {
                        
                        My.cellSnapshot!.alpha = 0.0
                        cell?.alpha = 1.0
                        
                        Path.initialIndexPath = nil
                        My.cellSnapshot!.removeFromSuperview()
                        My.cellSnapshot = nil
                    }
                    
                })
        }
    }
}
