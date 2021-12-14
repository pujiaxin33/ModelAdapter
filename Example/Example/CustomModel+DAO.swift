//
//  CustomModel+DAO.swift
//  Example
//
//  Created by jiaxin on 2020/7/2.
//  Copyright © 2020 jiaxin. All rights reserved.
//

import Foundation
import SQLite
import ModelAdapter

//因为SQLite和ObjectMapper都有<-操作符，为了避免冲突，数据库存储自定义部分就单独创建一个文件。
extension CustomModel: ModelAdapterModelCustomStorage {
    static let customSetExpression = Expression<String?>("custom_set")

    /*
     //如果是数据库表单创建之后新增的自定义属性，就通过addColumnStatements方法创建Field。
    func addColumnStatements(table: Table) -> [String]? {
        return [table.addColumn(CustomModel.customSetExpression)]
    }
     */
    func createColumn(tableBuilder: TableBuilder) {
        tableBuilder.column(CustomModel.customSetExpression)
    }
    func setters() -> [Setter] {
        guard let set = customSet else {
            return []
        }
        guard let data = try? JSONSerialization.data(withJSONObject: Array(set), options: []) else {
            return []
        }
        return [CustomModel.customSetExpression <- String(data: data, encoding: .utf8)]
    }
    mutating func update(with row: Row) {
        guard let string = row[CustomModel.customSetExpression] else {
            return
        }
        let data = Data(string.utf8)
        guard let stringArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [String] else {
            return
        }
        self.customSet = Set(stringArray)
    }
}
