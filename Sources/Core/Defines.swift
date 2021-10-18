//
//  FieldWrappedProtocol.swift
//  ModelAdaptor
//
//  Created by jiaxin on 2020/6/15.
//

import Foundation
import ObjectMapper
import SQLite

public protocol ModelAdaptorModel: Mappable, CustomStringConvertible { }
public protocol ModelAdaptorCustomMap {
    func customMap(map: Map)
}
public protocol ModelAdaptorCustomStorage {
    func createColumn(tableBuilder: TableBuilder)
    func addColumn(table: Table) -> String?
    func setters() -> [Setter]
    func update(with row: Row)
}

public extension ModelAdaptorCustomStorage {
    func addColumn(table: Table) -> String? {
        return nil
    }
}

protocol FieldWrappedProtocol {
    var key: String? { get }
}

protocol FieldMappableWrappedBaseProtocol: FieldWrappedProtocol {
    var codingKey: String? { get }
    var mapperClosure: ((String, Map)->())? { get }
}
protocol FieldMappableWrappedProtocol: FieldMappableWrappedBaseProtocol {}
protocol FieldOptionalMappableWrappedProtocol: FieldMappableWrappedBaseProtocol {}

protocol FieldStorageWrappedBaseProtocol: FieldWrappedProtocol {
    var storageNormalParams: StorageNormalParams? { get }

    func createColumn(tableBuilder: TableBuilder)
    func addColumn(table: Table) -> String?
    func setter() -> Setter?
    func initExpresionIfNeeded(key: String)
    func update(row: Row)
}
protocol FieldStorageWrappedProtocol: FieldStorageWrappedBaseProtocol { }
protocol FieldOptionalStorageWrappedProtocol: FieldStorageWrappedBaseProtocol { }
protocol FieldCustomStorageWrappedProtocol: FieldStorageWrappedBaseProtocol {}

protocol BaseMappableValueWrappedProtocol {
    func configMapperClosureWhenValueIsBaseMappable()
}
protocol ArrayBaseMappableValueWrappedProtocol {
    func configBaseMappableMapperClosure()
}

internal func mirrorDescriptionPrettyPrinted(_ string: String) -> String {
    return string.replacingOccurrences(of: "Mirror for ", with: "")
}
