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
    var connection: Connection = try! Connection("123")
    var table: Table = Table("user")

    required init() {
        initExpressions()
    }





}
