//
//  RoutineListController.swift
//  Taskly
//
//  Created by Development on 7/11/16.
//  Copyright © 2016 Rodrigo Chousal. All rights reserved.
//

import UIKit
import RealmSwift
import DZNEmptyDataSet
import UserNotifications

@available(iOS 10.0, *)
class RoutineListController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    let realm = try! Realm()
    
    // Constants
    let cellHeight = CGFloat(70)
    let headerHeight =  CGFloat(40)
    let spaceHeight = CGFloat(30)
    
    let yellowColor = UIColor(red: 243/255, green: 222/255, blue: 0/255, alpha: 1.0)
    let orangeColor = UIColor(red: 223/255, green: 111/255, blue: 48/255, alpha: 1.0)
    let blueColor = UIColor(red: 0/255, green: 20/255, blue: 40/255, alpha: 1.0)
    let darkGrayColor = UIColor(red: 110/255, green: 110/255, blue: 110/255, alpha: 1.0)
    let lightGrayColor = UIColor(red: 199/255, green: 199/255, blue: 204/255, alpha: 1.0)
    
    // Data
    var allRoutines: [[Routine]] = [[]]
    var queriedRoutines: [Routine] = []
    
    var selectedRoutine: Routine = Routine(name: "", timeOfDay: .None, reps: [], id: 0)
    var editingRoutine: Bool = false
    var idCount: Int = 0
    
    // View management
    var headers: [String] = []
    
    var actionRowView = UIView()
    var actionRowBackgrounds: [[UIView]] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        view.setBackground()
                    
        tableView.contentInset = UIEdgeInsets.init(top: 20, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = UIColor.clear
        
        // View which displays fake delete and edit buttons
        actionRowView.frame.size = tableView.frame.size
        tableView.addSubview(actionRowView)
        tableView.sendSubviewToBack(actionRowView)
                        
        // From realm
        loadRoutines()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        // Unselect any selected row
        let selection = tableView.indexPathForSelectedRow
        if (selection != nil) {
            let cell = tableView.cellForRow(at: selection!) as! RoutineCell
            unhighlightCell(cell: cell, atIndex: selection!)
            tableView.deselectRow(at: selection!, animated: true)
        }
        
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews(){
        tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: tableView.frame.size.height)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headers[section]
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return headers.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allRoutines[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoutineCell", for: indexPath) as! RoutineCell
        
        let section = (indexPath as NSIndexPath).section
        let row = (indexPath as NSIndexPath).row
        
        // Set title
        cell.nameLabel.text = allRoutines[section][row].name
        
        // Set task amount
        cell.taskAmountLabel.text = allRoutines[section][row].taskCountString
        
        // Set length
        if allRoutines[section][row].totalLength > 0 {
            cell.timeLabel.text = minutesToString(minutes: allRoutines[section][row].totalLength)
        } else {
            cell.timeLabel.text = ""
        }
        
        // Set disclosure indicator
        cell.disclosureImageView.image = #imageLiteral(resourceName: "disclosure_indicator")
        
        // Format text colors
        unhighlightCell(cell: cell, atIndex: indexPath)
        
        return cell as UITableViewCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let section = (indexPath as NSIndexPath).section
        let row = (indexPath as NSIndexPath).row
        
        cell.layer.mask = nil
        
        // If last cell, make corners round
        if row == allRoutines[section].count - 1 {
            
            // Rounded corners
            let maskPath = UIBezierPath(roundedRect: cell.bounds,
                                        byRoundingCorners: [.bottomLeft, .bottomRight],
                                        cornerRadii: CGSize(width: 10.0, height: 10.0))
            let shape = CAShapeLayer()
            shape.path = maskPath.cgPath
            
            cell.layer.masksToBounds = true
            cell.layer.mask = shape
        }
        
        // Create action backgrounds
        if actionRowBackgrounds[section][row].accessibilityIdentifier != "created" {
            
            let cellActionBackground = createBackgroundActionView(forCell: cell)

            cellActionBackground.tag = 1000 + indexPath.section * 100 + indexPath.row // Change?

            actionRowBackgrounds[indexPath.section][indexPath.row] = cellActionBackground

            actionRowView.addSubview(cellActionBackground)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: headerHeight))
        
        var icon = UIImageView()
        
        // background color and icon
        if tableView.visibleCells.count > 0 {
            
            if headers[section] == "Morning" {
                
                headerView.backgroundColor = yellowColor
                
                icon = UIImageView(image: UIImage(named: "sun")) // 1 : 1
                icon.frame = CGRect(x: 15, y: headerView.bounds.size.height/2 - 10, width: 20, height: 20)
                
            } else if headers[section] == "Afternoon" {
                
                headerView.backgroundColor = orangeColor
                
                icon = UIImageView(image: UIImage(named: "setting_sun")) // 22w : 12h
                icon.frame = CGRect(x: 15, y: headerView.bounds.size.height/2 - 10, width: 22, height: 12)
                
            } else if headers[section] == "Evening" {
                
                headerView.backgroundColor = blueColor
                
                icon = UIImageView(image: UIImage(named: "moon")) // 1 : 1
                icon.frame = CGRect(x: 15, y: headerView.bounds.size.height/2  - 10, width: 14, height: 14)
            
            } else {
                
                headerView.backgroundColor = darkGrayColor
            }
            
            headerView.addSubview(icon)
            icon.center.y = headerView.frame.size.height / 2
        }
        
        // title
        let sectionLabel = UILabel(frame: CGRect(x: 13 + icon.bounds.size.width + 13, y: headerView.bounds.size.height/2 - 10, width: tableView.bounds.size.width / 2, height: headerView.bounds.size.height))
        sectionLabel.text = headers[section]
        sectionLabel.textColor = UIColor.white
        sectionLabel.font = UIFont(name: "Avenir-Medium", size: 15)
        
        headerView.addSubview(sectionLabel)
        sectionLabel.center.y = headerView.frame.size.height / 2
        
        // time
        let timeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: headerView.bounds.size.width / 3, height: headerView.bounds.size.height))
        timeLabel.center.y = headerView.frame.size.height / 2
        timeLabel.frame.origin.x = headerView.frame.size.width - (timeLabel.frame.width + 10)
        timeLabel.textAlignment = .right
        timeLabel.textColor = UIColor.white
        timeLabel.font = UIFont(name: "Avenir-Light", size: 13)
        
        timeLabel.text = getSectionLength(for: section)
        
        headerView.addSubview(timeLabel)
        
        // Make corners round
        let maskPath = UIBezierPath(roundedRect: headerView.bounds,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: 10.0, height: 10.0))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        headerView.layer.mask = shape
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedRoutine = allRoutines[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RoutineCell
        highlightCell(cell: cell, atIndex: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RoutineCell
        highlightCell(cell: cell, atIndex: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RoutineCell
        unhighlightCell(cell: cell, atIndex: indexPath)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        // Unhighlight all cells if scrolling
        if let indexList = tableView.indexPathsForVisibleRows {
            
            for index in indexList {
                if let cell = tableView.cellForRow(at: index) {
                    unhighlightCell(cell: cell as! RoutineCell, atIndex: index)
                    tableView.deselectRow(at: index, animated: true)
                }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // Format delete action
        let delete = UITableViewRowAction(style: .destructive, title: "           ") { action, index in
            self.deleteRoutine(indexPath: indexPath as NSIndexPath)
        }
        delete.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "delete_wbg"))
        
        // Format edit action
        let edit = UITableViewRowAction(style: .default, title: "       ") { action, index in
            self.editingRoutine = true
            self.selectedRoutine = self.allRoutines[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "routineDetail", sender: self)
            }
        }
        edit.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "edit_wbg"))
        
        // Unhighlight selected cell
        if let cell = tableView.cellForRow(at: indexPath) {
            unhighlightCell(cell: cell as! RoutineCell, atIndex: indexPath)
        }
        
        return [ delete, edit ]
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return spaceHeight
    }
    
    // MARK: - Empty Data Management

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "You have no routines"
        let attrs = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline).withSize(18.0), convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.white]
        return NSAttributedString(string: str, attributes: convertToOptionalNSAttributedStringKeyDictionary(attrs))
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Add a routine to get started!"
        let attrs = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline).withSize(18.0), convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.white]
        return NSAttributedString(string: str, attributes: convertToOptionalNSAttributedStringKeyDictionary(attrs))
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "checklist")
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -view.frame.size.height / 15
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "insideRoutine" {
            
            let destinationVC = segue.destination as! TaskListController
            destinationVC.routine = self.selectedRoutine
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
        } else if segue.identifier == "routineDetail" {
            
            let navController = segue.destination as! UINavigationController
            let destinationVC = navController.viewControllers[0] as! RoutineDetailTableViewController
            
            destinationVC.newRoutine = selectedRoutine
            destinationVC.inEdit = editingRoutine
            
            if editingRoutine {
                destinationVC.primaryCount = selectedRoutine.id
            } else {
                destinationVC.primaryCount = idCount
            }
            
        } else if segue.identifier == "about" {
            
            let destinationVC = segue.destination as! AboutViewController
            destinationVC.fromHome = true
            
            // Capture screenshot for blurring
            if let layer = UIApplication.shared.keyWindow?.layer {
                
                let scale = UIScreen.main.scale
                UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
                layer.render(in: UIGraphicsGetCurrentContext()!)
                
                let capture = UIGraphicsGetImageFromCurrentImageContext()
                
                UIGraphicsEndImageContext()
                
                if let screenshot = capture {
                    destinationVC.backgroundSnapshot = screenshot
                }
            }
        }
    }
    
    @IBAction func cancel(_ segue:UIStoryboardSegue) {
        editingRoutine = false
    }
    
    @IBAction func save(_ segue:UIStoryboardSegue) {
        
        if let routineDetailTVC = segue.source as? RoutineDetailTableViewController {

            let routine = routineDetailTVC.newRoutine
            var overwriting = Bool()
            
            if routineDetailTVC.inEdit {
                // Update all values except tasks
                try! self.realm.write {
                    realm.create(Routine.self, value: ["id": routine.id, "name": routine.name, "timeOfDay": routine.timeOfDay, "reps": routine.reps, "remind": routine.remind], update: true)
                }
                
                // Finish editing
                editingRoutine = false
                overwriting = true
                
            } else {
                // Add new routine
                try! self.realm.write {
                    self.realm.add(routine)
                }
                                
                overwriting = false
            }
            
            let delegate = UIApplication.shared.delegate as? AppDelegate
            
            if routineDetailTVC.remindSwitch.isOn {
                let selectedDate = routineDetailTVC.remindTimePicker.date
                let entireWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
                
                // Remove all possible notifications
                if overwriting {
                    for rep in entireWeek {
                        delegate?.removeNotification(withIdentifier: String(routine.id) + "." + rep)
                    }
                }
                
                // Schedule new remind weekday values
                delegate?.scheduleNotification(at: selectedDate, every: routine.reps, forRoutine: routine, id: String(routine.id))
                
                // Rewrite routine
                try! self.realm.write {
                    realm.create(Routine.self, value: ["id": routine.id, "name": routine.name, "timeOfDay": routine.timeOfDay, "reps": routine.reps, "remind": routine.remind], update: true)
                }
                
            } else {
                // User switched off reminders
                delegate?.removeNotification(withIdentifier: String(routine.id))
            }
            
            DispatchQueue.main.async(execute: {
                self.loadRoutines()
                self.tableView.reloadData()
            })
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        
    }
        
    // MARK: - Content Management
    
    // Requests all routines from Realm
    func loadRoutines() {
        self.queriedRoutines = Array(realm.objects(Routine.self))
        findPrimaryKey()
        sortRoutines()
    }
    
    // Sorts queried routines into morning, afternoon, evening & none in allRoutines
    // Creates headers for new sections as needed
    func sortRoutines() {
        
        // Clean slate
        allRoutines.removeAll()
        headers.removeAll()
        actionRowBackgrounds.removeAll()
        actionRowView.subviews.forEach({ $0.removeFromSuperview() })
        
        // Temporary arrays used for filtering
        let morningRoutines = Array(realm.objects(Routine.self).filter("timeOfDay = 'Morning'"))
        let afternoonRoutines = Array(realm.objects(Routine.self).filter("timeOfDay = 'Afternoon'"))
        let eveningRoutines = Array(realm.objects(Routine.self).filter("timeOfDay = 'Evening'"))
        let noTimeRoutines = Array(realm.objects(Routine.self).filter("timeOfDay = 'None'"))
        
        // Checks if a section should be created and repopulates necessary arrays
        if !morningRoutines.isEmpty {
            headers.append(morningRoutines[0].timeOfDay)
            allRoutines.append(morningRoutines)
            
            actionRowBackgrounds.append([])
            actionRowBackgrounds[actionRowBackgrounds.count - 1] = Array(repeating: UIView(), count: morningRoutines.count)
        }
        
        if !afternoonRoutines.isEmpty {
            headers.append(afternoonRoutines[0].timeOfDay)
            allRoutines.append(afternoonRoutines)
            
            actionRowBackgrounds.append([])
            actionRowBackgrounds[actionRowBackgrounds.count - 1] = Array(repeating: UIView(), count: afternoonRoutines.count)
        }
        
        if !eveningRoutines.isEmpty {
            headers.append(eveningRoutines[0].timeOfDay)
            allRoutines.append(eveningRoutines)
            
            actionRowBackgrounds.append([])
            actionRowBackgrounds[actionRowBackgrounds.count - 1] = Array(repeating: UIView(), count: eveningRoutines.count)
        }
        
        if !noTimeRoutines.isEmpty {
            headers.append(noTimeRoutines[0].timeOfDay)
            allRoutines.append(noTimeRoutines)
            
            actionRowBackgrounds.append([])
            actionRowBackgrounds[actionRowBackgrounds.count - 1] = Array(repeating: UIView(), count: noTimeRoutines.count)
        }
    }
    
    func deleteRoutine(indexPath: NSIndexPath) {
        
        var wasLastRoutine: Bool = false
        let deletingRoutine = allRoutines[(indexPath).section][(indexPath).row]
        
        // Notifications
        let delegate = UIApplication.shared.delegate as? AppDelegate
        for rep in deletingRoutine.reps {
            delegate?.removeNotification(withIdentifier: String(deletingRoutine.id) + "." + rep)
        }
        
        // From persistent storage
        try! realm.write {
            for task in deletingRoutine.tasks {
                realm.delete(task)
            }
            realm.delete(deletingRoutine)
        }
        
        // From local storage
        allRoutines[(indexPath).section].remove(at: (indexPath).row)

        CATransaction.begin()
        
        CATransaction.setCompletionBlock({
            
            if wasLastRoutine {
                self.actionRowBackgrounds.remove(at: indexPath.section)
            }
            
            for cell in self.tableView.visibleCells {
                
                let index = self.tableView.indexPath(for: cell)!
                
                let cellActionBackground = self.createBackgroundActionView(forCell: cell)
                cellActionBackground.tag = 1000 + index.section * 100 + index.row

                self.actionRowBackgrounds[index.section][index.row] = cellActionBackground

                self.actionRowView.addSubview(cellActionBackground)
            }
        })
        
        tableView.beginUpdates()
        
        // From view
        tableView.deleteRows(at: [indexPath as IndexPath], with: .fade)
        
        tableView.endUpdates()
        
        // Remove and reload action backgrounds
        actionRowBackgrounds[indexPath.section].remove(at: indexPath.row)
        actionRowView.subviews.forEach({ $0.removeFromSuperview() })
        
        CATransaction.commit()
        
        // If deleting last cell in section but not the only one, draw curved edges
        if indexPath.row == allRoutines[indexPath.section].count && indexPath.row != 0 {
            
            var newLastIndex = indexPath as IndexPath
            
            newLastIndex.row -= 1
            
            let cell = tableView.cellForRow(at: newLastIndex)!
            
            let maskPath = UIBezierPath(roundedRect: cell.bounds,
                                        byRoundingCorners: [.bottomLeft, .bottomRight],
                                        cornerRadii: CGSize(width: 10.0, height: 10.0))
            let shape = CAShapeLayer()
            shape.path = maskPath.cgPath
            cell.layer.mask = shape
        }
        
        // If only cell in section, delete section
        if allRoutines[indexPath.section].count == 0 {

            wasLastRoutine = true
            
            // From presistent storage
            try! realm.write {
                realm.delete(allRoutines[(indexPath).section])
            }
            
            // From local storage
            allRoutines.remove(at: indexPath.section)
            headers.remove(at: indexPath.section)
            
            // From view
            var sectionSet = IndexSet()
            sectionSet.insert(indexPath.section)
            tableView.deleteSections(sectionSet, with: .fade)
        }
        
        actionRowView.frame.size = tableView.frame.size
    }
    
    func highlightCell(cell: RoutineCell, atIndex index: IndexPath) {
        
        let section = index.section
        let row = index.row
        
        switch allRoutines[section][row].timeOfDay {
            
        case "Morning":
            cell.backgroundColor = yellowColor
            
        case "Afternoon":
            cell.backgroundColor = orangeColor
            
        case "Evening":
            cell.backgroundColor = blueColor
            
        default:
            cell.backgroundColor = darkGrayColor
        }
        
        cell.nameLabel.textColor = UIColor.white
        cell.timeLabel.textColor = UIColor.white
        cell.taskAmountLabel.textColor = UIColor.white
        
        cell.disclosureImageView.image = #imageLiteral(resourceName: "white_disclosure")
    }
    
    func unhighlightCell(cell: RoutineCell, atIndex index: IndexPath) {
        
        let section = index.section
        let row = index.row
        
        cell.backgroundColor = UIColor.white
        
        switch allRoutines[section][row].timeOfDay {
            
        case "Morning":
            cell.nameLabel.textColor = yellowColor
            cell.taskAmountLabel.textColor = lightGrayColor
            cell.timeLabel.textColor = lightGrayColor
            
        case "Afternoon":
            cell.nameLabel.textColor = orangeColor
            cell.taskAmountLabel.textColor = lightGrayColor
            cell.timeLabel.textColor = lightGrayColor
            
        case "Evening":
            cell.nameLabel.textColor = blueColor
            cell.taskAmountLabel.textColor = lightGrayColor
            cell.timeLabel.textColor = lightGrayColor
            
        default:
            cell.nameLabel.textColor = darkGrayColor
            cell.taskAmountLabel.textColor = lightGrayColor
            cell.timeLabel.textColor = lightGrayColor
            
        }
        
        cell.disclosureImageView.image = #imageLiteral(resourceName: "disclosure_indicator")

    }
    
    func createBackgroundActionView(forCell cell: UITableViewCell) -> UIView {
        
        let actionBg = UIImageView(image: #imageLiteral(resourceName: "swiped_cell"))
        actionBg.frame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: cell.frame.size.width, height: cell.frame.size.height * 1.04)

        actionBg.accessibilityIdentifier = "created"
        
        return actionBg
    }
    
    // MARK: - Helper Methods
    
    func secondsToHoursMinutesSeconds (_ seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func minutesToString (minutes: Int) -> String {
        
        let hr = minutes / 60
        let min = minutes % 60
        
        var hourString = ""
        var minString = ""
        
        switch hr {
            
        case 0: hourString = ""
        case 1: hourString = "\(hr) hr "
            
        default: hourString = "\(hr) hrs "
        }
        
        if min > 0 {
            minString = "\(min) min"
        } else {
            
            minString = ""
        }
        
        return hourString + minString
    }
    
    func getSectionLength(for section: Int) -> String {
        var timeCount: Int = 0
        
        for routine in allRoutines[section] {
            timeCount += routine.totalLength
        }
        
        return minutesToString(minutes: timeCount)
    }
    
    // Finds largest unique key
    func findPrimaryKey() {
        for routine in queriedRoutines {
            if routine.id > idCount {
                idCount = routine.id
            }
        }
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
