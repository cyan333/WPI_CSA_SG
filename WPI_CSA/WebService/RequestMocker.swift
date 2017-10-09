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
        case pathGetFeeds:
            let feed1 = WCFeed(id: 9, title: "Title 9", type: "Event",
                               body: "Create red by user 11 i.e. Myself",
                               createdAt: "2017-02-21T02:12:21.534Z".dateFromISO8601)
            feed1.ownerId = 11
            feed1.ownerName = "Fangming Ning"
            feed1.avatarId = 41
            feed1.coverImgId = 20
            
            let feed2 = WCFeed(id: 3, title: "Title 3", type: "Event",
                               body: "Moment test 3 with very long description like this hahahahahaha hahahahahahahhaha hahahahhaha wa haha very long line1line2\\nline3line4\\nline5",
                               createdAt: "2017-01-09T17:34:12.215Z".dateFromISO8601)
            feed2.ownerId = 4
            feed2.ownerName = "Amy"
            feed2.avatarId = 13
            feed2.coverImgId = 35
            return ["", [feed1, feed2], ""]
        default:
            return []
        }
    }
}
