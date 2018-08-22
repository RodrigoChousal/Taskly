//
//  AppDelegate.swift
//  Taskly
//
//  Created by Development on 6/24/16.
//  Copyright © 2016 Rodrigo Chousal. All rights reserved.
//

import UIKit
import UserNotifications
import MessageUI
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    @available(iOS 10.0, *)
    func scheduleNotification(at date: Date, every repetition: [String], forRoutine routine: Routine, id: String) {
        
        var components = DateComponents()
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        
        components.hour = hour
        components.minute = minutes
        
        for rep in repetition {
            switch rep {
                case "Sunday"   : components.weekday = 1
                case "Monday"   : components.weekday = 2
                case "Tuesday"  : components.weekday = 3
                case "Wednesday": components.weekday = 4
                case "Thursday" : components.weekday = 5
                case "Friday"   : components.weekday = 6
                case "Saturday" : components.weekday = 7
                
            default:
                break
            }
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
            let content = UNMutableNotificationContent()
            content.title = routine.name
            content.body = "Let's go!"
            content.sound = UNNotificationSound.default()
            
            let request = UNNotificationRequest(identifier: id + "." + rep, content: content, trigger: trigger)
            
            print("added notif request w id: \(id + "." + rep)")
            
            UNUserNotificationCenter.current().add(request) {(error) in
                if let error = error {
                    print("Uh oh! We had an error: \(error)")
                }
            }
        }
    }
    
    func scheduleNotification(at date: Date, tasks: [Task]) {
        
        var components = DateComponents()
        let calendar = Calendar.current
        
        var triggerLength = 0.0
        
        let task = tasks[0]
        let name = tasks[1].name
        
        let taskLength = task.length * 60
        triggerLength += taskLength
        
        if let newDate = calendar.date(byAdding: .second, value: Int(triggerLength), to: date) {
            
            let day = calendar.component(.day, from: newDate)
            let hour = calendar.component(.hour, from: newDate)
            let minutes = calendar.component(.minute, from: newDate)
            let seconds = calendar.component(.second, from: newDate)
            
            components.day = day
            components.hour = hour
            components.minute = minutes
            components.second = seconds
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let content = UNMutableNotificationContent()
            content.title = name
            content.body = "This is your next task!"
            content.sound = UNNotificationSound.default()
            
            let request = UNNotificationRequest(identifier: name, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) {(error) in
                if let error = error {
                    print("Uh oh! We had an error: \(error)")
                }
            }
        }
    }
    
    func removeNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {(accepted, error) in
            if !accepted {
                print("Notification access denied.")
            }
        }
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 18) ?? UIFont.systemFont(ofSize: 18),
            NSForegroundColorAttributeName : UIColor.white
        ]
                
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [NSFontAttributeName: UIFont(name:"Avenir-Roman", size:13) ?? UIFont.systemFont(ofSize: 13),
             NSForegroundColorAttributeName: UIColor.white],
            for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [NSFontAttributeName: UIFont(name:"Avenir-Roman", size:13) ?? UIFont.systemFont(ofSize: 13),
             NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.3)],
            for: .disabled)
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 36/255, green: 45/255, blue: 70/255, alpha: 1.0)
        UINavigationBar.appearance().isTranslucent = false

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

    }


}

