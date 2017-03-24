//
//  Menu.swift
//  WPI_SG
//
//  Created by NingFangming on 3/23/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation

class Menu{
    var id : Int
    var name : String
    var isOpened : Bool
    var childMenus : [Menu]
    
    init(id : Int, name : String) {
        self.id = id
        self.name = name
        self.isOpened = false
        self.childMenus = []
    }
}
