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
    
    
    open class func uploadImg(completion: @escaping (_ error: String) -> Void) {
        do {
            let params = ["file" : UIImageJPEGRepresentation(UIImage(named: "1_1.jpg")!, 1.0)]
            let opt = try HTTP.POST(serviceBase + "fileup", parameters: params)
            opt.start{ response in
                completion("ok")
            }
        } catch let error{
            print (error.localizedDescription)
            completion(serverDown)
        }
    }
}
