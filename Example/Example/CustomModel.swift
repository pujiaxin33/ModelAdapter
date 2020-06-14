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

class CustomModel: ModelAdaptorObjectMappable {
    @Entity(key: "accountId")
    var accountID: Int?         //用户ID
    @Entity
    var userName: String?       //账号
    @Entity
    var nickName: String?       //昵称
    @Entity
    var amount: Double = 0            // 账户余额
    @Entity
    var phone: String?          //手机号
//    @Entity
//    var gender: DQGender?       //性别 = ['UnKnow', 'Male', 'Female'],
    @Entity
    var avatar: String?         //头像
//    @EntityConvertor(wrappedValue: Date(), convertor: DQDateTransform())
    @Entity(convertor: DQDateTransform())
    var birthday: Date?         //生日，没有就是nil
    @Entity(key: "level")
    var vipLevel: Int = 1       //会员等级， 1~5
    @Entity
    var levelPoints: Int = 0   //当前等级值
    @Entity
    var downPoints: Int = 0
//    @EntityConvertor(wrappedValue: Date(), key: "123", convertor: DQDateTransform())
    @Entity(convertor: DQDateTransform())
    var registerDate: Date = Date()   //注册时间，格式（2018-04-09 10:12:42 000）
    @Entity(wrappedValue: false,key: "hasFundsPassword")
    var isExchangePasswordValid: Bool    //是否设置了兑换密码

    required init?(map: Map) {
//        super.init()
//        self.accountID = nil
    }
}
