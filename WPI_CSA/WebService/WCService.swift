//
//  WCService.swift
//  WPI_CSA
//
//  Created by NingFangming on 5/4/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation



open class WCService {
    
    open class func checkSoftwareVersion(completion: @escaping (String, String, String) -> Void){
        do {
            let opt = try HTTP.GET(serviceBase + "get_version_info?version=" + softwareVersion)
            opt.start{ response in
                if response.error != nil {
                    completion(serverDown, "", "")
                    return
                }
                let dict = WCUtil.convertToDictionary(data: response.data)
                if let dict = dict {
                    if let status = dict["status"], let title = dict["title"],
                        let msg = dict["msg"], let error = dict["error"]{
                        if error != "" {
                            completion(error, "", "")
                            return
                        }else{
                            completion(status, title, msg)
                            return
                        }
                    }
                }
                completion(respondFormatError, "", "")
            }
        } catch{
            completion(HTTPError, "", "")
        }
        
    }
    
    open func start(_ completionHandler:@escaping ((Response) -> Void)) {
        do {
            let opt = try HTTP.GET("http://fmning.com:8080/WebApp/get_sg?menuId=89")
            opt.start()
        } catch let error {
            print("got an error creating the request: \(error)")
        }
    }
    
    
}
