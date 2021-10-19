//
//  FieldDAOExtension.swift
//  ModelAdaptor
//
//  Created by jiaxin on 2020/6/15.
//

import Foundation
import SQLite
import SQLiteValueExtension

struct AssociatedKeys {
    static var expression: UInt8 = 0
    static var expressionOptional: UInt8 = 0
    static var expressionsInit: UInt8 = 0
}

public typealias SQLiteValueProvider = SQLite.Value & StringValueExpressible

extension Field: FieldStorageIdentifierBaseProtocol where Value: SQLiteValueProvider { }
extension Field: FieldStorageIdentifierProtocol where Value: SQLiteValueProvider {
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
        tableBuilder.column(expression)
    }

    public func addColumn(table: Table) -> String? {
        return table.addColumn(expression, defaultValue: self.wrappedValue)
    }
}

extension FieldOptional: FieldIdentifierProtocol where Value: SQLiteValueProvider {}
extension FieldOptional: FieldStorageIdentifierBaseProtocol where Value: SQLiteValueProvider { }
extension FieldOptional: FieldOptionalStorageIdentifierProtocol where Value: SQLiteValueProvider {
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
        tableBuilder.column(expression)
    }

    public func addColumn(table: Table) -> String? {
        return table.addColumn(expression, defaultValue: self.wrappedValue)
    }
}
