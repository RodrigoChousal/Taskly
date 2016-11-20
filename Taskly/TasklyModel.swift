//
//  TasklyModel.swift
//  TasklyModel
//
//  Created by Development on 6/24/16.
//  Copyright © 2016 Rodrigo Chousal. All rights reserved.
//

import Foundation
import RealmSwift

// Routine model
class Routine: Object {
    
    dynamic var id = 0
    dynamic var name: String = ""
    dynamic var timeOfDay: String = ""
    dynamic var reps: String = ""
    dynamic var remind = 0.0
    
    let tasks = List<Task>()
    
    convenience init(name: String, timeOfDay: DayTime, id: Int) {
        self.init()
        self.timeOfDay = timeOfDay.rawValue
        self.name = name
        self.id = id
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}

enum DayTime: String {
    case Morning
    case Afternoon
    case Evening
    case None
    
    static let allValues = [Morning, Afternoon, Evening, None]
}

enum Repeats: String {
    case Daily
    case EveryOther
    case Weekly
    case Monthly
    
    static let allValues = [Daily, EveryOther, Weekly, Monthly]
}

// Task model
class Task: Object {
    
    dynamic var id = 0

    dynamic var name: String = ""
    dynamic var desc: String? = nil
    dynamic var length: Double = 0.0
    dynamic var state: Bool = true
    
    let routine = LinkingObjects(fromType: Routine.self, property: "tasks")
    
    dynamic var completed: Int = 0
    dynamic var averageTime: Int = 0
        
    convenience init(name: String, desc: String, length: Double, id: Int) {
        self.init()
        self.name = name
        self.desc = desc
        self.length = length
        self.id = id
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
