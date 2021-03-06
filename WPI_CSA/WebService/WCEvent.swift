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
    var description: String
    var startTime: Date
    var endTime: Date
    var location: String
    var fee: Double?
    var ownerId: Int?
    var createdAt: Date?
    var active: Bool
    
    init(id: Int, title: String, startTime: Date, endTime: Date, location: String, active: Bool){
        self.id = id
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.active = active
        self.description = ""
    }
    
}

open class WCEventManager {
    open class func getEvent(withMappingId id: Int, completion: @escaping (_ error: String, _ event: WCEvent?) -> Void) {
        if localMode{
            let mock = RequestMocker.getFakeResponse(forRequestPath: pathGetEvent)
            completion(mock[0] as! String, mock[1] as? WCEvent)
            return
        }
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
                    let startTime = (dict!["startTime"]! as! String).Iso8601DateUTC
                    let endTime = (dict!["endTime"]! as! String).Iso8601DateUTC
                    let location = dict!["location"]! as! String
                    let active = dict!["active"]! as! Bool
                    
                    let event = WCEvent(id: id, title: title, startTime: startTime, endTime: endTime, location: location, active: active)
                    event.ownerId = dict!["ownerId"]! as? Int
                    event.createdAt = (dict!["createdAt"]! as! String).Iso8601DateUTC
                    event.description = dict!["description"]! as! String
                    if let fee = dict!["fee"] as? Double {
                        event.fee = fee
                    }
                    
                    completion("", event)
                }
            }
        } catch let error {
            print(error.localizedDescription)
            completion(serverDown, nil)
        }
    }
}
