//
//  CustomDAO.swift
//  Example
//
//  Created by jiaxin on 2020/6/15.
//  Copyright © 2020 jiaxin. All rights reserved.
//

import Foundation
import ModelAdaptor
import SQLite

class CustomDAO: ModelAdaptorDAO {
    typealias Entity = CustomModel
    var connection: Connection = try! Connection("\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/db.sqlite3")
    var table: Table = Table("user")

    required init() {
    }

    func customUpdate(entity: Entity) throws {
        let statement = table.update(entity.$vipLevel.expression <- entity.vipLevel)
        try connection.run(statement)
    }
}
