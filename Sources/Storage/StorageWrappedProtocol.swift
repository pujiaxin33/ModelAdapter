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
    static var expressionCustom: UInt8 = 0
    static var expressionOptionalCustom: UInt8 = 0
    static var expressionsInit: UInt8 = 0
}

/// 把自定义的数据类型转换为SQLite可以存储的数据类型。
/// 需要实现方法`init?(value: SQLiteValue)`用于数据库类型转自定义类型；实现`func value() -> SQLiteValue?`用于把当前的自定义类型数据转换为数据库支持的类型。
/// 如果自定义类型会出现在数组、字典里面，就需要实现`init?(stringValue: String)`和`func stringValue() -> String?`方法，用于将当前的自定义类型数据存储进数组或者字典里面，然后数组或字典再被转换成字符串存储进数据库。
public protocol SQLiteValueProvider {
    associatedtype SQLiteValue: SQLite.Value
    init?(value: SQLiteValue)
    func value() -> SQLiteValue?

    //当数据被包裹在数组、字典里面时，就会调用下面两个方法进行转换。
    init?(stringValue: String)
    func stringValue() -> String?
}

extension String: SQLiteValueProvider {
    public typealias SQLiteValue = String
    public init?(value: SQLiteValue) {
        self = value
    }
    public func value() -> String? {
        return self
    }
    public init?(stringValue: String) {
         self = stringValue
    }
    public func stringValue() -> String? { return self }
}
extension Double: SQLiteValueProvider {
    public typealias SQLiteValue = Double
    public init?(value: SQLiteValue) {
        self = value
    }
    public func value() -> Double? {
        return self
    }
    public init?(stringValue: String) {
        if let value = Double(stringValue) {
            self = value
        }else {
            return nil
        }
    }
    public func stringValue() -> String? { return String(self) }
}
extension Int64: SQLiteValueProvider {
    public typealias SQLiteValue = Int64
    public init?(value: SQLiteValue) {
        self = value
    }
    public func value() -> Int64? {
        return self
    }
    public init?(stringValue: String) {
        if let value = Int64(stringValue) {
            self = value
        }else {
            return nil
        }
    }
    public func stringValue() -> String? { return String(self) }
}
extension Blob: SQLiteValueProvider {
    public typealias SQLiteValue = Blob
    public init?(value: SQLiteValue) {
        self = value
    }
    public func value() -> Blob? {
        return self
    }
    public init?(stringValue: String) {
        var bytes = [UInt8]()
        for start in stride(from: 0, to: stringValue.count, by: 2) {
            let startIndex = stringValue.index(stringValue.startIndex, offsetBy: start)
            let endIndex = stringValue.index(startIndex, offsetBy: 2)
            let byteString = stringValue[startIndex..<endIndex]
            bytes.append(UInt8(byteString, radix: 16) ?? 0)
        }
        self = .init(bytes: bytes)
    }
    public func stringValue() -> String? { return toHex() }
}
extension Bool: SQLiteValueProvider {
    public typealias SQLiteValue = Bool
    public init?(value: SQLiteValue) {
        self = value
    }
    public func value() -> Bool? {
        return self
    }
    public init?(stringValue: String) {
        switch stringValue {
        case "true": self = true
        case "false": self = false
        default: return nil
        }
    }
    public func stringValue() -> String? { return self ? "true" : "false" }
}
extension Int: SQLiteValueProvider {
    public typealias SQLiteValue = Int
    public init?(value: SQLiteValue) {
        self = value
    }
    public func value() -> Int? {
        return self
    }
    public init?(stringValue: String) {
        if let value = Int(stringValue) {
            self = value
        }else {
            return nil
        }
    }
    public func stringValue() -> String? { return String(self) }
}
extension Date: SQLiteValueProvider {
    public typealias SQLiteValue = Date
    public init?(value: SQLiteValue) {
        self = value
    }
    public func value() -> Date? {
        return self
    }
    public init(stringValue: String) {
        self = Date.fromDatatypeValue(stringValue)
    }
    public func stringValue() -> String? {
        return datatypeValue
    }
}
extension Data: SQLiteValueProvider {
    public typealias SQLiteValue = Data
    public init?(value: SQLiteValue) {
        self = value
    }
    public func value() -> Data? {
        return self
    }
    public init(stringValue: String) {
        if let blob = Blob(stringValue: stringValue) {
            self = Data.fromDatatypeValue(blob)
        }
        self = Data()
    }
    public func stringValue() -> String? {
        return datatypeValue.toHex()
    }
}

extension Array: SQLiteValueProvider where Element: SQLiteValueProvider {
    public typealias SQLiteValue = String
    static var separator: String { "|MASep|" }
    public init?(value: SQLiteValue) {
        let components = value.components(separatedBy: Array.separator)
        self = components.compactMap { Element.init(stringValue: $0) }
    }
    public func value() -> SQLiteValue? {
        var result = ""
        for elment in self {
            guard let value = elment.stringValue() else {
                continue
            }
            result.append(Array.separator + value)
        }
        return result
    }
    public init?(stringValue: String) {
        self.init(value: stringValue)
    }
    public func stringValue() -> String? { return value() }
}

