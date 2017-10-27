//
//  WCUtils.swift
//  WPI_CSA
//
//  Created by NingFangming on 5/5/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation

let serviceBase = "https://wcservice.fmning.com/" //*****************PROD
//let serviceBase = "http://wc.fmning.com/" //********************TEST

//If enabled, most of the HTTP request will return faked local value, instead of making network calls
let localMode = false

/*
   Web request URL standard:
   Create: create a new object and save to db
   Update: update an existing object
   Get: retrieve an existing object
   Save: create a new object if does not exist. update if it exists
*/
let pathGetVersionInfo = "get_version_info"
let pathGetSalt = "login_for_salt"
let pathLogin = "login"
let pathRegisterSalt = "register_for_salt"
let pathRegister = "register"
let pathSaveUserDetails = "save_user_detail"
let pathSendVerificationEmail = "send_verification_email"
let pathChangePassword = "update_password"
let pathCreateReport = "create_sg_report"
let pathCreateArticle = "create_sg_article"
let pathGetImage = "get_image"
let pathSaveTUImage = "save_type_unique_image"
let pathGetRecentFeeds = "get_recent_feeds"
let pathGetEvent = "get_event"
let pathGetFeed = "get_feed"
let pathGetTicket = "get_ticket"
let pathMakePayment = "make_payment"


let serverDown = "Server down"
let respondFormatError = "Incorrect respond format"
let noMoreFeedsError = "There are no more feeds."
let noEventError = "The event you are looking for does not exist."

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
