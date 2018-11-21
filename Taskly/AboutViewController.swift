//
//  AboutViewController.swift
//  Taskly
//
//  Created by Development on 1/6/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    var backgroundSnapshot = UIImage()
    var blurView = UIVisualEffectView()
    var fromHome = true
    var changedToCustom = false
    
    let appId = "1193245996"
    let feedbackComposer = FeedbackComposer()
    let backgroundChanger = BackgroundChanger()
    
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var backgroundView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        backgroundView.image = backgroundSnapshot
        
        blurBackground()
        
        // Only present about view if coming from home screen
        if fromHome {
            presentAboutView()
        }
        
        // If user presses the blurred background to go back
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.hideAboutView(_:)))
        blurView.addGestureRecognizer(gesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Send feedback
    
    @IBAction func sendFeedback(_ sender: Any) {
        fromHome = false
        
        let configuredMailComposeViewController = feedbackComposer.configuredMailComposeViewController()
        
        if feedbackComposer.canSendMail() {
            present(configuredMailComposeViewController, animated: true, completion: {
                UIApplication.shared.statusBarStyle = .lightContent
            })
        } else {
            showSendMailErrorAlert()
        }
    }
    
    func showSendMailErrorAlert() {
        let alertController = UIAlertController(title: "Could Not Send Email", message: "Reach us at tasklyfeedback@gmail.com", preferredStyle: .alert)
        let sendMailErrorAlert = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(sendMailErrorAlert)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Share
    
    @IBAction func share(_ sender: Any) {
        fromHome = false
        
        shareApp(appId: appId) { success in
            print("ShareApp \(success)")
        }
    }
    
    func shareApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "https://itunes.apple.com/app/id" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: completion)
    }
    
    // MARK: - Rate & review
    
    @IBAction func rateReview(_ sender: Any) {
        fromHome = false
        
        rateApp(appId: appId) { success in
            print("RateApp \(success)")
        }
    }
    
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "https://itunes.apple.com/app/viewContentsUserReviews?id=" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: completion)
    }
    
    // MARK: - Change background
    
    @IBAction func changeBackground(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Change Background", message: "What do you want to do?", preferredStyle: .actionSheet)
        
        let changeAction = UIAlertAction(title: "Choose From Library", style: .default, handler: self.chooseFromLibrary)
        alertController.addAction(changeAction)
        
        let defaultAction = UIAlertAction(title: "Use Default", style: .default, handler: self.setDefaultBackground)
        alertController.addAction(defaultAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
    
        present(alertController, animated: true, completion: nil)
    }
    
    func setDefaultBackground(_ alert: UIAlertAction) -> Void {
        let navController = self.presentingViewController as! UINavigationController
        let presenter = navController.viewControllers[0] as! RoutineListController
        presenter.view.setDefaultBackground()
    }
    
    func chooseFromLibrary(_ alert: UIAlertAction) -> Void {
        fromHome = false
        
        let imagePicker = backgroundChanger.imagePicker()
        
        if backgroundChanger.canChange() {
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation
     
    @objc func hideAboutView(_ sender:UITapGestureRecognizer) {
     
        UIView.animate(withDuration: 0.3, animations: {
            self.aboutView.frame.origin.y += self.view.frame.height + 30
            self.blurView.alpha = 0.0 }, completion: { (true) in
                
                if self.changedToCustom {
                    let navController = self.presentingViewController as! UINavigationController
                    let presenter = navController.viewControllers[0] as! RoutineListController
                    presenter.view.setBackground()
                }
                
                self.dismiss(animated: false, completion: nil)
        })
    }
    
    // MARK: - Helper
    
    func blurBackground() {
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.frame = view.frame
        blurView.alpha = 0.0
        
        view.addSubview(blurView)
        view.sendSubviewToBack(blurView)
        view.sendSubviewToBack(backgroundView)
    }
    
    func presentAboutView() {
        // Have about view below window so transition works
        aboutView.frame.origin.y = view.frame.height
        
        // Blur background and pop in about view
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.blurView.alpha = 1.0
            self.aboutView.frame.origin.y -= self.view.frame.height + 30
        })
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
