//
//  FieldDAOExtension.swift
//  ModelAdapter
//
//  Created by jiaxin on 2020/6/15.
//

import Foundation
import SQLite
import SQLiteValueExtension
import UIKit

struct AssociatedKeys {
    static var expression: UInt8 = 0
    static var expressionOptional: UInt8 = 0
}

protocol FieldValueDataypeEqualToInt64IdentifierProtocol {
    func createColumnWithPrimaryKey(tableBuilder: TableBuilder)
}
protocol FieldValueDataypeEqualToStringIdentifierProtocol {
    func createColumnWithCollate(tableBuilder: TableBuilder)
    func addColumnWithCollate(table: Table) -> String?
}

extension Field: FieldStorageIdentifierBaseProtocol where Value: SQLiteValueStringExpressible { }
extension Field: FieldStorageIdentifierProtocol where Value: SQLiteValueStringExpressible {
    public var expression: Expression<Value> {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.expression, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.expression) as! Expression<Value>
        }
    }

    public func setter() -> Setter? {
        return self.expression <- self.wrappedValue
    }

    public func initExpresionIfNeeded(key: String) {
        if objc_getAssociatedObject(self, &AssociatedKeys.expression) == nil {
            self.expression = Expression<Value>(key)
        }
    }

    public func update(with row: Row) {
        if let rowValue = try? row.get(expression) {
            self.wrappedValue = rowValue
        }
    }

    public func createColumn(tableBuilder: TableBuilder) {
        if self.params.isPrimaryKey != nil {
            tableBuilder.column(expression, primaryKey: self.params.isPrimaryKey!, check: self.params.check?(expression))
        }else if self.params.primaryKey != nil {
            if let bridge = self as? FieldValueDataypeEqualToInt64IdentifierProtocol {
                bridge.createColumnWithPrimaryKey(tableBuilder: tableBuilder)
            }
        }else if self.params.collate != nil {
            if let bridge = self as? FieldValueDataypeEqualToStringIdentifierProtocol {
                bridge.createColumnWithCollate(tableBuilder: tableBuilder)
            }
        }else {
            tableBuilder.column(expression, unique: self.params.unique, check: self.params.check?(expression))
        }
    }

    public func addColumn(table: Table) -> String? {
        if self.params.collate != nil {
            if let bridge = self as? FieldValueDataypeEqualToStringIdentifierProtocol {
                return bridge.addColumnWithCollate(table: table)
            }
        }
        return table.addColumn(expression, check: self.params.check?(expression), defaultValue: self.wrappedValue)
    }
}

extension Field: FieldValueDataypeEqualToInt64IdentifierProtocol where Value: SQLiteValueStringExpressible, Value.Datatype == Int64 {
    func createColumnWithPrimaryKey(tableBuilder: TableBuilder) {
        if self.params.primaryKey != nil {
            tableBuilder.column(expression, primaryKey: self.params.primaryKey!, check: self.params.check?(expression))
        }
    }
}
extension Field: FieldValueDataypeEqualToStringIdentifierProtocol where Value: SQLiteValueStringExpressible, Value.Datatype == String {
    func createColumnWithCollate(tableBuilder: TableBuilder) {
        if self.params.collate != nil {
            tableBuilder.column(expression, unique: self.params.unique, check: self.params.check?(expression), collate: self.params.collate!)
        }
    }
    func addColumnWithCollate(table: Table) -> String? {
        if self.params.collate != nil {
            return table.addColumn(expression, check: self.params.check?(expression), defaultValue: self.wrappedValue, collate: self.params.collate!)
        }
        return nil
    }
}

extension FieldOptional: FieldStorageIdentifierBaseProtocol where Value: SQLiteValueStringExpressible { }
extension FieldOptional: FieldOptionalStorageIdentifierProtocol where Value: SQLiteValueStringExpressible {
    public var expression: Expression<Value?> {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.expressionOptional, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.expressionOptional) as! Expression<Value?>
        }
    }

    public func setter() -> Setter? {
        return self.expression <- self.wrappedValue
    }

    public func initExpresionIfNeeded(key: String) {
        if objc_getAssociatedObject(self, &AssociatedKeys.expressionOptional) == nil {
            self.expression = Expression<Value?>(key)
        }
    }

    public func update(with row: Row) {
        self.wrappedValue = try? row.get(expression)
    }

    public func createColumn(tableBuilder: TableBuilder) {
        if self.params.collate != nil {
            if let bridge = self as? FieldValueDataypeEqualToStringIdentifierProtocol {
                bridge.createColumnWithCollate(tableBuilder: tableBuilder)
            }
        }else {
            if let check = self.params.checkOptional?(expression) {
                tableBuilder.column(expression, unique: self.params.unique, check: check)
            }else {
                tableBuilder.column(expression, unique: self.params.unique)
            }
        }
    }

    public func addColumn(table: Table) -> String? {
        if self.params.collate != nil {
            if let bridge = self as? FieldValueDataypeEqualToStringIdentifierProtocol {
                return bridge.addColumnWithCollate(table: table)
            }
        }
        if let check = self.params.checkOptional?(expression) {
            return table.addColumn(expression, check: check, defaultValue: self.wrappedValue)
        }else {
            return table.addColumn(expression, defaultValue: self.wrappedValue)
        }
    }
}

extension FieldOptional: FieldValueDataypeEqualToStringIdentifierProtocol where Value: SQLiteValueStringExpressible, Value.Datatype == String {
    func createColumnWithCollate(tableBuilder: TableBuilder) {
        if self.params.collate != nil {
            if let check = self.params.checkOptional?(expression) {
                tableBuilder.column(expression, unique: self.params.unique, check: check, collate: self.params.collate!)
            }else {
                tableBuilder.column(expression, unique: self.params.unique, collate: self.params.collate!)
            }
            
        }
    }
    func addColumnWithCollate(table: Table) -> String? {
        if self.params.collate != nil {
            if let check = self.params.checkOptional?(expression) {
                return table.addColumn(expression, check: check, defaultValue: self.wrappedValue, collate: self.params.collate!)
            }else {
                return table.addColumn(expression, defaultValue: self.wrappedValue, collate: self.params.collate!)
            }
        }
        return nil
    }
}
