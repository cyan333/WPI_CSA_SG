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
    
    open class func checkSoftwareVersion(version: String, completion: @escaping (_ status: String, _ title: String,
        _ msg: String, _ updates: String, _ version: String) -> Void){
        if localMode {
            let mock = RequestMocker.getFakeResponse(forRequestPath: pathGetVersionInfo)
            completion(mock[0] as! String, mock[1] as! String, mock[2] as! String,
                       mock[3] as! String, mock[4] as! String)
            return
        }
        do {
            let params = ["version" : version]
            let opt = try HTTP.GET(serviceBase + pathGetVersionInfo, parameters: params)
            opt.start{ response in
                if response.error != nil {
                    completion(serverDown, "", "", "", "")
                    return
                }
                let dict = WCUtils.convertToDictionary(data: response.data)
                if let dict = dict {
                    if let error = dict["error"] as? String {
                        if error != "" {
                            completion(error, "", "", "", "")
                            return
                        }
                    }
                    if let status = dict["status"] as? String {
                        completion(status, dict["title"] as? String ?? "", dict["message"] as? String ?? "",
                                   dict["updates"] as? String ?? "", dict["newVersion"] as? String ?? "")
                        return
                    }
                }
                completion(respondFormatError, "", "", "", "")
            }
        } catch{
            completion(serverDown, "", "", "", "")
        }
        
    }
    
    open class func reportSGProblem(forMenu menuId: Int,
                                    byUser userId: Int?,
                                    andEmail email: String,
                                    withReport report: String,
                                    completion: @escaping (String) -> Void) {
        do {
            let params = ["menuId": menuId, "userId": userId as Any, "email": email, "report": report] as [String : Any]
            let opt = try HTTP.New(serviceBase + pathCreateReport, method: .POST, parameters: params, headers: nil, requestSerializer: JSONParameterSerializer(), isDownload: false)
            opt.start { response in
                if response.error != nil {
                    completion(serverDown)
                    return
                }
                let dict = WCUtils.convertToDictionary(data: response.data)
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


