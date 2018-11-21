//
//  UIView+addBackground.swift
//  Taskly
//
//  Created by Development on 1/7/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import UIKit

extension UIView {

    func removeOldBackgroundView() {
        for subview in subviews {
            if subview.accessibilityIdentifier == "backgroundView" {
                subview.removeFromSuperview()
            }
        }
    }
    
    func findBackgoundImage() -> UIImage {
        
        let bgChanger = BackgroundChanger()
        
        if let bgImage = bgChanger.loadImageFromName(name: "userBackground") {
            return bgImage
        } else {
            return #imageLiteral(resourceName: "default_bg")
        }
    }
    
    func deleteCustomFromDirectory() {
        let bgChanger = BackgroundChanger()
        bgChanger.deleteCustomImageFromDirectory()
    }
    
    func setBackgroundToImage(image: UIImage) {
        
        let backView = UIImageView(image: image)
        backView.contentMode = .scaleAspectFill
        backView.clipsToBounds = true
        backView.frame = self.frame
        backView.frame.origin.y = 0
        
        if image != #imageLiteral(resourceName: "default_bg") {
            let grayView = UIView(frame: backView.frame)
            grayView.frame.origin.y = 0
            grayView.backgroundColor = UIColor(red: 144/255, green: 144/255, blue: 144/255, alpha: 0.3)
            backView.addSubview(grayView)
        }
        
        backView.accessibilityIdentifier = "backgroundView"
        
        self.addSubview(backView)
        self.sendSubviewToBack(backView)
    }
    
    func setBackground() {
        removeOldBackgroundView()
        setBackgroundToImage(image: findBackgoundImage())
    }
    
    func setDefaultBackground() {
        deleteCustomFromDirectory()
        removeOldBackgroundView()
        setBackgroundToImage(image: #imageLiteral(resourceName: "default_bg"))
    }
}
