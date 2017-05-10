//
//  WCUtil.swift
//  WPI_CSA
//
//  Created by NingFangming on 5/5/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation

//let serviceBase = "http://wcservice.fmning.com/" //*****************PROD
let serviceBase = "https://wc.fmning.com/" //********************TEST

let softwareVersion = "1.00"

let serverDown = "Server down"
let HTTPError = "Http API error"
let respondFormatError = "Incorrect respond format"

open class WCUtil{
    open class func convertToDictionary(data: Data) -> [String: String]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}
