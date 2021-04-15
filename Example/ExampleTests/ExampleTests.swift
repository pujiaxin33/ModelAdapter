//
//  ExampleTests.swift
//  ExampleTests
//
//  Created by jiaxin on 2021/4/15.
//  Copyright © 2021 jiaxin. All rights reserved.
//

import XCTest
import ModelAdaptor
import SQLite

class ExampleTests: XCTestCase {

    override class func setUp() {
        let dao = CustomDAO()
        dao.createTable()
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let dao = CustomDAO()
        try? dao.deleteAll()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInsertSingle() throws {
        let dao = CustomDAO()
        let model = createModel()
        try? dao.insert(entity: model)
        let all = try? dao.queryAll()
        XCTAssert(all?.count == 1)
    }

    func testInsertArray() throws {
        let dao = CustomDAO()
        let model = createModel()
        try? dao.insert(entities: [model, model])
        let all = try? dao.queryAll()
        XCTAssert(all?.count == 2)
    }

    func testDelete() throws {
        let dao = CustomDAO()
        let model = createModel()
        try? dao.insert(entity: model)
        model.nickName = "new nick"
        try? dao.insert(entity: model)
        try? dao.delete(model.$nickName.expression == "昵称")
        let all = try? dao.queryAll()
        XCTAssert(all?.count == 1)
        XCTAssert(all?.first?.nickName == "new nick")
    }

    func testUpdate() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let dao = CustomDAO()
        let model = createModel()
        try? dao.insert(entity: model)
        model.nickName = "更新后"
        try? dao.update(entity: model, model.$nickName.expression == "昵称")
        let all = try? dao.queryAll()
        XCTAssert(all?.last?.nickName == "更新后", "Update failed!")
    }

    func testQuery() throws {
        let dao = CustomDAO()
        let model = createModel()
        try? dao.insert(entity: model)
        model.nickName = "new nick"
        try? dao.insert(entity: model)

        let target1 = try? dao.query(model.$nickName.expression == "new nick")
        XCTAssert(target1?.nickName == "new nick")

        let target2 = try? dao.query(model.$nickName.expression == "昵称")
        XCTAssert(target2?.nickName == "昵称")
    }

    func createModel() -> CustomModel {
        let jsonDict = [
                        "accountID_key" : 123,
                        "userName" : "用户名",
                        "nick_name" : "昵称",
                        "amount" : Double(100),
                        "phone" : "123123123",
                        "gender" : Gender.male,
                        "avatar_key" : "avatar",
                        "birthday_coding" : "2020-08-08 06:06:06",
                        "level" : 10,
                        "registerDate" : "2020-08-08 06:06:06",
                        "has_money" : true,
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
