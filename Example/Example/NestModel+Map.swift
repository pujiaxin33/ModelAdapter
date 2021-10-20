//
//  NestModel+Ex.swift
//  Example
//
//  Created by tony on 2021/10/20.
//  Copyright © 2021 jiaxin. All rights reserved.
//

import Foundation
import ObjectMapper

extension NestModel: Mappable {
    
    init?(map: Map) {
        self.init()
    }
    mutating func mapping(map: Map) {
        nestName <- map["nest_name"]
        nestAge <- map["age"]
    }
}
