//
//  WCService.swift
//  WPI_CSA
//
//  Created by NingFangming on 5/4/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation



open class WCService {
    static var currentUser: WCUser? = nil
    static var appMode: AppMode = .Offline
    
    open class func checkSoftwareVersion(version: String, completion: @escaping (String, String, String, String) -> Void){
        do {
            let opt = try HTTP.GET(serviceBase + "get_version_info?version=" + version)
            opt.start{ response in
                if response.error != nil {
                    completion(serverDown, "", "", "")
                    return
                }
                let dict = WCUtil.convertToDictionary(data: response.data)
                if let dict = dict {
                    if let error = dict["error"] as? String {
                        if error != "" {
                            completion(error, "", "", "")
                            return
                        }
                    }
                    if let status = dict["status"] as? String, let title = dict["title"] as? String,
                        let msg = dict["msg"] as? String, let version = dict["version"] as? String{
                        completion(status, title, msg, version)
                        return
                    }
                }
                completion(respondFormatError, "", "", "")
            }
        } catch{
            completion(serverDown, "", "", "")
        }
        
    }
    
    open class func reportSGProblem(forMenu menuId: Int,
                                    byUser userId: Int?,
                                    andEmail email: String,
                                    withReport report: String,
                                    completion: @escaping (String) -> Void) {
        do {
            let params = ["menuId": menuId, "userId": userId as Any, "email": email, "report": report] as [String : Any]
            let opt = try HTTP.New(serviceBase + "add_sg_report", method: .POST, parameters: params, headers: nil, requestSerializer: JSONParameterSerializer(), isDownload: false)
            opt.start { response in
                if response.error != nil {
                    completion(serverDown)
                    return
                }
                let dict = WCUtil.convertToDictionary(data: response.data)
                if let dict = dict {
                    if let error = dict["error"] as? String{
                        if error != "" {
                            completion(error)
                            return
                        }else{
                            completion("")
                            return
                        }
                    }
                }
                completion(respondFormatError)
            }
        } catch let err{
            print(err)
            completion(serverDown)
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

enum AppMode{
    case Offline
    case Login
    case LoggedOn
}
