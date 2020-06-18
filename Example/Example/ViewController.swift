//
//  ViewController.swift
//  Example
//
//  Created by jiaxin on 2020/6/14.
//  Copyright © 2020 jiaxin. All rights reserved.
//

import UIKit
import SQLite
import ModelAdaptor

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let dao = CustomDAO()
        dao.createTable()
        let model = createModel()
        try? dao.insert(entity: model)
//        try? dao.insert(entities: [model])
//        try? dao.delete(model.$vipLevel.expression == 123)
//        try? dao.delete(model.$accountID.expressionOptional > 100)
//        try? dao.deleteAll()
//        try? dao.update(entity: model, model.$nickName.expressionOptional == "xinxin")
//        try? dao.update(entity: model, model.$amount.expression == 333)
//        let queryOne = try? dao.query(model.$birthday.expressionOptional == Date())
//        let queryTwo = try? dao.query(model.$vipLevel.expression == 1)
        let queryAll = try? dao.queryAll()

    }

    func createModel() -> CustomModel {
//        @Field(key: "accountID", storageParams: nil)
//        var accountID: Int?         //用户ID
//        @Field(codingParams: .init(key: nil, convertor: NilTransform<String>(), nested: nil, delimiter:  ".", ignoreNil:  false), storageParams: .init(key: nil))
//        var userName: String = "名字"       //账号
//        @Field(key: "nick_name")
//        var nickName: String?       //昵称
//        @Field(key: "amount")
//        var amount: Double = 0            // 账户余额
//        @Field
//        var phone: String?          //手机号
//        @Field
//        var gender: DQGender?       //性别 = ['UnKnow', 'Male', 'Female'],
//        @Field(codingParams: .init(key: "ava", convertor: NilTransform<String>()))
//        var avatar: String?         //头像
//        @Field(key: "birthday", codingParams: .init(key: "birthday_coding", convertor:  DQDateTransform()))
//        var birthday: Date?         //生日，没有就是nil
//        @Field(key: "level")
//        var vipLevel: Int = 1       //会员等级， 1~5
//        @Field
//        var levelPoints: Int = 0   //当前等级值
//        @Field
//        var downPoints: Int?
//        @Field(codingParams: .init(convertor: DQDateTransform()))
//        var registerDate: Date = Date()   //注册时间，格式（2018-04-09 10:12:42 000）
//        @Field(wrappedValue: false, key: "hasFundsPassword")
//        var isExchangePasswordValid: Bool   //是否设置了兑换密码
//        @Field
//        var nest: NestModel?
        let nestModel = NestModel(JSON: ["nest_name" : "嵌套名字", "age" : 123])
        let jsonDict = ["accountID" : 123,
                        "userName" : "用户名",
                        "nick_name" : "昵称",
                        "amount" : 100,
                        "phone" : "123123123",
                        "gender" : DQGender.male,
                        "avatar_key" : "avatar",
                        "birthday" : Date(),
                        "level" : 10,
                        "levelPoints" : 99,
                        "downPoints" : 88,
                        "registerDate" : Date(),
                        "hasFundsPassword" : true,
                        "nest" : nestModel! ] as [String : Any]
        let model = CustomModel(JSON: jsonDict)
        return model!
    }

}

