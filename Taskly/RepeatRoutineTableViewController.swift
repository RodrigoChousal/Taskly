//
//  RepeatRoutineTableViewController.swift
//  Taskly
//
//  Created by Development on 8/18/16.
//  Copyright © 2016 Rodrigo Chousal. All rights reserved.
//

import UIKit
import RealmSwift

class RepeatRoutineTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    let realm = try! Realm()
    
    let categories = [ Week.Monday.rawValue,
                       Week.Tuesday.rawValue,
                       Week.Wednesday.rawValue,
                       Week.Thursday.rawValue,
                       Week.Friday.rawValue,
                       Week.Saturday.rawValue,
                       Week.Sunday.rawValue ]
    
    var selectedRows: [Bool] = []
    
    var selectedCategories: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        navigationController?.delegate = self
        
        view.setBackground()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "categoryCell")
        
        selectedRows = getSelectedRows(selectedCategories: selectedCategories)
        
        tableView.backgroundView?.backgroundColor = UIColor.clear
        tableView.backgroundColor = UIColor.clear
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let controller = viewController as? RoutineDetailTableViewController {
            
            selectedCategories = getSelectedCategories(selectedRows: selectedRows)
            
            try! self.realm.write {
                controller.newRoutine.reps = selectedCategories
            }
            
            controller.repeatCell.textLabel?.text = controller.newRoutine.repDescription
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as UITableViewCell
        
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.text = categories[indexPath.row]
        cell.textLabel?.font = UIFont(name: "Avenir-Light", size: 24)
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
        cell.tintColor = UIColor.white
        
        if selectedRows[indexPath.row] == true {
            cell.accessoryType = .checkmark            
        } else {
            cell.accessoryType = .none
        }
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            
            var allowsChange: Bool = true
            selectedCategories = getSelectedCategories(selectedRows: selectedRows)
            
            if selectedCategories.count == 1 && cell.accessoryType == .checkmark {
                allowsChange = false
            }
            
            if allowsChange {
                
                if cell.accessoryType == .checkmark {
                    cell.accessoryType = .none
                    selectedRows[indexPath.row] = false
                    
                } else {
                    cell.accessoryType = .checkmark
                    selectedRows[indexPath.row] = true
                }
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func getSelectedCategories(selectedRows: [Bool]) -> [String] {
        var temporary: [String]  = []
        var count = 0

        for row in selectedRows {

            if row == true {
                temporary.append(categories[count])
            }

            count += 1
        }
        
        return temporary
    }
    
    func getSelectedRows(selectedCategories: [String]) -> [Bool] {
        var temporary = Array(repeating: false, count: categories.count)
        
        for category in selectedCategories {
            switch category {
                case categories[0]: temporary[0] = true
                case categories[1]: temporary[1] = true
                case categories[2]: temporary[2] = true
                case categories[2]: temporary[2] = true
                case categories[3]: temporary[3] = true
                case categories[3]: temporary[3] = true
                case categories[4]: temporary[4] = true
                case categories[5]: temporary[5] = true
                case categories[6]: temporary[6] = true
            default:
                break
            }
        }
        
        return temporary
    }
}
