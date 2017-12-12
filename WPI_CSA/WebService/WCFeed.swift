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
    var createdAt: Date
    var ownerId = -1
    var ownerName = ""
    var coverImgId: Int?
    var avatarId: Int?
    
    var event: WCEvent?
    
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
        if localMode {
            let mock = RequestMocker.getFakeResponse(forRequestPath: pathGetRecentFeeds)
            completion(mock[0] as! String, mock[1] as! [WCFeed], mock[2] as? String)
            return
        }
        do {
            var params = ["limit" : String(limit)]
            if let checkPoint = checkPoint {
                params["checkPoint"] = checkPoint
            }
            let opt = try HTTP.GET(serviceBase + pathGetRecentFeeds, parameters: params)
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
                                        if let feedId = feed["id"] as? Int {
                                            wcFeed.id = feedId
                                        }
                                        if let feedTitle = feed["title"] as? String {
                                            wcFeed.title = feedTitle
                                        }
                                        if let feedType = feed["type"] as? String {
                                            wcFeed.type = feedType
                                        }
                                        if let createdAt = (feed["createdAt"] as? String)?.Iso8601DateUTC {
                                            wcFeed.createdAt = createdAt
                                        }
                                        if let ownerId = feed["ownerId"] as? Int {
                                            wcFeed.ownerId = ownerId
                                        }
                                        if let ownerName = feed["ownerName"] as? String {
                                            wcFeed.ownerName = ownerName
                                        }
                                        if let coverImgId = feed["coverImgId"] as? Int {
                                            wcFeed.coverImgId = coverImgId
                                        }
                                        if let avatarId = feed["avatarId"] as? Int {
                                            wcFeed.avatarId = avatarId
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
    
    open class func getFeed(withId id: Int, completion: @escaping (_ error: String, _ feed: WCFeed?) -> Void) {
        if localMode {
            let mock = RequestMocker.getFakeResponse(forRequestPath: pathGetFeed)
            completion(mock[0] as! String, mock[1] as? WCFeed)
            return
        }
        do {
            let params = ["id" : id]
            let opt = try HTTP.GET(serviceBase + pathGetFeed, parameters: params)
            opt.start{ response in
                if response.error != nil {
                    completion(serverDown, nil)
                    return
                }
                let dict = WCUtils.convertToDictionary(data: response.data)
                if let dict = dict {
                    if let error = dict["error"] as? String {
                        if error != "" {
                            completion(error, nil)
                        } else {
                            let id = dict["id"] as! Int
                            let title = dict["title"] as! String
                            let type = dict["type"] as! String
                            let body = dict["body"] as! String
                            let createdAt = (dict["createdAt"] as! String).Iso8601DateUTC
                            let feed = WCFeed(id: id, title: title, type: type, body: body, createdAt: createdAt)
                            
                            if let eventDic = dict["event"] as? [String : Any] {
                                let id = eventDic["id"] as! Int
                                let title = eventDic["title"] as! String
                                let startTime = (eventDic["startTime"] as! String).Iso8601DateUTC
                                let endTime = (eventDic["endTime"] as! String).Iso8601DateUTC
                                let location = eventDic["location"] as! String
                                
                                let event = WCEvent(id: id, title: title, startTime: startTime,
                                                    endTime: endTime, location: location)
                                event.ownerId = eventDic["ownerId"] as? Int
                                event.createdAt = (eventDic["createdAt"] as! String).Iso8601DateUTC
                                event.description = eventDic["description"] as! String
                                if let fee = eventDic["fee"] as? Double {
                                    event.fee = fee
                                }
                                
                                feed.event = event
                            }
                            completion("", feed)
                        }
                    }
                } else {
                    completion(respondFormatError, nil)
                }
            }
        } catch let error {
            print(error.localizedDescription)
            completion(serverDown, nil)
        }
    }
    
    open class func createFeed(withTitiele title: String, type: String, body: String, coverImageString: String?,
                               completion: @escaping (_ error: String) -> Void) {
        do {
            var params = ["accessToken": WCService.currentUser!.accessToken!, "title": title, "type": type, "body": body]
            if let coverImageString = coverImageString {
                params["coverImage"] = coverImageString
            }
            let opt = try HTTP.POST(serviceBase + pathCreateFeed , parameters: params)
            opt.start{ response in
                if response.error != nil {
                    completion(serverDown)
                    return
                }
                let dict = WCUtils.convertToDictionary(data: response.data)
                if dict!["error"] as! String != "" {
                    completion(dict!["error"]! as! String)
                }else{
                    completion("")
                }
            }
        } catch let error {
            print(error.localizedDescription)
            completion(serverDown)
        }
    }
    
}
