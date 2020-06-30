//
//  CustomModel.swift
//  Example
//
//  Created by jiaxin on 2020/6/14.
//  Copyright © 2020 jiaxin. All rights reserved.
//

import Foundation
import ModelAdaptor
import ObjectMapper
import SQLite

enum Gender: String, SQLiteValueProvider {
    case unknow = "UnKnown"
    case female = "Female"
    case male = "Male"

    typealias SQLiteValue = String
    init?(value: String) {
        self.init(rawValue: value)
    }
    func value() -> String? {
        return self.rawValue
    }
}

class CustomModel: ModelAdaptorModel {
    @FieldOptional(key: "accountID_key", storageParams: nil)
    var accountID: Int?
    @Field(codingParams: .init(key: nil, convertor: NilTransform<String>(), nested: nil, delimiter:  ".", ignoreNil:  false), storageParams: .init(key: nil))
    var userName: String = "名字"
    @FieldOptional(key: "nick_name")
    var nickName: String?
    @Field(key: "amount", storageParams: .init(defaultValue: 100))
    var amount: Double = 6
    @FieldOptional
    var phone: String?
    @FieldOptional
    var gender: Gender?
    @FieldOptional(codingParams: .init(key: "avatar_key", convertor: NilTransform<String>()))
    var avatar: String?
    @FieldOptional(key: "birthday", codingParams: .init(key: "birthday_coding", convertor:  DQDateTransform()))
    var birthday: Date?
    @Field(key: "level")
    var vipLevel: Int = 1
    @Field
    var levelPoints: Int = 0
    @FieldOptional
    var downPoints: Int?
    @Field(codingParams: .init(convertor: DQDateTransform()))
    var registerDate: Date = Date()   //注册时间，格式（2018-04-09 10:12:42 000）
    @Field(wrappedValue: false, key: "hasFundsPassword")
    var isExchangePasswordValid: Bool
    @Field
    var nest: NestModel = NestModel(JSON: [String : Any]())!

    required init() {}
    required init?(map: Map) { }
}


struct NestModel: ModelAdaptorModel, SQLiteValueProvider {
    @FieldOptional(key: "nest_name")
    var nestName: String?
    @Field(key: "age")
    var nestAge: Int = 0

    init?(map: Map) {
    }

    init() {}

    typealias SQLiteValue = String
    init?(value: String) {
        self.init(JSONString: value)
    }

    func value() -> String? {
        return self.toJSONString()
    }
}

