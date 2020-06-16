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
}

public protocol SQLiteValueProvider {
    associatedtype SQLiteValue: SQLite.Value
    func value() -> SQLiteValue
}

public extension Field where Value: SQLiteValueProvider {
    
}

public extension Field where Value: SQLite.Value {
    var expression: Expression<Value> {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.expression, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.expression) as! Expression<Value>
        }
    }
    
    func setter() -> Setter? {
        return self.expression <- self.wrappedValue
    }

    func initExpresionIfNeeded(key: String) {
        self.expression = Expression<Value>(key)
    }

    func update(row: Row) {
        self.wrappedValue = row[expression]
    }
}

//todo:Field.Value可以是任意类型，比如自定义model。需要一个转换，把不支持SQLite.Value的类型转换为SQLite.Value类型，比如把自定义model转换为jsonString
//modeladapotr.value可以是任意类型，包括可选值
//SQLite.Value是部分范围值，不是可选的。所以有SQLite.Value?的定义
//, Value: SQLite.Value
public extension Field where Value: ExpressibleByNilLiteral, Value: SQLite.Value {
    var expression: Expression<Value> {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.expression, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.expression) as! Expression<Value>
        }
    }

    func setter() -> Setter? {
        //Operator function '<-' requires that 'Value' conform to 'SQLite.Value'
        return self.expression <- self.wrappedValue
    }

    func initExpresionIfNeeded(key: String) {
        self.expression = Expression<Value>(key)
    }

    func update(row: Row) {
        //Subscript 'subscript(_:)' requires that 'Value' conform to 'SQLite.Value'
        self.wrappedValue = row[expression]
    }
}

public extension Field where Value: SQLiteValueProvider {
    var expression: Expression<Value> {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.expression, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.expression) as! Expression<Value>
        }
    }

    func setter() -> Setter? {
        //Operator function '<-' requires that 'Value' conform to 'SQLite.Value'
        return self.expression <- self.wrappedValue.value()
    }

    func initExpresionIfNeeded(key: String) {
        self.expression = Expression<Value>(key)
    }

    func update(row: Row) {
        //Subscript 'subscript(_:)' requires that 'Value' conform to 'SQLite.Value'
        self.wrappedValue = row[expression]
    }
}
