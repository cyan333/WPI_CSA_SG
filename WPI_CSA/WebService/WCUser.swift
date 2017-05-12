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
    
    init(withId id: Int){
        self.id = id
    }
    
    init(withId id: Int, andUsername username: String, andAccessToken accessToken: String){
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
                let dict = WCUtil.convertToDictionary(data: response.data)
                if dict!["error"]! != "" {
                    print(dict!["error"]!, "")
                }else{
                    completion("", dict!["salt"]!)
                }
            }
        } catch let error{
            print (error.localizedDescription)
            completion(serverDown, "")
        }
    }
    
    open class func loginUser(withUsername username: String, andPassword password: String, andSalt salt: String,
                              completion: @escaping (_ user: WCUser) -> Void){
        
    }
    
    
    
}
