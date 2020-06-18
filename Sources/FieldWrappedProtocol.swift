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
    var codingKey: String? { get }
    var storageKey: String? { get }
    var storageVersion: Int? { get }
    var convertorClosure: ((String, Map)->())? { get }
    var immutableConvertorClosure: ((String, Map)->())? { get }

    func createColumn(tableBuilder: TableBuilder)
    func addColumn(table: Table)
    func setter() -> Setter?
    func initExpresionIfNeeded(key: String)
    func update(row: Row)
}

extension Field: FieldWrappedProtocol {
    func setter() -> Setter? {
        return nil
    }
    func initExpresionIfNeeded(key: String) {}
    func update(row: Row) {}
    func createColumn(tableBuilder: TableBuilder) {}
    func addColumn(table: Table) {}
}
