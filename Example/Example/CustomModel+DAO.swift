//
//  CustomModel+DAO.swift
//  Example
//
//  Created by jiaxin on 2020/7/2.
//  Copyright © 2020 jiaxin. All rights reserved.
//

import Foundation
import SQLite

//ModelAdaptorStorable自定义
extension CustomModel {
    static let customSetExpression = Expression<String?>("custom_set")

    func createColumn(tableBuilder: TableBuilder) {
        tableBuilder.column(CustomModel.customSetExpression)
    }
    func addColumn(table: Table) { }
    func setters() -> [Setter] {
        guard let set = customSet else {
            return []
        }
        guard let data = try? JSONSerialization.data(withJSONObject: Array(set), options: []) else {
            return []
        }
        return [CustomModel.customSetExpression <- String(data: data, encoding: .utf8)]
    }
    func update(with row: Row) {
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
