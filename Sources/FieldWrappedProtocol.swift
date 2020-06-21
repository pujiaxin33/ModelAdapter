//
//  FieldWrappedProtocol.swift
//  ModelAdaptor
//
//  Created by jiaxin on 2020/6/15.
//

import Foundation
import ObjectMapper
import SQLite

protocol FieldWrappedProtocol {
    var key: String? { get }
}

extension Field: FieldWrappedProtocol { }

protocol FieldMappableWrappedProtocol: FieldWrappedProtocol {
    var codingKey: String? { get }
    var convertorClosure: ((String, Map)->())? { get }
    var immutableConvertorClosure: ((String, Map)->())? { get }
}

protocol FieldStorgeWrappedProtocol: FieldWrappedProtocol {
    var storageKey: String? { get }
    var storageVersion: Int? { get }

    func createColumn(tableBuilder: TableBuilder)
    func addColumn(table: Table)
    func setter() -> Setter?
    func initExpresionIfNeeded(key: String)
    func update(row: Row)
}

protocol BaseMappableWrappedProtocol {
    func configBase()
}
protocol BaseMappableWrappedOptionalProtocol {
    func configBaseOptional()
}

