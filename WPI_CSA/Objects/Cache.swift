//
//  Cache.swift
//  WPI_CSA
//
//  Created by NingFangming on 9/1/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import Foundation

class Cache{
    var id: Int
    var name: String
    var type: CacheType
    var mappingId: Int
    var value: String
    
    init(id: Int, name: String, type: CacheType, mappingId: Int, value: String) {
        self.id = id
        self.name = name
        self.type = type
        self.mappingId = mappingId
        self.value = value
    }
}

enum CacheType: String{
    case Image
    case PDF
    case Menu
}
