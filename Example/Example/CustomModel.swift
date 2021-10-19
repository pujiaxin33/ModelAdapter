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
import SQLiteValueExtension

class CustomModel: ModelAdaptorModel, Mappable {
    @Field(key: "accountID_key", primaryKey: .default)
    var accountID: String = ""
    @FieldOptional(key: "nick_name")
    var nickName: String?
    var amount: Double = 6
    @FieldOptional
    var phone: String?
    @FieldOptional
    var gender: Gender?
    @FieldOptional(key: "birthday")
    var birthday: Date?
    //`Array.Element`、`Dictionary.Key`、`Dictionary.Value`和自定义数据类型遵从`SQLiteValueStringExpressible`协议，就可以通过`SQLite.swift`存储到数据库。
    @Field
    var nest: NestModel = NestModel(JSON: [String : Any]())!
    @Field
    var nests: [NestModel] = [NestModel]()
    @FieldOptional
    var customDict: [String: NestModel]?
    @FieldOptional
    var customDictInt: [Int : NestModel]?
    @FieldOptional
    var customDictAarray: [String: [NestModel]]?
    
    //如果值类型没有遵从`SQLiteValueStringExpressible`，就不能使用@Field。需要遵从`ModelAdaptorModelCustomStorage`协议，然后自己处理数据的存储流程。
    var customSet: Set<String>? = nil
    
    required init() {
        initExpressionsIfNeeded()
    }
    required init?(map: Map) {
        initExpressionsIfNeeded()
    }
    func mapping(map: Map) {
        accountID <- map["accountID_key"]
        nickName <- map["nick_name"]
        amount <- map["amount"]
        phone <- map["phone"]
        gender <- map["gender"]
        birthday <- (map["birthday_coding"], DateTransform())
        nest <- map["nest"]
        nests <- map["nests"]
        customDict <- map["custom_dict"]
        customDictAarray <- map["custom_dict_array"]
        customDictInt <- map["custom_dict_int"]
        customSet <- map["custom_set"]
    }
}


struct NestModel: ModelAdaptorModel, SQLiteValueStorable, Mappable {
    @FieldOptional(key: "nest_name")
    var nestName: String?
    @Field(key: "age")
    var nestAge: Int = 0

    init() {
        initExpressionsIfNeeded()
    }
    init?(map: Map) {
        initExpressionsIfNeeded()
    }
    mutating func mapping(map: Map) {
        nestName <- map["nest_name"]
        nestAge <- map["age"]
    }

    static func fromStringValue(_ stringValue: String) -> NestModel {
        return NestModel(JSONString: stringValue) ?? NestModel(JSON: [String : Any]())!
    }
    var stringValue: String {
        return toJSONString() ?? ""
    }
}

enum Gender: String, SQLiteValueStorable {
    case unknow = "UnKnown"
    case female = "Female"
    case male = "Male"

    static func fromStringValue(_ stringValue: String) -> Gender {
        return Gender(rawValue: stringValue) ?? .unknow
    }
    var stringValue: String {
        return rawValue
    }
}
