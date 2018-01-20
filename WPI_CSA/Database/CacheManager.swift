//
//  CacheManager.swift
//  WPI_CSA
//
//  Created by NingFangming on 9/1/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation
import UIKit

open class CacheManager {
    
    open class func localDirInitiateSetup() {
        let fileManager = FileManager.default
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        
        // Copy database file to document folder. Replace it if the file already exists
        let dbDestinationPath = documentDirectoryPath.appendingPathComponent("Database.sqlite")
        if fileManager.fileExists(atPath: dbDestinationPath){
            do{
                try fileManager.removeItem(atPath: dbDestinationPath)
            }catch let error {
                print(error.localizedDescription)
            }
        }
        do{
            try fileManager.copyItem(atPath: Bundle.main.path(forResource: "Database",
                                                              ofType: "sqlite")!,
                                     toPath: dbDestinationPath)
        }catch let error as NSError {
            print("error occurred, here are the details:\n \(error)")
        }
        
        // Creating image cache folder
        let imageCacheDir = documentDirectoryPath.appendingPathComponent("imageCache")
        do {
            if fileManager.fileExists(atPath: imageCacheDir) {
                try fileManager.removeItem(atPath: imageCacheDir)
            }
            try fileManager.createDirectory(atPath: imageCacheDir,
                                            withIntermediateDirectories: false, attributes: nil)
        } catch let error {
            print(error.localizedDescription)
        }
        
        /*let pdfCacheDir = documentDirectoryPath.appendingPathComponent("pdfCache")
         do {
         if !fileManager.fileExists(atPath: pdfCacheDir) {
         try fileManager.createDirectory(atPath: pdfCacheDir,
         withIntermediateDirectories: false, attributes: nil)
         }
         } catch let error {
         print(error.localizedDescription)
         }*/
        
        // Exclude files or directories from icloud backup
        var dbPathUrl = URL(fileURLWithPath: dbDestinationPath)
        var imgCachePathUrl = URL(fileURLWithPath: imageCacheDir)
        do {
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try dbPathUrl.setResourceValues(resourceValues)
            try imgCachePathUrl.setResourceValues(resourceValues)
            
        } catch let error{
            print(error.localizedDescription)
        }
    }
    
    open class func getImage(withName name: String, completion: @escaping (_ error: String, _ image: UIImage?) -> Void) {
        var id = 0
        if name.hasPrefix("WCImage_"){
            if let imgId = Int(name.replacingOccurrences(of: "WCImage_", with: "")) {
                id = imgId
            } else {
                completion("Malformated WCService image id", nil)
                return
            }
        } else {
            completion("", UIImage(named: name))
            return
        }
        
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                        .userDomainMask, true)[0] as NSString
        //print(documentDirectoryPath)
        if Database.getCache(type: .Image, mappingId: id) != nil {
            let image = UIImage(contentsOfFile: documentDirectoryPath
                .appendingPathComponent("imageCache/\(id).jpg"))
            if let image = image {
                //print("image from local")
                Database.imageHit(id: id)
                //Database.getImgHit(id: id)
                completion("", image)
                return
            } else {
                Database.deleteCache(id: id)
            }
        }
        
        //print("img from server")
        do {
            let params = ["id" : id]
            let opt = try HTTP.GET(serviceBase + "get_image", parameters: params)
            opt.start{ response in
                if let image = UIImage(data: response.data) {
                    let imgPath = documentDirectoryPath.appendingPathComponent("imageCache/\(id).jpg")
                    
                    do{
                        try UIImageJPEGRepresentation(image, 1.0)?.write(to: URL(fileURLWithPath: imgPath),
                                                                         options: .atomic)
                        //Database.createCache(type: .Image, mappingId: id, value: "1")
                        Database.createOrUpdateImageCache(imageId: id)
                    }catch let error{
                        print(error.localizedDescription)
                    }
                    completion("", image)
                } else if let error = String(data: response.data, encoding: .utf8) {
                    completion(error, nil)
                } else {
                    completion("Unknown error", nil)
                }
            }
        } catch let error {
            print(error.localizedDescription)
            completion(serverDown, nil)
        }
    }
    
    open class func uploadImage(image: UIImage, type: String, targetSize: Int? = nil,
                                completion: @escaping (_ error: String, _ id: Int?) -> Void) {
        var compressRate: CGFloat = 1
        if let targetSize = targetSize {
            compressRate = image.compressRateForSize(target: targetSize)
        }
        
        WCImageManager.saveTypeUniqueImg(image: image, type: type, compressRate: compressRate) {
            (error, id) in
            if error == "" {
                let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                                .userDomainMask, true)[0] as NSString
                print(documentDirectoryPath)
                let imgPath = documentDirectoryPath.appendingPathComponent("imageCache/\(id).jpg")
                
                do{
                    try UIImageJPEGRepresentation(image, compressRate)?.write(to: URL(fileURLWithPath: imgPath), options: .atomic)
                    Database.createOrUpdateImageCache(imageId: id)
                }catch let error{
                    print(error.localizedDescription)
                }
                completion("", id)
            } else {
                completion(error, nil)
            }
        }
    }
    
    open class func saveImageToLocal(image: UIImage, id: Int) {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                        .userDomainMask, true)[0] as NSString
        let imgPath = documentDirectoryPath.appendingPathComponent("imageCache/\(id).jpg")
        do{
            try UIImageJPEGRepresentation(image, 1)?.write(to: URL(fileURLWithPath: imgPath), options: .atomic)
            Database.createOrUpdateImageCache(imageId: id)
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
}

