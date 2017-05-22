//
//  WCUtils.swift
//  WPI_CSA
//
//  Created by NingFangming on 5/5/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation

//let serviceBase = "https://wcservice.fmning.com/" //*****************PROD
let serviceBase = "http://wc.fmning.com/" //********************TEST

let pathGetSalt = "login_for_salt"
let pathLogin = "login"
let pathGetUserDetails = "get_user_detail"
let pathSetUserDetails = "save_current_user_detail"
let pathEmailConfirmation = "send_email_confirmation"
let pathChangePassword = "change_password"
let pathRegisterSalt = "register_for_salt"
let pathRegister = "register"

let softwareVersion = "0.00"

let serverDown = "Server down"
//let HTTPError = "Http API error"
let respondFormatError = "Incorrect respond format"

open class WCUtils{
    open class func convertToDictionary(data: Data) -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    
    open class func md5(_ string: String) -> String {
        
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, string, CC_LONG(string.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate(capacity: 1)
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        
        return hexString
    }
    
}
