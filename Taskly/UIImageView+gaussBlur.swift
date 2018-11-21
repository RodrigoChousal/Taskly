//
//  UIImageView+gaussBlur.swift
//  Taskly
//
//  Created by Development on 11/20/16.
//  Copyright © 2016 Rodrigo Chousal. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func gaussBlur(imageNamed name: String, withBlurRadius blurRadius: CGFloat) {
        
        print("Blurring image...")
        
//        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        //always fill the view
//        blurEffectView.frame = UIScreen.main.bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//
//        self.image = UIImage(named: name)
//        self.addSubview(blurEffectView)
        
        let imageToBlur = CIImage(image: UIImage(named: name)!)
        
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter?.setValue(blurRadius, forKey: "inputRadius")
        blurfilter?.setValue(imageToBlur, forKey: "inputImage")
        
        let resultImage = blurfilter?.value(forKey: "outputImage") as! CIImage
        let blurredImage = UIImage(ciImage: resultImage)

        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        self.frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.image = blurredImage
		self.contentMode = UIView.ContentMode.scaleAspectFill
        
        
        
        // gray filter
//        let grayView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
//        grayView.backgroundColor = UIColor(red: 144/255, green: 144/255, blue: 144/255, alpha: 0.40)

//        self.addSubview(grayView)
        
    }

}

