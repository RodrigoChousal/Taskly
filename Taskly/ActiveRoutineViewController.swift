//
//  ActiveRoutineViewController.swift
//  Taskly
//
//  Created by Development on 9/11/16.
//  Copyright © 2016 Rodrigo Chousal. All rights reserved.
//

import UIKit
import RealmSwift
import AudioToolbox

class ActiveRoutineViewController: UIViewController {
    
    let realm = try! Realm()
    
    var routine: Routine = Routine(name: "", timeOfDay: .None, id: 0) // Encontrar mejor manera NOT ZERO
    
    var routineLength: Int {
        var length = 0.0
        for task in routine.tasks {
            length += task.length
        }
        
        return Int(length)
    }
    
    var currentTaskPlace: Int = 0
    var timeInSeconds = 0
    var timer: Timer?
    var totalSecondsElapsed: Int = 0
    var currentTaskLength: Int = 0
    
    var descriptionOn: Bool = false
    
    var tasklyOrange = UIColor(red: 253, green: 157, blue: 0, alpha: 1.0)
    var tasklyGreen = UIColor(red: 65, green: 168, blue: 95, alpha: 1.0)

    @IBOutlet weak var routineNameLabel: UILabel!
    @IBOutlet weak var routineTimeRemaining: UILabel!
    @IBOutlet weak var currentTaskLabel: UILabel!
    @IBOutlet weak var taskTimeRemaining: UILabel!
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var timesCompletedLabel: UILabel!
    @IBOutlet weak var averageTimeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var avgTimeLabel: UILabel!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var completedLabel: UILabel!
    
    @IBOutlet weak var taskProgressBar: UIProgressView!
    @IBOutlet weak var routineProgressBar: UIProgressView!
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        if currentTaskPlace == routine.tasks.count - 1 { // routine.tasks.count - 1
            nextButton.titleLabel?.text = "Finish" // Not changing, condition working
        }
        
        setupView()
        
