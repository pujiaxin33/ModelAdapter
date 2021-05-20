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

    init?(value: String) {
        self.init(rawValue: value)
    }
    func value() -> String? {
        return self.rawValue
    }
    init?(stringValue: String) {
        self.init(rawValue: stringValue)
    }
    func stringValue() -> String? {
        return value()
    }
}

class CustomModel: ModelAdaptorModel {
    @FieldOptional(key: "accountID_key", storageParams: .init(primaryKey: true))
    var accountID: String?
    //这里的NilTransform<String>仅仅起到一个防止编译器报错，不知道convertor的类型。
    @Field(codingParams: .init(key: nil, convertor: NilTransform<String>(), nested: nil, delimiter:  ".", ignoreNil:  false), storageParams: .init(key: "user_name"))
    var userName: String = "名字"
    @FieldOptional(key: "nick_name")
    var nickName: String?
    @Field(key: "amount", storageParams: .init(isNewField: true, defaultValue: 100))
    var amount: Double = 6
    @FieldOptional
    var phone: String?
    @FieldOptional
    var gender: Gender?
    @FieldOptional(codingParams: .init(key: "avatar_key", convertor: NilTransform<String>()))
    var avatar: String?
    @FieldOptional(key: "birthday", codingParams: .init(key: "birthday_coding", convertor:  DateTransform()))
    var birthday: Date?
    @Field(key: "level")
    var vipLevel: Int = 1
    @Field(codingParams: .init(convertor: DateTransform()))
    var registerDate: Date = Date()
    @Field(wrappedValue: false, key: "has_money")
    var isRich: Bool
    @Field
    var nest: NestModel = NestModel(JSON: [String : Any]())!

    //如果值类型不是基础类型或不是遵从BaseMappable的类型（比如[String: T]、[String : [T]]、[Int : T]不能被识别），那么ObjectMapper的map需要自己处理
    //如果值类型遵从SQLiteValueProvider协议，就无需处理SQlite逻辑。（Array.Elment遵从SQLiteValueProvider、Dictionary.Key和Dictionary.Value遵从SQLiteValueProvider等情况）
    //下面示例String、Int、NestModel、[NestModel]都是遵从于SQLiteValueProvider协议的。
    @FieldCustom
    var nests: [NestModel] = [NestModel]()
    @FieldOptionalCustom
    var customDict: [String: NestModel]?
    @FieldOptionalCustom
    var customDictInt: [Int : NestModel]?
    @FieldOptionalCustom
    var customDictAarray: [String: [NestModel]]?
    //如果值类型既不遵从BaseMappable协议，也没有遵从SQLiteValueProvider，就不使用任何@Field，需要自己处理ObjectMapper和QLite.swift逻辑
    var customSet: Set<String>?

    required init?(map: Map) {
    }
}

extension CustomModel: ModelAdaptorCustomMap {
    func customMap(map: Map) {
        self.nests <- map["nests"]
        self.customDict <- map["custom_dict"]
        self.customDictAarray <- map["custom_dict_array"]
        self.customDictInt <- (map["custom_dict_int"], IntDictTransform())
        self.customSet <- (map["custom_set"], ArraySetTransform())
    }
}

struct NestModel: ModelAdaptorModel, SQLiteValueProvider {
    @FieldOptional(key: "nest_name")
    var nestName: String?
    @Field(key: "age")
    var nestAge: Int = 0

    init?(map: Map) {
    }

    init?(value: String) {
        self.init(JSONString: value)
    }
    func value() -> String? {
        return self.toJSONString()
    }
    init?(stringValue: String) {
        if !stringValue.isEmpty {
            self.init(JSONString: stringValue)
        }else {
            return nil
        }
    }
    func stringValue() -> String? {
        return value()
    }
}

struct IntDictTransform: TransformType {
    typealias Object = [Int : NestModel]
    typealias JSON = [Int : [String : Any]]

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

    func transformToJSON(_ value: [Int : NestModel]?) -> [Int : [String : Any]]? {
        guard let dict = value else {
            return nil
        }
        var result = [Int: [String:Any]]()
        for (key, value) in dict {
            result[key] = value.toJSON()
        }
        return result
    }
}

struct ArraySetTransform: TransformType {
    typealias Object = Set<String>
    typealias JSON = [String]

    func transformFromJSON(_ value: Any?) -> Object? {
        guard let array = value as? [String] else {
            return nil
        }
        return Set(array)
    }

    func transformToJSON(_ value: Object?) -> JSON? {
        guard let set = value else {
            return nil
        }
        return Array(set)
    }
}
