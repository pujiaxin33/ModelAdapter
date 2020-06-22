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
    func value() -> SQLiteValue?
}

extension Optional: SQLiteValueProvider where Wrapped: SQLiteValueProvider {
    public typealias SQLiteValue = Wrapped.SQLiteValue
    public func value() -> Wrapped.SQLiteValue? {
        switch self {
        case .none:
            return nil
        case .some(let data):
            return data as? Wrapped.SQLiteValue
        }
    }
}
//extension Optional: Expressible where Wrapped: Expressible {
//    public var expression: Expression<Void> {
//        return Expression<Void>("123")
//    }
//}
//
//extension Optional: SQLite.Value where Wrapped: SQLite.Value {
//    public typealias Datatype = Wrapped
//    public static let declaredDatatype = "REAL"
//
//    public static func fromDatatypeValue(_ datatypeValue: Wrapped) -> Wrapped {
//        return datatypeValue
//    }
//    public var datatypeValue: Wrapped {
//        return self
//    }
//}

extension String: SQLiteValueProvider {
    public typealias SQLiteValue = String
    public func value() -> String? {
        return self
    }
}
extension Double: SQLiteValueProvider {
    public typealias SQLiteValue = Double
    public func value() -> Double? {
        return self
    }
}
extension Int64: SQLiteValueProvider {
    public typealias SQLiteValue = Int64
    public func value() -> Int64? {
        return self
    }
}
extension Blob: SQLiteValueProvider {
    public typealias SQLiteValue = Blob
    public func value() -> Blob? {
        return self
    }
}
extension Bool: SQLiteValueProvider {
    public typealias SQLiteValue = Bool
    public func value() -> Bool? {
        return self
    }
}
extension Int: SQLiteValueProvider {
    public typealias SQLiteValue = Int
    public func value() -> Int? {
        return self
    }
}
extension Date: SQLiteValueProvider {
    public typealias SQLiteValue = Date
    public func value() -> Date? {
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
        self.expression = Expression<Value.SQLiteValue>(key)
    }

    public func update(row: Row) {
        self.wrappedValue = row[expression] as! Value
    }

    public func createColumn(tableBuilder: TableBuilder) {
        tableBuilder.column(expression)
    }

    public func addColumn(table: Table) {
        _ = table.addColumn(expression, defaultValue: self.wrappedValue.value()!)
    }
}
//todo:FieldStorgeWrappedProtocol  确定是否会调用这里的扩展方法
extension Field: FieldStorgeOptionalWrappedProtocol where Value: SQLiteValueProvider, Value: ExpressibleByNilLiteral {
    public var expressionOptional: Expression<Value.SQLiteValue?> {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.expressionOptional, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.expressionOptional) as! Expression<Value.SQLiteValue?>
        }
    }

    public func setter() -> Setter? {
//        if let value = self.wrappedValue.value() {
//            return self.expressionOptional <- value
//        }
//        return nil
        return self.expressionOptional <- self.wrappedValue.value()
    }

    public func initExpresionIfNeeded(key: String) {
        self.expressionOptional = Expression<Value.SQLiteValue?>(key)
    }

    public func update(row: Row) {
        if let value = row[expressionOptional] as? Value {
            self.wrappedValue = value
        }
    }

    public func createColumn(tableBuilder: TableBuilder) {
        tableBuilder.column(expressionOptional)
    }

    public func addColumn(table: Table) {
        _ = table.addColumn(expressionOptional)
    }
}

extension Field where Value: SQLite.Value {

}

//extension Field where Value == Optional<SQLite.Value> {
//
//}
