//
//  Menu.swift
//  WPI_SG
//
//  Created by NingFangming on 3/23/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation

class Menu{
    var id: Int
    var name: String
    var isOpened: Bool
    var isParentMenu: Bool
    var subMenus: [Menu]
    
    init(id : Int, name : String) {
        self.id = id
        self.name = name
        self.isOpened = false
        self.isParentMenu = false
        self.subMenus = []
    }
    /*Sample:
     {"id" : "1",
      "name" : "Chapter 1",
      "isParentMenu" : "true",
      "subMenus" : [{}, {}]
     }
     */
    func toJson() -> String{
        var jsonStr = ""
        jsonStr += "{\"id\":\"\(id)\",\"name\":\"\(name)\",\"isParentMenu\":\"\(isParentMenu)\","
        jsonStr += "\"subMenus\":["
        for m in subMenus as [Menu]{
            jsonStr += m.toJson()
            jsonStr += ","
        }
        if (isParentMenu){
            jsonStr = jsonStr.substring(to: jsonStr.index(before: jsonStr.endIndex))
        }
        jsonStr += "]}"
        
        return jsonStr
    }
}
