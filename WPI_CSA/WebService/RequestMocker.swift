//
//  RequestMocker.swift
//  WPI_CSA
//
//  Created by NingFangming on 10/5/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation

open class RequestMocker {
    open class func getFakeResponse(forRequestPath path: String) -> [Any] {
        switch path {
        case pathGetVersionInfo:
            return ["OK", "", "", "", ""]
        case pathGetRecentFeeds:
            let feed1 = WCFeed(id: 9, title: "Title 9", type: "Event",
                               body: "Create red by user 11 i.e. Myself",
                               createdAt: "2017-02-21T02:12:21.534Z".Iso8601DateUTC)
            feed1.ownerId = 11
            feed1.ownerName = "Fangming Ning"
            feed1.avatarId = 41
            feed1.coverImgId = 20
            
            let feed2 = WCFeed(id: 3, title: "Title 3", type: "Event",
                               body: "Moment test 3 with very long description like this hahahahahaha hahahahahahahhaha hahahahhaha wa haha very long line1line2\\nline3line4\\nline5",
                               createdAt: "2017-01-09T17:34:12.215Z".Iso8601DateUTC)
            feed2.ownerId = 4
            feed2.ownerName = "Amy"
            feed2.avatarId = 13
            feed2.coverImgId = 35
            return ["", [feed1, feed2], ""]
        case pathGetFeed:
            let feed = WCFeed(id: 9, title: "Title 9", type: "Event",
                               body: "Create red by user 11 i.e. Myself",
                               createdAt: "2017-02-21T02:12:21.534Z".Iso8601DateUTC)
            feed.ownerId = 11
            feed.ownerName = "Fangming Ning"
            feed.avatarId = 41
            feed.coverImgId = 20
            
            let sTime = "2018-04-10T22:00:00Z".Iso8601DateUTC
            let eTime = "2018-04-11T02:00:00Z".Iso8601DateUTC
            let event = WCEvent(id: 1, title: "Dragon night 2018", startTime: sTime, endTime: eTime,
                                location: "Aldem Hall", active: true)
            event.ownerId = 11
            event.createdAt = "2017-10-15T23:01:31.732580Z".Iso8601DateUTC
            event.description = "This is dragon night event for 2018, hosted by CSA. There will be chinese shows and food."
            event.fee = 0
            
            feed.event = event
            return ["", feed]
        case pathGetEvent:
            let sTime = "2018-04-10T22:00:00Z".Iso8601DateUTC
            let eTime = "2018-04-11T02:00:00Z".Iso8601DateUTC
            let event = WCEvent(id: 1, title: "Dragon night 2018", startTime: sTime, endTime: eTime,
                                location: "Aldem Hall", active: true)
            event.ownerId = 11
            event.createdAt = "2017-10-15T23:01:31.732580Z".Iso8601DateUTC
            event.description = "This is dragon night event for 2018, hosted by CSA. There will be chinese shows and food."
            event.fee = 0
            
            return ["", event]
        case pathLogin:
            let user = WCUser(username: "fning@wpi.edu", accessToken: "token")
            user.emailConfirmed = true
            user.name = "Fangming Ning"
            return ["", user]
        case pathSaveUserDetails:
            return ["", 1]
        default:
            return []
        }
    }
}
