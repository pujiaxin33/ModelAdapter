//
//  NestModel.swift
//  Example
//
//  Created by tony on 2021/10/20.
//  Copyright © 2021 jiaxin. All rights reserved.
//

import Foundation
import ModelAdaptor
import SQLiteValueExtension
import SQLite

struct NestModel: ModelAdaptorModel, SQLiteValueStorable {
    @FieldOptional(key: "nest_name")
    var nestName: String?
    @Field(key: "age")
    var nestAge: Int = 0

    init() {
        initFieldExpressions()
    }

    static func fromStringValue(_ stringValue: String) -> NestModel {
        return NestModel(JSONString: stringValue) ?? NestModel(JSON: [String : Any]())!
    }
    var stringValue: String {
        return toJSONString() ?? ""
    }
}
