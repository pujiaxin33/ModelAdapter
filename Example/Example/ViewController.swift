//
//  ViewController.swift
//  Example
//
//  Created by jiaxin on 2020/6/14.
//  Copyright © 2020 jiaxin. All rights reserved.
//

import UIKit
import SQLite
import ModelAdapter
import ObjectMapper

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let model = createModel()
        print(model)
        let dao = CustomDAO()
        dao.createTable()
        try? dao.insert(entity: model)
        model.nickName = "更新后"
        //需要导入SQLite，下面==操作符才能正确识别
        try? dao.update(entity: model, model.$nickName.expression == "昵称")
        
        if let queryAll = try? dao.queryAll() {
            print(queryAll)
        }
    }

    func createModel() -> CustomModel {
        let jsonDict = [
                        "accountID_key" : UUID().uuidString,
                        "nick_name" : "昵称",
                        "amount" : Double(100),
                        "phone" : "123123123",
                        "gender" : Gender.male,
                        "avatar_key" : "avatar",
                        "birthday_coding" : "2020-08-08 06:06:06",
                        "nest" :  ["nest_name" : "嵌套名字", "age" : 123],
                        "nests" : [["nest_name" : "嵌套名字", "age" : 123]],
                        "custom_dict" : ["custom1" : ["nest_name" : "嵌套名字", "age" : 123]],
                        "custom_dict_array" : ["custom1" : [["nest_name" : "嵌套名字", "age" : 123]]],
                        "custom_dict_int" : [1 : ["nest_name" : "嵌套名字", "age" : 123]],
                        "custom_set" : ["1", "2", "3"]
            ] as [String : Any]
        return CustomModel(JSON: jsonDict)!
    }

}

