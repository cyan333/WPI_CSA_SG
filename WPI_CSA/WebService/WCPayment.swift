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
    open class func makePayment(for type: String, withId id: Int, paying amount: Double,
                                completion: @escaping (_ error: String, _ status: String, _ ticketStatus: String,
                                                       _ ticketId: Int?, _ ticket: PKPass?) -> Void) {
        do {
            let params = ["type": type, "id" : id, "amount" : amount,
                          "accessToken": WCService.currentUser!.accessToken!] as [String : Any]
            let opt = try HTTP.POST(serviceBase + pathMakePayment , parameters: params)
            opt.start{ response in
                if response.error != nil {
                    completion(serverDown, "", "", nil, nil)
                    return
                }
                let dict = WCUtils.convertToDictionary(data: response.data)
                if dict!["error"] as! String != "" {
                    completion(dict!["error"]! as! String, "", "", nil, nil)
                }else{
                    guard let status = dict!["status"] as? String else {
                        completion(respondFormatError, "", "", nil, nil)
                        return
                    }
                    guard let ticketStatus = dict!["ticketStatus"] as? String else {
                        completion(respondFormatError, "", "", nil, nil)
                        return
                    }
                    let ticketId = dict!["ticketId"] as? Int
                    let ticketStr = dict!["ticket"] as? String
                    //var ticket: PKPass?
                    if ticketStr != nil {
                        var error: NSError?
                        let ticket = PKPass(data: Data(base64Encoded:ticketStr!, options: .ignoreUnknownCharacters)!, error: &error)
                        
                        if error == nil {
                            completion("", status, ticketStatus, ticketId, ticket)
                        } else {
                            completion("", status, error?.localizedDescription ?? "Unknown error."
                                + " Please contact admin@fmning.com", ticketId, nil)
                        }
                    } else {
                        completion("", status, ticketStatus, ticketId, nil)
                    }
                    
                    
                }
            }
        } catch let error {
            print(error.localizedDescription)
            completion(serverDown, "", "", nil, nil)
        }
    }
}
