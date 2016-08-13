//
//  Taskly.swift
//  Taskly
//
//  Created by Development on 6/24/16.
//  Copyright © 2016 Rodrigo Chousal. All rights reserved.
//

import Foundation
import RealmSwift

// Routine model
class Routine: Object {
    
    dynamic var name: String = ""
    dynamic var timeOfDay: String = ""
    let tasks = List<Task>()
    
    convenience init(name: String, timeOfDay: DayTime) {
        self.init()
        self.timeOfDay = timeOfDay.rawValue
        self.name = name
    }
}

enum DayTime: String {
    case Morning
    case Afternoon
    case Evening
    case None
}

// Task model
class Task: Object {
    
    dynamic var name: String = ""
    dynamic var desc: String? = nil
    dynamic var length: Double = 0.0
    dynamic var state: Bool = true
    
    convenience init(name: String, desc: String, length: Double) {
        self.init()
        self.name = name
        self.desc = desc
        self.length = length
    }
}
