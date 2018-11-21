//
//  TasklyModel.swift
//  TasklyModel
//
//  Created by Development on 6/24/16.
//  Copyright © 2016 Rodrigo Chousal. All rights reserved.
//

import Foundation
import RealmSwift

class RealmString: Object {
    @objc dynamic var stringValue = ""
}

// Routine model
class Routine: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var name: String = ""
    @objc dynamic var timeOfDay: String = ""
    @objc dynamic var remind = 0.0
    @objc dynamic var shouldRemind: Bool = false
    @objc dynamic var streak: Int = 0
    @objc dynamic var lastCompletion: Date = Date()
    @objc dynamic var nextCompletion: Date {
        
        // Weekday of last completion
        let lastWeekday = Int(Calendar.current.dateComponents([.weekday], from: lastCompletion).weekday!)
        
        // Replaces weekdays in strings to weekdays in int values
        var remindDays: [Int] = []
        for rep in self.reps {
            switch rep {
            case "Sunday":
                remindDays.append(1)
            case "Monday":
                remindDays.append(2)
            case "Tuesday":
                remindDays.append(3)
            case "Wednesday":
                remindDays.append(4)
            case "Thursday":
                remindDays.append(5)
            case "Friday":
                remindDays.append(6)
            case "Saturday":
                remindDays.append(7)
            default:
                break
            }
        }
        
        // Captures first day in weekday array
        var smallestDay: Int {
            var smallest = 0
            for index in remindDays {
                if index < smallest {
                    smallest = index
                }
            }
            return smallest
        }
        
        // Captures last day in weekday array
        var endOfSeries: Int {
            var biggest = 0
            for index in remindDays {
                if index > biggest {
                    biggest = index
                }
            }
            return biggest
        }
        
        var nextDay = 0
        var minimumDiff = 0
        
        // Checks if last time was done during planned weekday
        if remindDays.contains(lastWeekday) {
            let lastCompletionIndex = remindDays.index(of: lastWeekday)!
            let lastReminderIndex = remindDays.index(of: remindDays.last!)!
            
            // If last time was not end of week reminders
            if remindDays.count >= lastReminderIndex + 1 {
                // This means next time is next in array
                nextDay = remindDays[lastCompletionIndex + 1]
                                
            } else {
                // This means last completion was end of week reminders, start week again
                nextDay = remindDays[0]
            }
            
        } else { // Last completion was not planned (i.e. not in reminders array)
            
            // Arbitrary number: smallest difference never larger than 1 + largest weekday
            minimumDiff = endOfSeries + 1
            
            // Go through planned weekdays and calculate closest planned day, as long as it is in the future: this is next completion
            for plannedDay in remindDays {
                
                // If planned day in array is later than the last completion and closer than minimum difference in earlier calculations
                if plannedDay > lastWeekday && (plannedDay - lastWeekday) < minimumDiff {
                    
                    minimumDiff = plannedDay - lastWeekday
                    nextDay = lastWeekday + minimumDiff
                    
                // Else if last completion was later than last planned weekday, next completion is earliest planned weekday
                } else if lastWeekday > endOfSeries {
                    nextDay = smallestDay
                }
            }
        }
        
        // Days till streak ends
        var days = nextDay - lastWeekday
        
        // If days is less than 0, jumping weeks: add 7 for correction
        if days < 0 {
            days += 7
        }
        
        // Next completion is last completion but days later: 24 hours, 60 minutes, 60 seconds
        let nextCompletion = lastCompletion.addingTimeInterval(TimeInterval(days*24*60*60))

        return nextCompletion
    }
    @objc dynamic var taskCountString: String {
        if self.tasks.count > 1 {
            return "\(self.tasks.count) Tasks"
            
        } else if self.tasks.count == 1 {
            return "1 Task"
            
        } else {
            return "Empty"
        }
    }
    @objc dynamic var repDescription: String {
        
        var description = ""
        
        let monday = Week.Monday.rawValue
        let tuesday = Week.Tuesday.rawValue
        let wednesday = Week.Wednesday.rawValue
        let thursday = Week.Thursday.rawValue
        let friday = Week.Friday.rawValue
        let saturday = Week.Saturday.rawValue
        let sunday = Week.Sunday.rawValue
        
        if reps == [monday, tuesday, wednesday, thursday, friday, saturday, sunday] {
            description = "Every Day"
            
        } else if reps == [monday, tuesday, wednesday, thursday, friday] {
            description = "Weekdays"
            
        } else if reps == [saturday, sunday] {
            description = "Weekends"
            
        } else {
            
            if reps.count == 1 {
                description = reps[0] + "s"
                
            } else if reps.count == 2 {
                description = reps[0] + "s & " + reps[1] + "s"
                
            } else if self.reps.count > 2 {
                for day in reps {
                    switch day {
                    case monday:
                        description += "Mon. "
                    case tuesday:
                        description += "Tue. "
                    case wednesday:
                        description += "Wed. "
                    case thursday:
                        description += "Thu. "
                    case friday:
                        description += "Fri. "
                    case saturday:
                        description += "Sat. "
                    case sunday:
                        description += "Sun. "
                    default:
                        description = ""
                    }
                }
            }
        }
        
        return description
    }
    @objc dynamic var totalLength: Int {
        
        var localCount: Double = 0
        
        for task in tasks {
            localCount += task.length
        }
        
        return Int(localCount)
    }
    
    var tasks = List<Task>()
    
    var reps: [String] {
        get {
            return _backingReps.map { $0.stringValue }
        }
        set {
            _backingReps.removeAll()
            _backingReps.append(objectsIn: newValue.map({ RealmString(value: [$0]) }))
        }
    }
    let _backingReps = List<RealmString>()
    
    override static func ignoredProperties() -> [String] {
        return ["reps"]
    }
    
    convenience init(name: String, timeOfDay: DayTime, reps: [String], id: Int) {
        self.init()
        self.timeOfDay = timeOfDay.rawValue
        self.name = name
        self.id = id
        self.reps = reps
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

enum Week: String {
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
    case Sunday
}

// Task model
class Task: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var name: String = ""
    @objc dynamic var desc: String? = nil
    @objc dynamic var length: Double = 0.0
    @objc dynamic var state: Bool = true
    @objc dynamic var completed: Int = 0
    @objc dynamic var averageTime: Int = 0
    
    let routine = LinkingObjects(fromType: Routine.self, property: "tasks")
    
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
