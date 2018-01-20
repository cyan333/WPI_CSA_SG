//
//  WCUser.swift
//  WPI_CSA
//
//  Created by NingFangming on 5/11/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation
import UIKit

open class WCUser{
    var username: String?
    var accessToken: String?
    var avatarId: Int?
    var emailConfirmed = true
    var name = ""
    var birthday = ""
    var classOf = ""
    var major = ""
    
    init(username: String, accessToken: String){
        self.username = username
        self.accessToken = accessToken
    }
}

open class WCUserManager{
    
    open class func loginUser(withAccessToken accessToken: String? = nil, withUsername username: String? = nil,
                              andPassword password: String? = nil,
                              completion: @escaping (_ error: String, _ user: WCUser?) -> Void){
        if localMode {
            let mock = RequestMocker.getFakeResponse(forRequestPath: pathLogin)
            completion(mock[0] as! String, mock[1] as? WCUser)
            return
        }
        do {
            var params: [String: String]
            if let accessToken = accessToken {
                params = ["accessToken" : accessToken]
            } else {
                params = ["username" : username!, "password" : password!]
            }
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
                    let user = WCUser(username: dict!["username"] as! String, accessToken: dict!["accessToken"] as! String)
                    user.emailConfirmed = dict!["emailConfirmed"] as! Bool
                    if let name = dict!["name"] as? String {
                        user.name = name
                    }
                    if let birthday = dict!["birthday"] as? String {
                        user.birthday = birthday
                    }
                    if let classOf = dict!["year"] as? String {
                        user.classOf = classOf
                    }
                    if let major = dict!["major"] as? String {
                        user.major = major
                    }
                    if let avatarId = dict!["avatarId"] as? Int {
                        user.avatarId = avatarId
                    }
                    if user.name == "" {user.name = "Unknown"}
                    
                    WCService.currentUser = user
                    WCUtils.checkAndSaveAccessToken(dict: dict)
                    completion("", user)
                }
            }
        } catch let error{
            print (error.localizedDescription)
            completion(serverDown, nil)
        }
    }
    
    open class func register(forUsername username: String, andPassword password: String, andName name: String, andBirthday birthday: String?,
                             andClassOd classOf: String?, andMajor major: String?, avatar: UIImage?, targetSize: Int? = nil,
                             completion: @escaping(_ error: String, _ user: WCUser?) -> Void){
        do {
            var params = ["username": username, "password": password, "name": name]
            if let birthday = birthday {
                params["birthday"] = birthday
            }
            if let classOf = classOf {
                params["year"] = classOf
            }
            if let major = major {
                params["major"] = major
            }
            if let avatar = avatar {
                var compressRate: CGFloat = 1
                if let targetSize = targetSize {
                    compressRate = avatar.compressRateForSize(target: targetSize)
                }
                let imageData = UIImageJPEGRepresentation(avatar, compressRate)!
                let base64 = imageData.base64EncodedString()
                params["avatar"] = base64
            }
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
                    let user = WCUser(username: username, accessToken: dict!["accessToken"] as! String)
                    user.emailConfirmed = false
                    user.name = name
                    user.birthday = birthday ?? ""
                    user.classOf = classOf ?? ""
                    user.major = major ?? ""
                    if let avatarId = dict!["imageId"] as? Int {
                        user.avatarId = avatarId
                    }
                    
                    WCService.currentUser = user
                    WCUtils.checkAndSaveAccessToken(dict: dict)
                    completion("", user)
                }
            }
        } catch let error{
            print (error.localizedDescription)
            completion(serverDown, nil)
        }
    }
    
    //version 1.10 migration
    open class func loginMigration(forUsername username: String, andEncryptedPassword password: String,
                                   completion: @escaping(_ error: String, _ accessToken: String?) -> Void){
        do {
            let params = ["username" : username, "password" : password]
            let opt = try HTTP.POST(serviceBase + "login_migration", parameters: params)
            opt.start { response in
                if response.error != nil {
                    completion(serverDown, nil)
                    return
                }
                let dict = WCUtils.convertToDictionary(data: response.data)
                if dict!["error"] as! String != "" {
                    completion(dict!["error"]! as! String, nil)
                }else{
                    WCUtils.checkAndSaveAccessToken(dict: dict)
                    completion("", dict!["accessToken"]! as? String)
                }
            }
        } catch let error{
            print (error.localizedDescription)
            completion(serverDown, nil)
        }
    }
    
    open class func saveCurrentUserDetails(name: String?, birthday: String?, classOf: String?, major: String?, avatar: UIImage?,
                                           targetSize: Int? = nil, completion: @escaping (_ error: String, _ imgId: Int?) -> Void){
        if localMode {
            let mock = RequestMocker.getFakeResponse(forRequestPath: pathSaveUserDetails)
            completion(mock[0] as! String, mock[1] as? Int)
            return
        }
        do {
            var params = ["accessToken": WCService.currentUser!.accessToken]
            if let name = name {
                params["name"] = name
            }
            if let birthday = birthday {
                params["birthday"] = birthday
            }
            if let classOf = classOf {
                params["year"] = classOf
            }
            if let major = major {
                params["major"] = major
            }
            if let avatar = avatar {
                var compressRate: CGFloat = 1
                if let targetSize = targetSize {
                    compressRate = avatar.compressRateForSize(target: targetSize)
                }
                let imageData = UIImageJPEGRepresentation(avatar, compressRate)!
                let base64 = imageData.base64EncodedString()
                params["avatar"] = base64
            }
            
            if params.count == 1 {
                completion("No user details to be saved", nil)
                return
            }
            
            let opt = try HTTP.POST(serviceBase + pathSaveUserDetails, parameters: params)
            opt.start { response in
                if response.error != nil {
                    completion(serverDown, nil)
                    return
                }
                let dict = WCUtils.convertToDictionary(data: response.data)
                if dict!["error"] as! String != "" {
                    completion(dict!["error"]! as! String, nil)
                }else{
                    var imgId: Int? = nil
                    if let newId = dict!["imageId"] as? Int {
                        imgId = newId
                        WCService.currentUser?.avatarId = imgId
                    }
                    WCService.currentUser?.name = name ?? ""
                    WCService.currentUser?.birthday = birthday ?? ""
                    WCService.currentUser?.classOf = classOf ?? ""
                    WCService.currentUser?.major = major ?? ""
                    
                    completion("", imgId)
                }
            }
        } catch let error{
            print (error.localizedDescription)
            completion(serverDown, nil)
        }
    }
    
    open class func sendEmailConfirmation(completion: @escaping(_ error: String) -> Void){
        do {
            let params = ["accessToken": WCService.currentUser!.accessToken]
            let opt = try HTTP.POST(serviceBase + pathSendVerificationEmail, parameters: params)
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
                                   completion: @escaping(_ error: String) -> Void){
        do {
            let params = ["accessToken": WCService.currentUser!.accessToken, "oldPwd": oldPass, "newPwd": newPass]
            let opt = try HTTP.POST(serviceBase + pathChangePassword, parameters: params)
            opt.start { response in
                if response.error != nil {
                    completion(serverDown)
                    return
                }
                let dict = WCUtils.convertToDictionary(data: response.data)
                if dict!["error"] as! String != "" {
                    completion(dict!["error"]! as! String)
                }else{
                    WCUtils.checkAndSaveAccessToken(dict: dict)
                    completion("")
                }
            }
        } catch let error{
            print (error.localizedDescription)
            completion(serverDown)
        }
    }
}
