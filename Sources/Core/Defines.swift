//
//  FieldWrappedProtocol.swift
//  ModelAdaptor
//
//  Created by jiaxin on 2020/6/15.
//

import Foundation
import SQLite

//fixme:CustomStringConvertible for print
public protocol ModelAdaptorModel {
    init()
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

protocol FieldIdentifierProtocol {
    var key: String? { get }
}

protocol FieldStorageIdentifierBaseProtocol: FieldIdentifierProtocol {
    var storageNormalParams: StorageNormalParams? { get }

    func createColumn(tableBuilder: TableBuilder)
    func addColumn(table: Table) -> String?
    func setter() -> Setter?
    func initExpresionIfNeeded(key: String)
    func update(with row: Row)
}
protocol FieldStorageIdentifierProtocol: FieldStorageIdentifierBaseProtocol { }
protocol FieldOptionalStorageIdentifierProtocol: FieldStorageIdentifierBaseProtocol { }
protocol FieldCustomStorageIdentifierProtocol: FieldStorageIdentifierBaseProtocol {}


internal func mirrorDescriptionPrettyPrinted(_ string: String) -> String {
    return string.replacingOccurrences(of: "Mirror for ", with: "")
}
