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

enum DQGender: String {
    case unknow = "UnKnown"
    case female = "Female"
    case male = "Male"
}

class CustomModel: ModelAdaptorMappable, NormalInitialize {
//    @FieldOptional(key: "accountID_key", storageParams: nil)
//    var accountID: Int?         //用户ID
//    @Field(codingParams: .init(key: nil, convertor: NilTransform<String>(), nested: nil, delimiter:  ".", ignoreNil:  false), storageParams: .init(key: nil))
//    var userName: String = "名字"       //账号
//    @FieldOptional(key: "nick_name")
//    var nickName: String?       //昵称
//    @Field(key: "amount")
//    var amount: Double = 6            // 账户余额
    @Field
    var phone: String?          //手机号
//    @Field
//    var gender: DQGender?       //性别 = ['UnKnow', 'Male', 'Female'],
//    @FieldOptional(codingParams: .init(key: "avatar_key", convertor: NilTransform<String>()))
//    var avatar: String?         //头像
//    @FieldOptional(key: "birthday", codingParams: .init(key: "birthday_coding", convertor:  DQDateTransform()))
//    var birthday: Date?         //生日，没有就是nil
//    @Field(key: "level")
//    var vipLevel: Int = 1       //会员等级， 1~5
//    @Field
//    var levelPoints: Int = 0   //当前等级值
//    @Field
//    var downPoints: Int?
//    @Field(codingParams: .init(convertor: DQDateTransform()))
//    var registerDate: Date = Date()   //注册时间，格式（2018-04-09 10:12:42 000）
//    @Field(wrappedValue: false, key: "hasFundsPassword")
//    var isExchangePasswordValid: Bool   //是否设置了兑换密码
//    @Field
//    var nest: NestModel = NestModel(JSON: [String : Any]())!


    required init() {

    }

    required init?(map: Map) { }
}


struct NestModel: SQLiteValueProvider, ModelAdaptorMappable {
    typealias SQLiteValue = String

    @FieldOptional(key: "nest_name")
    var nestName: String?
    @Field(key: "age")
    var nestAge: Int = 0

    func value() -> String? {
        return toJSONString()
    }

    init?(map: Map) {

    }
}

