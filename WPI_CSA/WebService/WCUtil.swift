//
//  WCUtil.swift
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
let pathUserDetails = "get_user_detail"

let softwareVersion = "0.00"

let serverDown = "Server down"
let HTTPError = "Http API error"
let respondFormatError = "Incorrect respond format"

open class WCUtil{
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
