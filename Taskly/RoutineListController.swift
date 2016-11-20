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

class RoutineListController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    let realm = try! Realm()

    @IBOutlet weak var tableView: UITableView!
    
    let backgroundView = UIView()
    
    var allRoutines: [[Routine]] = [[]]
    var queriedRoutines: [Routine] = []
    
    var headers: [String] = []
    
    var idCount: Int = 0

    var selectedRoutine: Routine = Routine(name: "", timeOfDay: .None, id: 0)
    var editingRoutine: Bool = false
    
    let cellHeight = CGFloat(75)
    let spaceHeight = CGFloat(25)
    
    let yellowColor = UIColor(red: 243/255, green: 222/255, blue: 0/255, alpha: 1.0)
    let orangeColor = UIColor(red: 223/255, green: 111/255, blue: 48/255, alpha: 1.0)
    let blueColor = UIColor(red: 40/255, green: 50/255, blue: 77/255, alpha: 1.0)
    let grayColor = UIColor(red: 110/255, green: 110/255, blue: 110/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        backgroundView.frame = view.frame
//        backgroundView.addBlurredBackground(blurRadius: 15, withImageNamed: "background2")
        
        view.addSubview(backgroundView)
        view.sendSubview(toBack: backgroundView)
        
        loadRoutines()
        
        tableView.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
        tableView.sectionHeaderHeight = 38
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        editingRoutine = false
        
        if allRoutines.isEmpty {
            tableView.alpha = 0.0
        } else {
            tableView.alpha = 1.0
        }
        
        loadRoutines()
        setTableViewHeight(table: tableView)
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
        return allRoutines[section].count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let section = (indexPath as NSIndexPath).section
        let row = (indexPath as NSIndexPath).row
        
        if row == allRoutines[section].count {
            return spaceHeight
        }
        
        return cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoutineCell", for: indexPath)
        
        let section = (indexPath as NSIndexPath).section
        let row = (indexPath as NSIndexPath).row
        
        // If isn't last (clear) cell
        if row != allRoutines[section].count {
            
            // Set title
            cell.textLabel?.text = allRoutines[section][row].name
            
            // Format
            cell.textLabel?.font = UIFont(name: "Avenir-Heavy", size: 21.0)
            switch allRoutines[section][row].timeOfDay {
                
                case "Morning": cell.textLabel?.textColor = yellowColor
                case "Afternoon": cell.textLabel?.textColor = orangeColor
                case "Evening": cell.textLabel?.textColor = blueColor
                
                default: cell.textLabel?.textColor = grayColor
            }
            
            cell.accessoryType = .disclosureIndicator
            cell.isUserInteractionEnabled = true
            
        } else {
            cell.accessoryType = .none
            cell.isUserInteractionEnabled = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let section = (indexPath as NSIndexPath).section
        let row = (indexPath as NSIndexPath).row
        
        if cell.bounds.height == spaceHeight { // Overkill!
            cell.textLabel?.text = ""
            cell.alpha = 0.0
            cell.backgroundView?.backgroundColor = UIColor.clear
            cell.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            
        } else {
            
            cell.backgroundColor = UIColor.white
            cell.layer.mask = nil
            
            if row == allRoutines[section].count - 1 {
                
                let maskPath = UIBezierPath(roundedRect: cell.bounds,
                                            byRoundingCorners: [.bottomLeft, .bottomRight],
                                            cornerRadii: CGSize(width: 10.0, height: 10.0))
                let shape = CAShapeLayer()
                shape.path = maskPath.cgPath
                cell.layer.mask = shape // deletes delete button :(
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40))
        
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
                
                headerView.backgroundColor = grayColor
            }
            
            headerView.addSubview(icon)
        }
        
        // title
        let sectionLabel = UILabel(frame: CGRect(x: 13 + icon.bounds.size.width + 13, y: headerView.bounds.size.height/2 - 10, width: tableView.bounds.size.width, height: 18))
        sectionLabel.text = headers[section]
        sectionLabel.textColor = UIColor.white
        sectionLabel.font = UIFont(name: "Avenir-Medium", size: 15)
        
        // round corners
        let maskPath = UIBezierPath(roundedRect: headerView.bounds,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: 10.0, height: 10.0))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        headerView.layer.mask = shape
        
        headerView.addSubview(sectionLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        selectedRoutine = allRoutines[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        
        print("Selected routine is now \(selectedRoutine.name)")
        
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            self.deleteRoutine(indexPath: indexPath as NSIndexPath)
        }
        delete.backgroundColor = UIColor.red
        
        let edit = UITableViewRowAction(style: .default, title: "Edit") { action, index in
            self.editingRoutine = true
            self.selectedRoutine = self.allRoutines[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "routineDetail", sender: self)
            }
        }
        edit.backgroundColor = UIColor.orange
        
        return [ delete, edit ]
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0000001
    }
    
    // MARK: - Empty Data Management

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "You have no routines"
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline).withSize(18.0), NSForegroundColorAttributeName: UIColor.white]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Add a routine to get started!"
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body).withSize(18.0), NSForegroundColorAttributeName: UIColor.white]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "Checklist")
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -tableView.frame.size.height / 4.0
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
        if segue.identifier == "insideRoutine" {
            
            let destinationVC = segue.destination as! TaskListController
            destinationVC.routine = self.selectedRoutine
            
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
        }
    }
    
    @IBAction func cancel(_ segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func save(_ segue:UIStoryboardSegue) {
        
        if let routineDetailTVC = segue.source as? RoutineDetailTableViewController {

            if let routine = routineDetailTVC.newRoutine {
                                
                if routineDetailTVC.inEdit {
                    // Update all values except tasks
                    try! self.realm.write {
                        realm.create(Routine.self, value: ["id": routine.id, "name": routine.name, "timeOfDay": routine.timeOfDay, "reps": routine.reps, "remind": routine.remind], update: true)
                    }
                    
                    // Finish editing
                    editingRoutine = false
                    
                } else {
                    // Add new routine
                    try! self.realm.write {
                        self.realm.add(routine)
                    }
                }
                
                DispatchQueue.main.async(execute: {
                    self.loadRoutines()
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    // MARK: - Content Load & Sort
    
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
        
        // Temporary arrays used for filtering
        let morningRoutines = Array(realm.objects(Routine.self).filter("timeOfDay = 'Morning'"))
        let afternoonRoutines = Array(realm.objects(Routine.self).filter("timeOfDay = 'Afternoon'"))
        let eveningRoutines = Array(realm.objects(Routine.self).filter("timeOfDay = 'Evening'"))
        let noTimeRoutines = Array(realm.objects(Routine.self).filter("timeOfDay = 'None'"))
        
        // Checks if a section should be created and repopulates
        if !morningRoutines.isEmpty {
            headers.append(morningRoutines[0].timeOfDay)
            allRoutines.append(morningRoutines)
        }
        
        if !afternoonRoutines.isEmpty {
            headers.append(afternoonRoutines[0].timeOfDay)
            allRoutines.append(afternoonRoutines)
        }
        
        if !eveningRoutines.isEmpty {
            headers.append(eveningRoutines[0].timeOfDay)
            allRoutines.append(eveningRoutines)
        }
        
        if !noTimeRoutines.isEmpty {
            headers.append(noTimeRoutines[0].timeOfDay)
            allRoutines.append(noTimeRoutines)
        }
        
        
    }
    
    func deleteRoutine(indexPath: NSIndexPath) { // add delete button inside editing
        
        var indexP = indexPath as IndexPath
        
        let beforeDeleting = realm.objects(Routine.self).count
        print("There are \(beforeDeleting) before delete")
        
        // From persistent storage
        try! realm.write {
            realm.delete(allRoutines[(indexPath).section][(indexPath).row])
        }
        
        // From local storage
        allRoutines[(indexPath).section].remove(at: (indexPath).row)
        
        let remainingRoutines = realm.objects(Routine.self).count
        print("There are \(remainingRoutines) after delete")
        
        // From view
        tableView.deleteRows(at: [indexPath as IndexPath], with: .fade)
        
        // If deleting last cell in section but not only, draw curved edges
        if indexP.row == allRoutines[indexPath.section].count && indexP.row != 0 {
            
            indexP.row = allRoutines[indexPath.section].count - 1
            
            let cell = tableView.cellForRow(at: indexP)!
            
            let maskPath = UIBezierPath(roundedRect: cell.bounds,
                                        byRoundingCorners: [.bottomLeft, .bottomRight],
                                        cornerRadii: CGSize(width: 10.0, height: 10.0))
            let shape = CAShapeLayer()
            shape.path = maskPath.cgPath
            cell.layer.mask = shape // deletes delete button :(
            
        }
        
        // If only cell in section, delete section
        if allRoutines[indexPath.section].count == 0 {

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
    }
    
    func setTableViewHeight(table: UITableView) {
        let headersHeight = table.sectionHeaderHeight
        
        let numberOfHeaders = CGFloat(headers.count)
        let numberOfCells = CGFloat(queriedRoutines.count)
        
        let calculatedHeight = headersHeight * numberOfHeaders + cellHeight * numberOfCells + spaceHeight * numberOfHeaders
        
        table.frame = CGRect(x: table.frame.origin.x, y: table.frame.origin.y, width: table.frame.size.width, height: calculatedHeight)
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
