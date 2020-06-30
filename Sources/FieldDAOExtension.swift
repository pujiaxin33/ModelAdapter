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

public protocol SQLiteValueProvider {
    associatedtype SQLiteValue: SQLite.Value
    init?(value: SQLiteValue)
    func value() -> SQLiteValue?
    //fixme:defaultValue应该能单独配置
    func defaultValue() -> SQLiteValue?
}

extension String: SQLiteValueProvider {
    public typealias SQLiteValue = String
    public init?(value: SQLiteValue) {
        self = value
    }
    public func value() -> String? {
        return self
    }
    public func defaultValue() -> String? {
        return self
    }
}
extension Double: SQLiteValueProvider {
    public typealias SQLiteValue = Double
    public init?(value: SQLiteValue) {
        self = value
    }
    public func value() -> Double? {
        return self
    }
    public func defaultValue() -> Double? {
        return self
    }
}
extension Int64: SQLiteValueProvider {
    public typealias SQLiteValue = Int64
    public init?(value: SQLiteValue) {
        self = value
    }
    public func value() -> Int64? {
        return self
    }
    public func defaultValue() -> Int64? {
        return self
    }
}
extension Blob: SQLiteValueProvider {
    public typealias SQLiteValue = Blob
    public init?(value: SQLiteValue) {
        self = value
    }
    public func value() -> Blob? {
        return self
    }
    public func defaultValue() -> Blob? {
        return self
    }
}
extension Bool: SQLiteValueProvider {
    public typealias SQLiteValue = Bool
    public init?(value: SQLiteValue) {
        self = value
    }
    public func value() -> Bool? {
        return self
    }
    public func defaultValue() -> Bool? {
        return self
    }
}
extension Int: SQLiteValueProvider {
    public typealias SQLiteValue = Int
    public init?(value: SQLiteValue) {
        self = value
    }
    public func value() -> Int? {
        return self
    }
    public func defaultValue() -> Int? {
        return self
    }
}
extension Date: SQLiteValueProvider {
    public typealias SQLiteValue = Date
    public init?(value: SQLiteValue) {
        self = value
    }
    public func value() -> Date? {
        return self
    }
    public func defaultValue() -> Date? {
        return self
    }
}

extension Field: FieldStorgeWrappedProtocol where Value: SQLiteValueProvider {
    public var expression: Expression<Value.SQLiteValue> {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.expression, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.expression) as! Expression<Value.SQLiteValue>
        }
    }

    public func setter() -> Setter? {
        if let value = self.wrappedValue.value() {
            return self.expression <- value
        }
        return nil
    }

    public func initExpresionIfNeeded(key: String) {
        if objc_getAssociatedObject(self, &AssociatedKeys.expression) == nil {
            self.expression = Expression<Value.SQLiteValue>(key)
        }
    }

    public func update(row: Row) {
        if let value = Value.init(value: row[expression]) {
            self.wrappedValue = value
        }
    }

    public func createColumn(tableBuilder: TableBuilder) {
        tableBuilder.column(expression)
    }

    public func addColumn(table: Table) {
        if let value = self.wrappedValue.defaultValue() {
            _ = table.addColumn(expression, defaultValue: value)
        }else {
            assertionFailure("Must provide defaultValue")
        }
    }
}

extension FieldOptional: FieldOptionalStorgeWrappedProtocol where Value: SQLiteValueProvider {
    public var expression: Expression<Value.SQLiteValue?> {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.expressionOptional, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.expressionOptional) as! Expression<Value.SQLiteValue?>
        }
    }

    public func setter() -> Setter? {
        return self.expression <- self.wrappedValue?.value()
    }

    public func initExpresionIfNeeded(key: String) {
        if objc_getAssociatedObject(self, &AssociatedKeys.expressionOptional) == nil {
            self.expression = Expression<Value.SQLiteValue?>(key)
        }
    }

    public func update(row: Row) {
        if let value = row[expression] {
            self.wrappedValue = Value.init(value: value)
        }else {
            self.wrappedValue = nil
        }
    }

    public func createColumn(tableBuilder: TableBuilder) {
        tableBuilder.column(expression)
    }

    public func addColumn(table: Table) {
        _ = table.addColumn(expression, defaultValue: self.wrappedValue?.defaultValue())
    }
}

//extension Field: FieldSQLiteValueProviderWrappedProtocol where Value: SQLiteValueProvider {
//    public var expression: Expression<Value.SQLiteValue> {
//        set {
//            objc_setAssociatedObject(self, &AssociatedKeys.expression, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//        get {
//            return objc_getAssociatedObject(self, &AssociatedKeys.expression) as! Expression<Value.SQLiteValue>
//        }
//    }
//
//    public func setter() -> Setter? {
//        return self.expression <- self.wrappedValue.value()
//    }
//
//    public func initExpresionIfNeeded(key: String) {
//        if objc_getAssociatedObject(self, &AssociatedKeys.expression) == nil {
//            self.expression = Expression<Value.SQLiteValue>(key)
//        }
//    }
//
//    public func update(row: Row) {
//        self.wrappedValue = Value.init(value: row[expression])
//    }
//
//    public func createColumn(tableBuilder: TableBuilder) {
//        tableBuilder.column(expression)
//    }
//
//    public func addColumn(table: Table) {
//        _ = table.addColumn(expression, defaultValue: self.wrappedValue.value())
//    }
//}

