//
//  FieldWrappedProtocol.swift
//  ModelAdaptor
//
//  Created by jiaxin on 2020/6/15.
//

import Foundation
import ObjectMapper
import SQLite

public protocol ModelAdaptorModel: ModelAdaptorMappable, ModelAdaptorStorable {}

protocol FieldWrappedProtocol {
    var key: String? { get }
}
extension Field: FieldWrappedProtocol { }

protocol FieldMappableWrappedProtocol: FieldWrappedProtocol {
    var codingKey: String? { get }
    var mapperClosure: ((String, Map)->())? { get }
    var immutableMapperClosure: ((String, Map)->())? { get }
}

 protocol FieldOptionalMappableWrappedProtocol: FieldMappableWrappedProtocol {}

protocol FieldStorgeWrappedProtocol: FieldWrappedProtocol {
    var storageKey: String? { get set }
    var storageVersion: Int? { get }

    func createColumn(tableBuilder: TableBuilder)
    func addColumn(table: Table)
    func setter() -> Setter?
    func initExpresionIfNeeded(key: String)
    func update(row: Row)
}

protocol FieldOptionalStorgeWrappedProtocol: FieldWrappedProtocol {
    var storageKey: String? { get set }
    var storageVersion: Int? { get }

    func createColumn(tableBuilder: TableBuilder)
    func addColumn(table: Table)
    func setter() -> Setter?
    func initExpresionIfNeeded(key: String)
    func update(row: Row)
}

protocol FieldSQLiteValueProviderWrappedProtocol: FieldWrappedProtocol {
    var storageKey: String? { get set }
    var storageVersion: Int? { get }

    func createColumn(tableBuilder: TableBuilder)
    func addColumn(table: Table)
    func setter() -> Setter?
    func initExpresionIfNeeded(key: String)
    func update(row: Row)
}

protocol FieldOptionalSQLiteValueProviderWrappedProtocol: FieldWrappedProtocol {
    var storageKey: String? { get set }
    var storageVersion: Int? { get }

    func createColumn(tableBuilder: TableBuilder)
    func addColumn(table: Table)
    func setter() -> Setter?
    func initExpresionIfNeeded(key: String)
    func update(row: Row)
}

protocol BaseMappableWrappedProtocol {
    func configBaseMappableMapperClosure()
}

