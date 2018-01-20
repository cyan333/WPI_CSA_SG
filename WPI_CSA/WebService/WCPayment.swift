//
//  WCPayment.swift
//  WPI_CSA
//
//  Created by Fangming Ning on 10/22/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation
import PassKit

open class WCPaymentManager{
    
    open class func checkPaymentStatus(for type: String, withId id: Int,
                                completion: @escaping (_ error: String, _ status: String, _ ticketId: Int?) -> Void) {
        do {
            let params = ["type": type, "id" : id,
                          "accessToken": WCService.currentUser!.accessToken!] as [String : Any]
            let opt = try HTTP.POST(serviceBase + pathCheckPaymentStatus , parameters: params)
            opt.start{ response in
                if response.error != nil {
                    completion(serverDown, "", nil)
                    return
                }
                let dict = WCUtils.convertToDictionary(data: response.data)
                if dict!["error"] as! String != "" {
                    completion(dict!["error"]! as! String, "", nil)
                }else{
                    guard let status = dict!["status"] as? String else {
                        completion(respondFormatError, "", nil)
                        return
                    }
                    WCUtils.checkAndSaveAccessToken(dict: dict)
                    let ticketId = dict!["ticketId"] as? Int
                    completion("", status, ticketId)
                }
            }
        } catch let error {
            print(error.localizedDescription)
            completion(serverDown, "", nil)
        }
    }
    
    
    open class func makePayment(for type: String, withId id: Int, paying amount: Double, using method: String? = nil, withToken nonce: String? = nil,
                                completion: @escaping (_ error: String, _ status: String, _ ticketId: Int?, _ ticket: PKPass?) -> Void) {
        do {
            var params = ["type": type, "id" : id, "amount" : amount,
                          "accessToken": WCService.currentUser!.accessToken!] as [String : Any]
            if let method = method {
                params["method"] = method
                params["nonce"] = nonce ?? "Unknown"
            }
            let opt = try HTTP.POST(serviceBase + pathMakePayment , parameters: params)
            opt.start{ response in
                if response.error != nil {
                    completion(serverDown, "", nil, nil)
                    return
                }
                let dict = WCUtils.convertToDictionary(data: response.data)
                if dict!["error"] as! String != "" {
                    completion(dict!["error"]! as! String, "", nil, nil)
                }else{
                    guard let status = dict!["status"] as? String else {
                        completion(respondFormatError, "", nil, nil)
                        return
                    }
                    let ticketId = dict!["ticketId"] as? Int
                    let ticketStr = dict!["ticket"] as? String
                    WCUtils.checkAndSaveAccessToken(dict: dict)
                    WCUtils.checkAndSaveAccessToken(dict: dict)
                    if ticketStr != nil {
                        var error: NSError?
                        let ticket = PKPass(data: Data(base64Encoded:ticketStr!, options: .ignoreUnknownCharacters)!, error: &error)
                        
                        if error == nil {
                            completion("", status, ticketId, ticket)
                        } else {
                            completion("Payment processed correctly but ticket failed to be created. " + (error?.localizedDescription ?? "Unknown error.")
                                + " Please contact admin@fmning.com", "", ticketId, nil)
                        }
                    } else {
                        completion("", status, ticketId, nil)
                    }
                    
                    
                }
            }
        } catch let error {
            print(error.localizedDescription)
            completion(serverDown, "", nil, nil)
        }
    }
}
