//
//  WCFeed.swift
//  WPI_CSA
//
//  Created by NingFangming on 9/18/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation

open class WCFeed {
    var id: Int
    var title: String
    var type: String
    var body: String
    var createdAt: Int
    
    init(id: Int, title: String, type: String, body: String, createdAt: Int){
        self.id = id
        self.title = title
        self.type = type
        self.body = body
        self.createdAt = createdAt
    }
}

open class WCFeedManager {
    
    open class func getRecentFeeds(withLimit limit: Int, andCheckPoint checkPoint: String?,
                             completion: @escaping (_ error: String, _ feedList: [WCFeed]?,
                                                    _ checkPoint: String) -> Void) {
        do {
            var params = ["limit" : "5"]
            if let checkPoint = checkPoint {
                params["checkPoint"] = checkPoint
            }
            let opt = try HTTP.GET(serviceBase + pathGetFeeds, parameters: params)
            opt.start{ response in
                let dict = WCUtils.convertToDictionary(data: response.data)
                dump(dict)
            }
        } catch let error {
            print(error.localizedDescription)
            completion(serverDown, nil, "")
        }
    }
    
}
