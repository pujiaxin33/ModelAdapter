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

enum Gender: String, SQLiteValueProvider {
    case unknow = "UnKnown"
    case female = "Female"
    case male = "Male"

    typealias SQLiteValue = String
    init?(value: SQLiteValue) {
        self.init(rawValue: value)
    }
    func value() -> SQLiteValue? {
        return self.rawValue
    }
    init?(stringValue: String) {
        self.init(rawValue: stringValue)
    }
    func stringValue() -> String? {
        return self.rawValue
    }
}

class CustomModel: ModelAdaptorModel {
    @FieldOptional(key: "accountID_key")
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
    @FieldCustom
    var nests: [NestModel] = [NestModel]()
    @FieldCustom
    var customDict: [String: NestModel]?
    @FieldCustom
    var customDictAarray: [String: [NestModel]]?
    var customDictInt: [Int : NestModel]?//完全需要自己去处理map和storage


    required init() {
        //必须在required的初始化器调用initExpressionsIfNeeded方法
        initExpressionsIfNeeded()
    }
    required init?(map: Map) {
        //必须在required的初始化器调用initExpressionsIfNeeded方法
        initExpressionsIfNeeded()
    }

    func customMap(map: Map) {
//        self.nests <- map["nests"]
        self.customDict <- map["custom_dict"]
        self.customDictAarray <- map["custom_dict_array"]
        self.customDictInt <- (map["custom_dict_int"], IntDictTransform())
    }
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
    init?(value: SQLiteValue) {
        self.init(JSONString: value)
    }
    func value() -> SQLiteValue? {
        return self.toJSONString()
    }

    init?(stringValue: String) {
        self.init(JSONString: stringValue)
    }

    func stringValue() -> String? {
        return self.toJSONString()
    }
}

struct IntDictTransform: TransformType {
    typealias Object = [Int : NestModel]
    typealias JSON = String

    func transformFromJSON(_ value: Any?) -> [Int : NestModel]? {
        guard let dict = value as? [Int : [String: Any]] else {
            return nil
        }
        var result = [Int : NestModel]()
        for (key, dictValue) in dict {
            guard let model = NestModel(JSON: dictValue) else {
                continue
            }
            result[key] = model
        }
        return result
    }

    func transformToJSON(_ value: [Int : NestModel]?) -> String? {
        guard let dict = value else {
            return nil
        }
        var result = [Int: String]()
        for (key, value) in dict {
            guard let string = value.stringValue() else {
                continue
            }
            result[key] = string
        }
        guard let data = try? JSONSerialization.data(withJSONObject: result, options: []) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
