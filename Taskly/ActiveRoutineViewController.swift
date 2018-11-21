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
    
    var routine: Routine = Routine(name: "", timeOfDay: .None, reps: [], id: 0)
    var activeTasks: [Task] = []
    
    var enteredBackgroundDate = Date()
    
    var routineLength: Int {
        var length = 0.0
        for task in activeTasks {
            length += task.length
        }
        
        return Int(length) * 60
    }
    
    var currentTaskPlace: Int = 0
    var timeInSeconds = 0
    var timer: Timer?
    var routineSecondsElapsed: Int = 0
    var currentTaskLength: Int = 0
    
    var descriptionOn: Bool = false
    
    var currentTaskProgress: Float = 0
    var currentRoutineProgress: Float = 0
    
    var tasklyOrange = UIColor(red: 253/255, green: 157/255, blue: 0/255, alpha: 1.0)
    var tasklyGreen = UIColor(red: 65/255, green: 168/255, blue: 95/255, alpha: 1.0)

    @IBOutlet weak var routineNameLabel: UILabel!
    @IBOutlet weak var routineTimeRemaining: UILabel!
    @IBOutlet weak var currentTaskLabel: UILabel!
    @IBOutlet weak var taskTimeRemaining: UILabel!
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var showDescButton: UIButton!
    
    @IBOutlet weak var medalImageView: UIImageView!
    @IBOutlet weak var fireImageView: UIImageView!
    @IBOutlet weak var stopwatchImageView: UIImageView!
    
    @IBOutlet weak var streakValueLabel: UILabel!
    @IBOutlet weak var averageTimeLabel: UILabel!
    @IBOutlet weak var timesCompletedLabel: UILabel!
    
    @IBOutlet weak var avgTimeLabel: UILabel!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var completedLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var taskInfoView: UIView!
    
    @IBOutlet weak var taskProgressBar: UIProgressView!
    @IBOutlet weak var routineProgressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appReturnedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        if currentTaskPlace == activeTasks.count - 1 {
            nextButton.setBackgroundImage(#imageLiteral(resourceName: "finish_btn"), for: .normal)
            nextButton.setBackgroundImage(#imageLiteral(resourceName: "finish_btn"), for: .highlighted)
        }
        
        showDescButton.isEnabled = true
        showDescButton.isUserInteractionEnabled = true
        
        setupView()
        
        startTimer(activeTasks[currentTaskPlace])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // animate notes information
        if activeTasks[currentTaskPlace].desc != "" {
            self.descriptionLabel.text = "Press here to see your notes"
            UIView.animate(withDuration: 1.0, animations: {
                self.taskInfoView.alpha = 1.0
                self.descriptionLabel.alpha = 0.0
            }, completion: { (true) in
                self.descriptionLabel.text = self.activeTasks[self.currentTaskPlace].desc
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func startTimer(_ task: Task) {
        
        if timeInSeconds < 0 {
            timeInSeconds += Int(task.length * 60)
        } else {
            timeInSeconds = Int(task.length * 60)
        }
        
        currentTaskLength = Int(task.length * 60)
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        
        currentTaskProgress = Float(1.0 - Double(timeInSeconds) / Double(currentTaskLength))
        taskProgressBar.setProgress(currentTaskProgress, animated: true)
        
        currentRoutineProgress = Float(routineSecondsElapsed) / Float(routineLength)
        routineProgressBar.setProgress(currentRoutineProgress, animated: true)
        
        if timeInSeconds > 0 {
            timeInSeconds -= 1
            taskTimeRemaining.text = secondsToString(timeInSeconds)
            
        } else if timeInSeconds <= 0 {
            print("next task!")
            nextTask(nextButton)
        }
        
        let secondsLeft = (routineLength) - Int(routineSecondsElapsed)
        let finishDate = Date().addingTimeInterval(TimeInterval(secondsLeft))
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        routineTimeRemaining.text = "You will finish at " + formatter.string(from: finishDate)
        routineSecondsElapsed += 1
    }
    
    @IBAction func previousTask(_ sender: AnyObject) {
        timer?.invalidate()
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

        if descriptionOn {
            invisibleShowDesc(self)
        }
        
        var currentTask = activeTasks[currentTaskPlace]
        
        nextButton.setBackgroundImage(#imageLiteral(resourceName: "next_btn"), for: .normal)
        nextButton.setBackgroundImage(#imageLiteral(resourceName: "next_btn"), for: .highlighted)
        
        if currentTaskPlace > 0 {
            currentTaskPlace -= 1
            
            currentTask = activeTasks[currentTaskPlace]
            
            routineSecondsElapsed -= Int(currentTaskProgress * Float(currentTaskLength))

            let routineProgress = Float(routineSecondsElapsed) / Float(routineLength)
            routineProgressBar.setProgress(routineProgress, animated: true)
            
            startTimer(currentTask)
            
        } else if currentTaskPlace == 0 {
            timer?.invalidate()
            
            routineSecondsElapsed = 0
            
            taskTimeRemaining.text = secondsToString(Int(currentTask.length) * 60)
            startTimer(currentTask)
        }
        
        currentTaskLabel.text = currentTask.name
        timesCompletedLabel.text = String(currentTask.completed)
        averageTimeLabel.text = secondsToString(currentTask.averageTime)
        taskTimeRemaining.text = secondsToString(Int(currentTask.length * 60))
    }
    
    @IBAction func nextTask(_ sender: AnyObject) {
        timer?.invalidate()
        
        if descriptionOn {
            invisibleShowDesc(self)
        }
        
        if timeInSeconds >= 0 {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        
        let currentTask = activeTasks[currentTaskPlace]

        let oldAverage = currentTask.completed * currentTask.averageTime
        let newTime = Int(currentTask.length * 60) - timeInSeconds
        
        let newAverage = (oldAverage + newTime) / (currentTask.completed + 1)
        
        try! self.realm.write {
            currentTask.completed += 1
            currentTask.averageTime = newAverage
        }
        
        if currentTaskPlace < activeTasks.count - 1 {
            currentTaskPlace += 1
            
            if currentTaskPlace == activeTasks.count - 1 {
                nextButton.setBackgroundImage(#imageLiteral(resourceName: "finish_btn"), for: .normal)
                nextButton.setBackgroundImage(#imageLiteral(resourceName: "finish_btn"), for: .highlighted)
            }
            
            let nextTask = activeTasks[currentTaskPlace]
            
            // schedule notification for task
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
				if (currentTaskPlace + 1) < activeTasks.count {
					delegate.scheduleNotification(at: Date(), tasks: [nextTask, activeTasks[currentTaskPlace + 1]])
				} else {
					delegate.scheduleNotification(at: Date(), tasks: [nextTask])
				}
            }
            
            // remove notification for previous task
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.removeNotification(withIdentifier: currentTask.name)
            }
            
            taskTimeRemaining.text = secondsToString(Int(nextTask.length * 60))
            currentTaskLabel.text = nextTask.name
            timesCompletedLabel.text = String(nextTask.completed)
            averageTimeLabel.text = secondsToString(nextTask.averageTime)
            
            routineSecondsElapsed += Int(( 1.0 - currentTaskProgress) * Float(currentTaskLength))
            taskProgressBar.setProgress(1.0, animated: true)
            
            currentRoutineProgress = Float(routineSecondsElapsed) / Float(routineLength)
            routineProgressBar.setProgress(currentRoutineProgress, animated: true)
            
            startTimer(nextTask)
            
        } else if currentTaskPlace == activeTasks.count - 1 {
            routineSecondsElapsed = routineLength
            taskProgressBar.setProgress(1.0, animated: true)
            
            let routineProgress = Float(routineSecondsElapsed) / Float(routineLength)
            routineProgressBar.setProgress(routineProgress, animated: true)
            
            taskTimeRemaining.text = "00:00"
            routineFinished()
        }
    }
    
    @IBAction func closeAction(_ sender: AnyObject) {
        timer?.invalidate()
        removeAllTaskNotifications()
    }
    
    @IBAction func invisibleShowDesc(_ sender: AnyObject) {
        
        if !descriptionOn && !description.isEmpty {
            
            self.descriptionOn = true
            
            if activeTasks[currentTaskPlace].desc != "" {
                descriptionLabel.text = activeTasks[currentTaskPlace].desc
            } else {
                descriptionLabel.text = "No Notes"
            }
            
            // Hide others
            for subview in taskInfoView.subviews {
                subview.alpha = 0.0
            }
            
            // Show description
            descriptionLabel.alpha = 1.0
            
        } else {
            
            // Hide description
            self.descriptionOn = false
            descriptionLabel.alpha = 0.0
            
            // Show others
            for subview in taskInfoView.subviews {
                subview.alpha = 1.0
            }
        }
    }
    
    func checkStreak() {
        let elapsedTime = Date().timeIntervalSince(routine.lastCompletion)
        if routine.lastCompletion.addingTimeInterval(elapsedTime) < routine.nextCompletion {
            try! realm.write {
                
                routine.streak += 1
            }
        } else {
            try! realm.write {
                routine.streak = 0
            }
        }
    }
    
    func setupView() {

        view.setBackground()
        
        // Over orange triangle
        routineNameLabel.text = routine.name
        routineNameLabel.textColor = UIColor.white
        routineNameLabel.font = UIFont(name: "Avenir-Medium", size: 18.0)
        
        let secondsLeft = (routineLength) - Int(routineSecondsElapsed)
        let finishDate = Date().addingTimeInterval(TimeInterval(secondsLeft))
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        routineTimeRemaining.text = "You will finish at " + formatter.string(from: finishDate)
        routineTimeRemaining.textColor = UIColor.white
        routineTimeRemaining.font = UIFont(name: "Avenir-Medium", size: 13.75)
        
        closeButton.tintColor = UIColor.white
        closeButton.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 13.75)
        
        // Main
        currentTaskLabel.text = activeTasks[currentTaskPlace].name
        currentTaskLabel.textColor = UIColor.white
        currentTaskLabel.font = UIFont(name: "Avenir-Light", size: 40)
        
        taskTimeRemaining.textColor = UIColor.white
        taskTimeRemaining.font = UIFont(name: "Avenir-Roman", size: 100)
        
        // Optional description
        descriptionLabel.alpha = 0.0
        descriptionLabel.text = activeTasks[currentTaskPlace].desc
        descriptionLabel.textColor = UIColor.white
        descriptionLabel.font = UIFont(name: "Avenir-Medium", size: 13.75)
        
        // Bottom information
        timesCompletedLabel.text = String(activeTasks[currentTaskPlace].completed)
        streakValueLabel.text = String(routine.streak)
        averageTimeLabel.text = secondsToString(activeTasks[currentTaskPlace].averageTime)
        
        let averageTimeString = String(activeTasks[currentTaskPlace].averageTime)
        if averageTimeString == "0" {
            averageTimeLabel.text = ""
        }
        
        streakValueLabel.textColor = UIColor.white
        averageTimeLabel.textColor = UIColor.white
        timesCompletedLabel.textColor = UIColor.white
        
        avgTimeLabel.textColor = UIColor.white
        streakLabel.textColor = UIColor.white
        completedLabel.textColor = UIColor.white
        
        // Progress bars
        routineProgressBar.setProgress(0.0, animated: false)
        routineProgressBar.trackTintColor = UIColor.clear
        routineProgressBar.progressTintColor = UIColor.white
        
        taskProgressBar.setProgress(0.0, animated: false)
        taskProgressBar.trackTintColor = UIColor.clear
        taskProgressBar.progressTintColor = tasklyGreen
        
        if activeTasks[currentTaskPlace].desc != "" {
            self.descriptionLabel.text = "Press here to see your notes"
            self.taskInfoView.alpha = 0.0
            self.descriptionLabel.alpha = 1.0
        }
    }
    
    func setBackgroundToImage(image: UIImage) {
        let backView = UIImageView(image: image)
        backView.frame = view.frame
        backView.contentMode = .bottomLeft
        
        if image != #imageLiteral(resourceName: "default_bg") {
            let grayView = UIView(frame: backView.frame)
            grayView.backgroundColor = UIColor(red: 144/255, green: 144/255, blue: 144/255, alpha: 0.4)
            backView.addSubview(grayView)
        }
        
        view.addSubview(backView)
        view.sendSubviewToBack(backView)
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
        
        UIApplication.shared.isIdleTimerDisabled = false
        removeAllTaskNotifications()
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        checkStreak()
        
        try! self.realm.write {
            routine.lastCompletion = Date()
        }
        
        var alertMessage: String
        
        if (routine.timeOfDay.lowercased()) == "none" {
            alertMessage = "Great work! Another productive day!"
        } else {
            alertMessage = "Great work! Another productive \(routine.timeOfDay.lowercased())!"
        }
        
        let alertController = UIAlertController(title: "Routine completed", message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        let finishAction = UIAlertAction(title: "Finish", style: .default, handler: self.returnToLastView)
        alertController.addAction(finishAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func returnToLastView(_ alert: UIAlertAction) -> Void {
        timer?.invalidate()
        dismiss(animated: true, completion: nil)
    }
    
    func removeAllTaskNotifications() {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            for task in activeTasks {
                delegate.removeNotification(withIdentifier: task.name)
            }
        }
    }
    
    @objc func appMovedToBackground() {
        enteredBackgroundDate = Date()
    }

    @objc func appReturnedToForeground() {
        let elapsed = Int(Date().timeIntervalSince(enteredBackgroundDate))
        
        routineSecondsElapsed += elapsed
        timeInSeconds -= elapsed
    }
}
