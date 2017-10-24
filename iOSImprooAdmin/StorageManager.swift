//
//  StorageManager.swift
//  Improo
//
//  Created by Zakhar Garan on 20.10.17.
//  Copyright © 2017 GaranZZ. All rights reserved.
//

import UIKit
import FirebaseStorage

class StorageManager {
    
    static var documentsUrl: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    static func getImage(forSection section: Section, imageName: String, completion: @escaping (UIImage?)->()) {
        
        guard let documentsUrl = documentsUrl else {
            completion(nil)
            return
        }
        
        let imagePath = section.rawValue + "/" + imageName
        let documentsImagePath = documentsUrl.appendingPathComponent(imagePath)
        
        if let image = getLocalImage(imageUrl: documentsImagePath) {
            completion(image)
        } else {
            guard directoryExists(forSection: section) else {
                //SHOW ALERT
                return
            }
            let imageReference = Storage.storage().reference(withPath: imagePath)
            let _ = imageReference.write(toFile: documentsImagePath, completion: { (url, error) in
                guard let url = url else {
                    completion(nil)
                    return
                }
                completion(getLocalImage(imageUrl: url))
            })
        }
    }
    
    static func getLocalImage(imageUrl: URL) -> UIImage? {
        do {
            let imageData = try Data(contentsOf: imageUrl)
            return UIImage(data: imageData)
        }
        catch {
            return nil
        }
    }
    
    static func directoryExists(forSection section: Section) -> Bool {
        guard let documentsUrl = documentsUrl else {
            return false
        }
        let sectionPath = documentsUrl.appendingPathComponent(section.rawValue).path
        
        if FileManager.default.fileExists(atPath: sectionPath) {
            return true
        } else {
            do {
                try FileManager.default.createDirectory(atPath: sectionPath, withIntermediateDirectories: true, attributes: nil)
                return true
            } catch {
                return false
            }
        }
    }
}
