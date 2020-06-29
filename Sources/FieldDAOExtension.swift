//
//  FieldDAOExtension.swift
//  ModelAdaptor
//
//  Created by jiaxin on 2020/6/15.
//

import Foundation
import SQLite

struct AssociatedKeys {
    static var expression: UInt8 = 0
    static var expressionOptional: UInt8 = 0
}

extension Field: FieldStorgeWrappedProtocol where Value: SQLite.Value {
    public var expression: Expression<Value> {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.expression, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let result = objc_getAssociatedObject(self, &AssociatedKeys.expressionOptional) as? Expression<Value> {
                return result
            }
            initExpresionIfNeeded(key: storageKey!)
            return objc_getAssociatedObject(self, &AssociatedKeys.expressionOptional) as! Expression<Value>
        }
    }

    public func setter() -> Setter? {
        return self.expression <- self.wrappedValue
    }

    public func initExpresionIfNeeded(key: String) {
        self.expression = Expression<Value>(key)
    }

    public func update(row: Row) {
        self.wrappedValue = row[expression]
    }

    public func createColumn(tableBuilder: TableBuilder) {
        tableBuilder.column(expression)
    }

    public func addColumn(table: Table) {
        _ = table.addColumn(expression, defaultValue: self.wrappedValue)
    }
}

extension FieldOptional: FieldOptionalStorgeWrappedProtocol where Value: SQLite.Value {
    public var expression: Expression<Value?> {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.expressionOptional, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let result = objc_getAssociatedObject(self, &AssociatedKeys.expressionOptional) as? Expression<Value?> {
                return result
            }
            initExpresionIfNeeded(key: storageKey!)
            return objc_getAssociatedObject(self, &AssociatedKeys.expressionOptional) as! Expression<Value?>
        }
    }

    public func setter() -> Setter? {
        return self.expression <- self.wrappedValue
    }

    public func initExpresionIfNeeded(key: String) {
        self.expression = Expression<Value?>(key)
    }

    public func update(row: Row) {
        self.wrappedValue = row[expression]
    }

    public func createColumn(tableBuilder: TableBuilder) {
        tableBuilder.column(expression)
    }

    public func addColumn(table: Table) {
        _ = table.addColumn(expression, defaultValue: self.wrappedValue)
    }
}
