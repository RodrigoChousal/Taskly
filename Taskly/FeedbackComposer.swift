//
//  FeedbackComposer.swift
//  Taskly
//
//  Created by Development on 1/6/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import Foundation
import MessageUI

class FeedbackComposer: NSObject, MFMailComposeViewControllerDelegate {
    
    func canSendMail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
                
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.navigationBar.tintColor = UIColor.white
        
        mailComposerVC.setToRecipients(["tasklyfeedback@gmail.com"])
        mailComposerVC.setSubject("Feedback")
        mailComposerVC.setMessageBody("Is there something we can improve?", isHTML: false)
        
        return mailComposerVC
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