extension Dictionary: SQLiteValueProvider where Key: SQLiteValueProvider, Value: SQLiteValueProvider {
    public typealias SQLiteValue = String
    public init?(value: SQLiteValue) {
        if let dictValue = Dictionary.fromString(value: value) {
            self = dictValue
        }else {
            return nil
        }
    }
    public func value() -> SQLiteValue? { return stringValue() }
    public init?(stringValue: String) {
        if let dictValue = Dictionary.fromString(value: stringValue) {
            self = dictValue
        }else {
            return nil
        }
    }
    public func stringValue() -> String? {
        var result = [String : String]()
        for (key, value) in self {
            guard let keyValue = key.stringValue(), let stringValue = value.stringValue() else {
                continue
            }
            result[keyValue] = stringValue
        }
        guard let data = try? JSONSerialization.data(withJSONObject: result, options: []) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    private static func fromString(value: String) -> Self? {
        guard let dict = try? JSONSerialization.jsonObject(with: Data(value.utf8), options: []) as? [String : String] else {
            return nil
        }
        var result = [Key: Value]()
        for (key, item) in dict {
            guard let resultKey = Key.init(stringValue: key), let resultVaule = Value.init(stringValue: item) else {
                continue
            }
            result[resultKey] = resultVaule
        }
        return result
    }
}

extension Field: FieldStorageWrappedBaseProtocol where Value: SQLiteValueProvider { }
extension Field: FieldStorageWrappedProtocol where Value: SQLiteValueProvider {
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
        if let rowValue = try? row.get(expression), let value = Value.init(value: rowValue) {
            self.wrappedValue = value
        }
    }

    public func createColumn(tableBuilder: TableBuilder) {
        tableBuilder.column(expression)
    }

    public func addColumn(table: Table) -> String? {
        if let value = self.storageParams?.defaultValue?.value() {
            return table.addColumn(expression, defaultValue: value)
        }else {
            assertionFailure("Must provide defaultValue")
            return nil
        }
    }
}

extension FieldOptional: FieldStorageWrappedBaseProtocol where Value: SQLiteValueProvider { }
extension FieldOptional: FieldOptionalStorageWrappedProtocol where Value: SQLiteValueProvider {
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
        if let value = try? row.get(expression) {
            self.wrappedValue = Value.init(value: value)
        }else {
            self.wrappedValue = nil
        }
    }

    public func createColumn(tableBuilder: TableBuilder) {
        tableBuilder.column(expression)
    }

    public func addColumn(table: Table) -> String? {
        return table.addColumn(expression, defaultValue: self.storageParams?.defaultValue?.value())
    }
}

extension FieldCustom: FieldStorageWrappedBaseProtocol where Value: SQLiteValueProvider { }
extension FieldCustom: FieldCustomStorageWrappedProtocol where Value: SQLiteValueProvider {
    public var expression: Expression<Value.SQLiteValue?> {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.expressionCustom, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.expressionCustom) as! Expression<Value.SQLiteValue?>
        }
    }

    public func setter() -> Setter? {
        return self.expression <- self.wrappedValue.value()
    }

    public func initExpresionIfNeeded(key: String) {
        if objc_getAssociatedObject(self, &AssociatedKeys.expressionCustom) == nil {
            self.expression = Expression<Value.SQLiteValue?>(key)
        }
    }

    public func update(row: Row) {
        if let stroageValue = try? row.get(expression), let value = Value.init(value: stroageValue) {
            self.wrappedValue = value
        }
    }

    public func createColumn(tableBuilder: TableBuilder) {
        tableBuilder.column(expression)
    }

    public func addColumn(table: Table) -> String? {
        return table.addColumn(expression, defaultValue: self.storageParams?.defaultValue?.value())
    }
}

extension FieldOptionalCustom: FieldStorageWrappedBaseProtocol where Value: SQLiteValueProvider { }
extension FieldOptionalCustom: FieldCustomStorageWrappedProtocol where Value: SQLiteValueProvider {
    public var expression: Expression<Value.SQLiteValue?> {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.expressionOptionalCustom, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.expressionOptionalCustom) as! Expression<Value.SQLiteValue?>
        }
    }

    public func setter() -> Setter? {
        return self.expression <- self.wrappedValue?.value()
    }

    public func initExpresionIfNeeded(key: String) {
        if objc_getAssociatedObject(self, &AssociatedKeys.expressionOptionalCustom) == nil {
            self.expression = Expression<Value.SQLiteValue?>(key)
        }
    }

    public func update(row: Row) {
        if let value = try? row.get(expression) {
            self.wrappedValue = Value.init(value: value)
        }else {
            self.wrappedValue = nil
        }
    }

    public func createColumn(tableBuilder: TableBuilder) {
        tableBuilder.column(expression)
    }

    public func addColumn(table: Table) -> String? {
        return table.addColumn(expression, defaultValue: self.storageParams?.defaultValue?.value())
    }
}
