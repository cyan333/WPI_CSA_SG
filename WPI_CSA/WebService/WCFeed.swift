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
    var ownerId = -1
    var ownerName = ""
    var createdAt: Date
    
    init(id: Int, title: String, type: String, body: String, createdAt: Date){
        self.id = id
        self.title = title
        self.type = type
        self.body = body
        self.createdAt = createdAt
    }
    
    init() {
        self.id = -1
        self.title = ""
        self.type = ""
        self.body = ""
        self.createdAt = Date()
    }
}

open class WCFeedManager {
    
    //This method needs to be error proof
    open class func getRecentFeeds(withLimit limit: Int, andCheckPoint checkPoint: String?,
                             completion: @escaping (_ error: String, _ feedList: [WCFeed],
                                                    _ checkPoint: String?) -> Void) {
        do {
            var params = ["limit" : String(limit)]
            if let checkPoint = checkPoint {
                params["checkPoint"] = checkPoint
            }
            let opt = try HTTP.GET(serviceBase + pathGetFeeds, parameters: params)
            var feedList = [WCFeed]()
            opt.start{ response in
                if response.error != nil {
                    completion(serverDown, feedList, nil)
                    return
                }
                let dict = WCUtils.convertToDictionary(data: response.data)
                if let dict = dict {
                    if let error = dict["error"] as? String {
                        if error != "" {
                            completion(error, feedList, nil)
                        } else {
                            if let rawList = dict["feedList"] as? [Any] {
                                for feed in rawList {
                                    if let feed = feed as? [String: Any] {
                                        let wcFeed = WCFeed()
                                        if let feedId = feed["feedId"] as? Int {
                                            wcFeed.id = feedId
                                        }
                                        if let feedTitle = feed["feedTitle"] as? String {
                                            wcFeed.title = feedTitle
                                        }
                                        if let feedType = feed["feedType"] as? String {
                                            wcFeed.type = feedType
                                        }
                                        if let feedBody = feed["feedBody"] as? String {
                                            wcFeed.body = feedBody
                                        }
                                        if let createdAt = (feed["createdAt"] as? String)?.dateFromISO8601 {
                                            wcFeed.createdAt = createdAt
                                        }
                                        if let ownerId = feed["ownerId"] as? Int {
                                            wcFeed.ownerId = ownerId
                                        }
                                        if let ownerName = feed["ownerName"] as? String {
                                            wcFeed.ownerName = ownerName
                                        }
                                        feedList.append(wcFeed)
                                    }
                                }
                                completion("", feedList, dict["checkPoint"] as? String)
                            } else {
                                completion(respondFormatError, feedList, nil)
                            }
                        }
                    }
                } else {
                    completion(respondFormatError, feedList, nil)
                }
            }
        } catch let error {
            print(error.localizedDescription)
            completion(serverDown, [WCFeed](), nil)
        }
    }
    
}
