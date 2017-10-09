//
//  WCEvent.swift
//  WPI_CSA
//
//  Created by NingFangming on 10/8/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation

open class WCEvent {
    var id: Int
    var title: String
    var startTime: Date
    var endTime: Date
    var location: String
    var ownerId: Int?
    var createdAt: Date?
    
    init(id: Int, title: String, startTime: Date, endTime: Date, location: String){
        self.id = id
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
    }
    
}

open class WCEventManager {
    open class func getEvent(withMappingId id: Int, completion: @escaping (_ error: String, _ event: WCEvent?) -> Void) {
        do {
            let params = ["mappingId" : id]
            let opt = try HTTP.GET(serviceBase + pathGetEvent, parameters: params)
            opt.start{ response in
                if response.error != nil {
                    completion(serverDown, nil)
                    return
                }
                let dict = WCUtils.convertToDictionary(data: response.data)
                if dict!["error"] as! String != "" {
                    completion(dict!["error"]! as! String, nil)
                }else{
                    let id = dict!["id"]! as! Int
                    let title = dict!["title"]! as! String
                    let startTime = (dict!["startTime"]! as! String).dateFromISO8601
                    let endTime = (dict!["endTime"]! as! String).dateFromISO8601
                    let location = dict!["location"]! as! String
                    
                    let event = WCEvent(id: id, title: title, startTime: startTime, endTime: endTime, location: location)
                    event.ownerId = dict!["ownerId"]! as? Int
                    event.createdAt = (dict!["createdAt"]! as! String).dateFromISO8601
                    
                    completion("", event)
                }
            }
        } catch let error {
            print(error.localizedDescription)
            completion(serverDown, nil)
        }
    }
}
