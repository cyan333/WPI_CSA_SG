//
//  WCImage.swift
//  WPI_CSA
//
//  Created by NingFangming on 8/20/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation
import UIKit

open class WCImageManager {
    
    open class func getImage(withId id: Int, completion: @escaping (_ error: String, _ image: UIImage?) -> Void) {
        do {
            let params = ["id" : id]
            let opt = try HTTP.GET(serviceBase + pathGetImage, parameters: params)
            opt.start{ response in
                if let image = UIImage(data: response.data) {
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
    
    
    open class func saveTypeUniqueImg(image: UIImage, type: String,
                                      completion: @escaping (_ error: String, _ imageId: Int) -> Void) {
        do {
            let imageData = UIImageJPEGRepresentation(image, 1)!
            let base64 = imageData.base64EncodedString()
            let params = ["accessToken": WCService.currentUser!.accessToken, "type": type,
                          "image": base64]
            let opt = try HTTP.POST(serviceBase + pathSaveTUImage, parameters: params)
            opt.start{ response in
                if response.error != nil {
                    completion(serverDown, -1)
                    return
                }
                let dict = WCUtils.convertToDictionary(data: response.data)
                if dict!["error"] as! String != "" {
                    completion(dict!["error"]! as! String, -1)
                }else{
                    completion("", dict!["imageId"]! as! Int)
                }
            }
        } catch let error{
            print (error.localizedDescription)
            completion(serverDown, -1)
        }
    }
}
