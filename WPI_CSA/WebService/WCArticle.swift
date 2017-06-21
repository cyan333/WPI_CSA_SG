//
//  WCArticle.swift
//  WPI_CSA
//
//  Created by NingFangming on 6/20/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation

open class WCArticle {
    var id: Int
    var title: String
    var article: String
    var menuId: Int
    
    init(title: String, article: String, menuId: Int) {
        self.id = -1
        self.title = title
        self.article = article
        self.menuId = menuId
    }
    
    init(id: Int, title: String, article: String, menuId: Int){
        self.id = id
        self.title = title
        self.article = article
        self.menuId = menuId
    }
}

open class WCArticleManager {
    open class func submitArticle(withTitle title: String, andArticle article: String, underMenu menuId: Int,
                                  completion: @escaping (_ error: String) -> Void) {
        do {
            let params = ["accessToken": WCService.currentUser!.accessToken, "title": title,
                          "article": article, "menuId": menuId] as [String : Any?]
            let opt = try HTTP.POST(serviceBase + pathSubmitArticle, parameters: params)
            opt.start { response in
                if response.error != nil {
                    completion(serverDown)
                    return
                }
                let dict = WCUtils.convertToDictionary(data: response.data)
                if dict!["error"] as! String != "" {
                    completion(dict!["error"]! as! String)
                }else{
                    WCService.currentUser!.name = dict!["name"] as! String
                    completion("")
                }
            }
        } catch let error{
            print (error.localizedDescription)
            completion(serverDown)
        }
    }
    
}
