//
//  WCUser.swift
//  WPI_CSA
//
//  Created by NingFangming on 5/11/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation

public class WCUser{
    var id: Int
    var username: String?
    var accessToken: String?
    var emailConfirmed = true
    var name = ""
    
    init(id: Int){
        self.id = id
    }
    
    init(id: Int, username: String, accessToken: String){
        self.id = id
        self.username = username
        self.accessToken = accessToken
    }
}

open class WCUserManager{
    
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
    
    open class func loginUser(withUsername username: String, andPassword password: String,
                              completion: @escaping (_ error: String, _ user: WCUser?) -> Void){
        do {
            let params = ["username" : username, "password" : password]
            let opt = try HTTP.POST(serviceBase + pathLogin, parameters: params)
            opt.start { response in
                if response.error != nil {
                    completion(serverDown, nil)
                    return
                }
                let dict = WCUtils.convertToDictionary(data: response.data)
                if dict!["error"] as! String != "" {
                    completion(dict!["error"]! as! String, nil)
                }else{
                    let user = WCUser(id: dict!["userId"] as! Int,
                                      username: dict!["username"] as! String,
                                      accessToken: dict!["accessToken"] as! String)
                    user.emailConfirmed = dict!["emailConfirmed"] as! Bool
                    if let name = dict!["name"] as? String {
                        user.name = name
                    }
                    if user.name == "" {user.name = "Unknown"}
                    completion("", user)
                }
            }
        } catch let error{
            print (error.localizedDescription)
            completion(serverDown, nil)
        }
    }
    
    open class func regesterSalt(forUsername username: String, completion: @escaping(_ error: String, _ salt: String) -> Void){
        do {
            let params = ["username": username, "offset": NSTimeZone.local.secondsFromGMT() / 3600] as [String : Any]
            let opt = try HTTP.POST(serviceBase + pathRegisterSalt, parameters: params)
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
    
    open class func register(forUsername username: String,
                             andEncryptedPassword password: String,
                             completion: @escaping(_ error: String, _ user: WCUser?) -> Void){
        do {
            let params = ["username" : username, "password" : password]
            let opt = try HTTP.POST(serviceBase + pathRegister, parameters: params)
            opt.start { response in
                if response.error != nil {
                    completion(serverDown, nil)
                    return
                }
                let dict = WCUtils.convertToDictionary(data: response.data)
                if dict!["error"] as! String != "" {
                    completion(dict!["error"]! as! String, nil)
                }else{
                    let user = WCUser(id: dict!["userId"] as! Int,
                                      username: dict!["username"] as! String,
                                      accessToken: dict!["accessToken"] as! String)
                    user.emailConfirmed = false
                    completion("", user)
                }
            }
        } catch let error{
            print (error.localizedDescription)
            completion(serverDown, nil)
        }
    }
    
    open class func getCurrentUserDetails(completion: @escaping (_ error: String) -> Void){
        do {
            let params = ["accessToken": WCService.currentUser!.accessToken,
                          "userId": WCService.currentUser!.id] as [String : Any?]
            let opt = try HTTP.POST(serviceBase + pathGetUserDetails, parameters: params)
            opt.start { response in
                if response.error != nil {
                    completion(serverDown)
                    return
                }
                let dict = WCUtils.convertToDictionary(data: response.data)
                if dict!["error"] as! String != "" {
                    completion(dict!["error"]! as! String)
                }else{
                    WCService.currentUser!.name = dict!["name"] as! String
                    completion("")
                }
            }
        } catch let error{
            print (error.localizedDescription)
            completion(serverDown)
        }
    }
    
    open class func saveCurrentUserDetails(realName name: String?, completion: @escaping (_ error: String) -> Void){
        do {
            let params = ["accessToken": WCService.currentUser!.accessToken,
                          "name": name] as [String : Any?]
            let opt = try HTTP.POST(serviceBase + pathSetUserDetails, parameters: params)
            opt.start { response in
                if response.error != nil {
                    completion(serverDown)
                    return
                }
                let dict = WCUtils.convertToDictionary(data: response.data)
                if dict!["error"] as! String != "" {
                    completion(dict!["error"]! as! String)
                }else{
                    completion("")
                }
            }
        } catch let error{
            print (error.localizedDescription)
            completion(serverDown)
        }
    }
    
    open class func sendEmailConfirmation(completion: @escaping(_ error: String) -> Void){
        do {
            let params = ["accessToken": WCService.currentUser!.accessToken]
            let opt = try HTTP.POST(serviceBase + pathEmailConfirmation, parameters: params)
            opt.start { response in
                if response.error != nil {
                    completion(serverDown)
                    return
                }
                let dict = WCUtils.convertToDictionary(data: response.data)
                if dict!["error"] as! String != "" {
                    completion(dict!["error"]! as! String)
                }else{
                    completion("")
                }
            }
        } catch let error{
            print (error.localizedDescription)
            completion(serverDown)
        }
    }
    
    open class func changePassword(from oldPass: String, to newPass: String,
                                   completion: @escaping(_ error: String, _ accessToken: String) -> Void){
        do {
            let params = ["accessToken": WCService.currentUser!.accessToken, "oldPwd": oldPass, "newPwd": newPass]
            let opt = try HTTP.POST(serviceBase + pathChangePassword, parameters: params)
            opt.start { response in
                if response.error != nil {
                    completion(serverDown, "")
                    return
                }
                let dict = WCUtils.convertToDictionary(data: response.data)
                if dict!["error"] as! String != "" {
                    completion(dict!["error"]! as! String, "")
                }else{
                    completion("", dict!["accessToken"]! as! String)
                }
            }
        } catch let error{
            print (error.localizedDescription)
            completion(serverDown, "")
        }
    }
}
