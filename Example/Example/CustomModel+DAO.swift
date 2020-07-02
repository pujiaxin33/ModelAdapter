//
//  CustomModel+DAO.swift
//  Example
//
//  Created by jiaxin on 2020/7/2.
//  Copyright © 2020 jiaxin. All rights reserved.
//

import Foundation
import SQLite

extension CustomModel {
    static let customDictIntExpression = Expression<String?>("custom_dict_int")

    func createColumn(tableBuilder: TableBuilder) {
        tableBuilder.column(CustomModel.customDictIntExpression)
    }
    func addColumn(table: Table) {

    }
    func setters() -> [Setter] {
        guard let dict = customDictInt else {
            return []
        }
        var result = [String : String]()
        for (key, value) in dict {
            guard let stringValue = value.toJSONString() else {
                continue
            }
            result["\(key)"] = stringValue
        }
        guard let data = try? JSONSerialization.data(withJSONObject: result, options: []) else {
            return []
        }
        return [CustomModel.customDictIntExpression <- String(data: data, encoding: .utf8)]
    }
    func update(with row: Row) {
        guard let string = row[CustomModel.customDictIntExpression] else {
            return
        }

        let data = Data(string.utf8)
        guard let stringDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : String] else {
            return
        }
        var result = [Int : NestModel]()
        for (key, value) in stringDict {
            guard let model = NestModel(JSONString: value) else {
                continue
            }
            result[Int(key) ?? 0] = model
        }
        self.customDictInt = result
    }
}
