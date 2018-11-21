//
//  BackgroundChanger.swift
//  Taskly
//
//  Created by Development on 1/7/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import UIKit
import RealmSwift

class BackgroundChanger: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func canChange() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum)
    }
    
    func imagePicker() -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        
        return picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        saveImage(image: image, path: fileInDocumentsDirectory(filename: "userBackground"))
        
        let presenter = picker.presentingViewController as! AboutViewController
        presenter.changedToCustom = true
        
        picker.dismiss(animated: true, completion: { () -> Void in })
    }
    
    // MARK: - Helper methods
    
    func fileInDocumentsDirectory(filename: String) -> String {
        let documentsFolderPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
        return documentsFolderPath.appendingPathComponent(filename)
    }

    
    func saveImage(image: UIImage, path: String ) {
        
        var bg = image
        
        bg = cropImageToFit(image: image)
        
        let jpegImageData = bg.jpegData(compressionQuality: 1.0)
		
        do {
            try jpegImageData?.write(to: URL(fileURLWithPath: path), options: .atomic)
        } catch {
            print(error)
        }
    }
    
    func loadImageFromName(name: String) -> UIImage? {
        let path = self.fileInDocumentsDirectory(filename: name)
        
        let image = UIImage(contentsOfFile: path)
        
        return image
    }
    
    func deleteCustomImageFromDirectory() {
        let fileManager = FileManager.default
        
        let documentsFolderPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
        let path = documentsFolderPath.appendingPathComponent("userBackground")
        
        do {
            try fileManager.removeItem(atPath: path)
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
    
    func cropImageToFit(image: UIImage) -> UIImage {
        
        var croppedImage = image
        
        // only crop if image is horizontal
        if image.size.width > image.size.height {
            
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            
            let heightRatio = screenHeight / image.size.height
            let cropWidth = screenWidth / heightRatio
            
            let cropRect = CGRect(x: image.size.width/3, y: 0, width: cropWidth, height: image.size.height)
            
            let imageRef:CGImage = image.cgImage!.cropping(to: cropRect)!
            
            croppedImage = UIImage(cgImage:imageRef)
        }
        
        return croppedImage
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