        startTimer(routine.tasks[currentTaskPlace])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func startTimer(_ task: Task) {
        taskProgressBar.setProgress(0.0, animated: false)
        
        timeInSeconds = Int(task.length * 60)
        currentTaskLength = Int(task.length * 60)
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    func update() {
        totalSecondsElapsed += 1
        
        taskProgressBar.progress = Float(1.0 - Double(timeInSeconds) / Double(currentTaskLength)) // Find way to smooth animation
        print("Task progress bar at \(Float(1.0 - Double(timeInSeconds) / Double(currentTaskLength)))") // Find way to smooth animation
        
        routineProgressBar.progress = Float(totalSecondsElapsed) / Float(routineLength * 60)
        print("Routine progress bar at \(Float(totalSecondsElapsed) / Float(routineLength * 60))")
        
        if timeInSeconds > 0 {
            timeInSeconds -= 1
            print(timeInSeconds)
            
            taskTimeRemaining.text = secondsToString(timeInSeconds)
            
        } else if timeInSeconds == 0 {
            nextTask(nextButton)
        }
        
        if totalSecondsElapsed % 60 == 0 && totalSecondsElapsed > 0 {
            routineTimeRemaining.text = "\(routineLength - totalSecondsElapsed % 60) minutes remaining"
        }
    }
    
    @IBAction func previousTask(_ sender: AnyObject) {
        timer?.invalidate()
        
        if currentTaskPlace > 0 {
            currentTaskPlace -= 1
            currentTaskLabel.text = routine.tasks[currentTaskPlace].name
            startTimer(routine.tasks[currentTaskPlace])
        } else if currentTaskPlace == 0 {
            timer?.invalidate()
            taskTimeRemaining.text = secondsToString(Int(routine.tasks[currentTaskPlace].length) * 60)
            startTimer(routine.tasks[currentTaskPlace])
        }
    }
    
    @IBAction func nextTask(_ sender: AnyObject) { // Too many writes.. try 1
        timer?.invalidate()
        
        try! self.realm.write {
            routine.tasks[currentTaskPlace].completed += 1
        }
        
        let newAverage = ((routine.tasks[currentTaskPlace].completed * routine.tasks[currentTaskPlace].averageTime) + (Int(routine.tasks[currentTaskPlace].length * 60) - timeInSeconds)) / (routine.tasks[currentTaskPlace].completed + 1)
        
        try! self.realm.write {
            routine.tasks[currentTaskPlace].averageTime = newAverage
        }
        
        if currentTaskPlace < routine.tasks.count - 1 {
            currentTaskPlace += 1
            currentTaskLabel.text = routine.tasks[currentTaskPlace].name
            startTimer(routine.tasks[currentTaskPlace])
            
            if currentTaskPlace == routine.tasks.count - 1 {
                nextButton.titleLabel?.text = "Finish"
            }
            
        } else if currentTaskPlace == routine.tasks.count - 1 {
            taskTimeRemaining.text = "00:00"
            routineFinished()
        }
    }
    
    @IBAction func closeAction(_ sender: AnyObject) {
        timer?.invalidate()
    }
    
    @IBAction func invisibleShowDesc(_ sender: AnyObject) {
        if !descriptionOn && !description.isEmpty {
            self.descriptionOn = true
            
            // Hide others
            timesCompletedLabel.alpha = 0.0
            averageTimeLabel.alpha = 0.0
            avgTimeLabel.alpha = 0.0
            streakLabel.alpha = 0.0
            completedLabel.alpha = 0.0
            
            
            // Show description
            descriptionLabel.alpha = 1.0
            
        } else {
            // Hide description
            self.descriptionOn = false
            descriptionLabel.alpha = 0.0
            
            // Show others
            timesCompletedLabel.alpha = 1.0
            averageTimeLabel.alpha = 1.0
            avgTimeLabel.alpha = 1.0
            streakLabel.alpha = 1.0
            completedLabel.alpha = 1.0
        }
    }
    
    func setupView() {
        
        // Over orange triangle
        routineNameLabel.text = routine.name
        routineNameLabel.textColor = UIColor.white
        routineNameLabel.font = UIFont(name: "Avenir-Medium", size: 18.0)
        
        routineTimeRemaining.text = "\(String(routineLength)) minutes remaining"
        routineTimeRemaining.textColor = UIColor.white
        routineTimeRemaining.font = UIFont(name: "Avenir-Medium", size: 13.75)
        
        closeButton.tintColor = UIColor.white
        closeButton.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 13.75)
        
        // Main
        currentTaskLabel.text = routine.tasks[currentTaskPlace].name
        currentTaskLabel.textColor = UIColor.white
        currentTaskLabel.font = UIFont(name: "Avenir-Light", size: 40)
        
        taskTimeRemaining.textColor = UIColor.white
        taskTimeRemaining.font = UIFont(name: "Avenir-Roman", size: 110)
        
        // Optional
        descriptionLabel.alpha = 0.0
        descriptionLabel.text = routine.tasks[currentTaskPlace].desc
        descriptionLabel.textColor = UIColor.white
        descriptionLabel.font = UIFont(name: "Avenir-Medium", size: 13.75)
        
        // Bottom information
        timesCompletedLabel.text = String(routine.tasks[currentTaskPlace].completed)
        timesCompletedLabel.textColor = UIColor.white
        
        completedLabel.textColor = UIColor.white
        
        streakLabel.textColor = UIColor.white
        
        avgTimeLabel.textColor = UIColor.white
        
        averageTimeLabel.text = secondsToString(routine.tasks[currentTaskPlace].averageTime)
        averageTimeLabel.textColor = UIColor.white
        
        routineProgressBar.progress = 0.0
        routineProgressBar.progressTintColor = UIColor.white
        
        taskProgressBar.progress = 0.0
        taskProgressBar.progressTintColor = tasklyGreen // no jala fuck
    }
    
    func secondsToString (_ seconds: Int) -> String {
        
        let (h, m, s) = secondsToHoursMinutesSeconds(seconds)
        
        if h > 0 {
            return String(format:"%02i:%02i:%02i", h, m, s)
        } else {
            return String(format:"%02i:%02i", m, s)
        }
    }
    
    func stringToSeconds(_ time: String) -> Int {
        
        let time = time as NSString
        
        var h: Int?
        var m: Int?
        var s: Int?
        
        if time.length == 8 {
            h = Int(time.substring(with: NSRange(location: 0, length: 2))) ?? 0
            m = Int(time.substring(with: NSRange(location: 3, length: 5))) ?? 0
            s = Int(time.substring(with: NSRange(location: 6, length: 8))) ?? 0
            
            return (h! * 60 * 60) + (m! * 60) + s!
            
        } else if time.length == 6 {
            m = Int(time.substring(with: NSRange(location: 0, length: 2))) ?? 0
            s = Int(time.substring(with: NSRange(location: 3, length: 5))) ?? 0
            
            return (m! * 60) + s!
            
        } else {
            return 0
        }

        
    }
    
    func secondsToHoursMinutesSeconds (_ seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func routineFinished() {
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        var alertMessage: String
        
        if (routine.timeOfDay.lowercased()) == "none" {
            alertMessage = "Great work! Another productive day!"
        } else {
            alertMessage = "Great work! Another productive \(routine.timeOfDay.lowercased())!"
        }
        
        let alertController = UIAlertController(title: "Routine completed", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        let finishAction = UIAlertAction(title: "Finish", style: .default, handler: self.returnToLastView) // Para que sirven los handlers? Como se usan?
        alertController.addAction(finishAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func returnToLastView(_ alert: UIAlertAction) -> Void {
        timer?.invalidate()
        dismiss(animated: true, completion: nil)
    }

}
