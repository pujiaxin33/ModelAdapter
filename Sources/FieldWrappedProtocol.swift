//
//  FieldWrappedProtocol.swift
//  ModelAdaptor
//
//  Created by jiaxin on 2020/6/15.
//

import Foundation
import ObjectMapper
import SQLite

public protocol FieldWrappedProtocol {
    var key: String? { get }
}

extension Field: FieldWrappedProtocol { }

public protocol FieldMappableWrappedProtocol: FieldWrappedProtocol {
    var codingKey: String? { get }
    var convertorClosure: ((String, Map)->())? { get }
    var immutableConvertorClosure: ((String, Map)->())? { get }
}

public protocol FieldOptionalMappableWrappedProtocol: FieldMappableWrappedProtocol {}

public protocol FieldStorgeWrappedProtocol: FieldWrappedProtocol {
    var storageKey: String? { get set }
    var storageVersion: Int? { get }

    func createColumn(tableBuilder: TableBuilder)
    func addColumn(table: Table)
    func setter() -> Setter?
    func initExpresionIfNeeded(key: String)
    func update(row: Row)
}

public protocol FieldOptionalStorgeWrappedProtocol: FieldWrappedProtocol {
    var storageKey: String? { get set }
    var storageVersion: Int? { get }

    func createColumn(tableBuilder: TableBuilder)
    func addColumn(table: Table)
    func setter() -> Setter?
    func initExpresionIfNeeded(key: String)
    func update(row: Row)
}

public protocol BaseMappableWrappedProtocol {
    func configBase()
}

