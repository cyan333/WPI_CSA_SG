//
//  WCUtils.swift
//  WPI_CSA
//
//  Created by NingFangming on 5/5/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation

let prodMode = true;

let serviceBase = prodMode ? "https://wcservice.fmning.com/" : "http://wc.fmning.com/"

let clientToken = prodMode ? "production_sbqbjrph_vbwwmgd2tn8gkg9m" : "sandbox_bk8pdqf3_wnbj3bx4nwmtyz77"

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
let pathLogin = "login"
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
let pathCheckPaymentStatus = "check_payment_status"
let pathCreateFeed = "create_feed"
let pathResetPassword = "send_change_pwd_email"


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
    
    
    open class func checkAndSaveAccessToken(dict: [String : Any]?) {
        
        if let dict = dict {
            if let accessToken = dict["accessToken"] as? String {
                WCService.currentUser?.accessToken = accessToken
                Utils.setParam(named: savedAccessToken, withValue: accessToken)// Is it really good to involve Utils here?
            }
        }
    }
    
}
