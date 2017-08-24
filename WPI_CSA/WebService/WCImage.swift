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
            let opt = try HTTP.GET(serviceBase + "file")
            opt.start{ response in
                if let imageData = response.data as Data? {
                    completion("", UIImage(data: imageData))
                }
            }
        } catch let error {
            print(error.localizedDescription)
            completion(serverDown, nil)
        }
    }
    
    
    open class func getSaltForUser(withUsername username: String,
                                   completion: @escaping (_ error: String, _ salt: String) -> Void) {
        do {
            let params = ["username" : username]
            let opt = try HTTP.POST(serviceBase + pathGetSalt, parameters: params)
            opt.start { response in
                if response.error != nil {
                    completion(serverDown, "")
                    return
                }
                let dict = WCUtils.convertToDictionary(data: response.data)
                if dict!["error"] as! String != "" {
                    completion(dict!["error"]! as! String, "")
                }else{
                    completion("", dict!["salt"]! as! String)
                }
            }
        } catch let error{
            print (error.localizedDescription)
            completion(serverDown, "")
        }
    }
}
