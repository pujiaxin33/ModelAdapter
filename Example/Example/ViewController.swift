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
        print(model)
//        try? dao.insert(entity: model)
        try? dao.insert(entities: [model])
//        try? dao.delete(model.$nickName.expression == "更新后")
//        try? dao.delete(model.$accountID.expressionOptional > 100)
//        try? dao.deleteAll()
//        model.nickName = "更新后"
//        try? dao.update(entity: model, model.$nickName.expression == "昵称")
//        try? dao.update(entity: model, model.$amount.expression == 333)
//        let queryOne = try? dao.query(model.$birthday.expressionOptional == Date())
//        let queryTwo = try? dao.query(model.$vipLevel.expression == 1)
        let queryAll = try? dao.queryAll()
        print(queryAll)
    }

    func createModel() -> CustomModel {
        let jsonDict = [
                        "accountID_key" : 123,
                        "userName" : "用户名",
                        "nick_name" : "昵称",
                        "amount" : Double(100),
                        "phone" : "123123123",
                        "gender" : DQGender.male,
                        "avatar_key" : "avatar",
                        "birthday_coding" : "2020-08-08 06:06:06",
                        "level" : 10,
                        "levelPoints" : 99,
                        "downPoints" : 88,
                        "registerDate" : "2020-08-08 06:06:06",
                        "hasFundsPassword" : true,
                        "nest" :  ["nest_name" : "嵌套名字", "age" : 123]
            ] as [String : Any]
        return CustomModel(JSON: jsonDict)!
    }

}

