//
//  SQLiteValueExtension.swift
//  SQLiteValueExtension
//
//  Created by jiaxin on 2020/7/14.
//  Copyright © 2020 jiaxin. All rights reserved.
//

import Foundation
import SQLite

public protocol StringValueExpressible  {
    associatedtype ValueType = Self
    static func fromStringValue(_ stringValue: String) -> ValueType
    var stringValue: String { get }
}

extension Int: StringValueExpressible {
    public static func fromStringValue(_ stringValue: String) -> Int {
        return Int(stringValue) ?? 0
    }
    public var stringValue: String {
        return String(self)
    }
}
extension Int64: StringValueExpressible {
    public static func fromStringValue(_ stringValue: String) -> Int64 {
        return Int64(stringValue) ?? 0
    }
    public var stringValue: String {
        return String(self)
    }
}
extension Bool: StringValueExpressible {
    public static func fromStringValue(_ stringValue: String) -> Bool {
        return Bool(stringValue) ?? false
    }
    public var stringValue: String {
        return String(self)
    }
}
extension Double: StringValueExpressible {
    public static func fromStringValue(_ stringValue: String) -> Double {
        return Double(stringValue) ?? 0
    }
    public var stringValue: String {
        return String(self)
    }
}
extension String: StringValueExpressible {
    public static func fromStringValue(_ stringValue: String) -> String {
        return stringValue
    }
    public var stringValue: String {
        return self
    }
}
extension Blob: StringValueExpressible {
    public static func fromStringValue(_ stringValue: String) -> Blob {
        var bytes = [UInt8]()
        for start in stride(from: 0, to: stringValue.count, by: 2) {
            let startIndex = stringValue.index(stringValue.startIndex, offsetBy: start)
            let endIndex = stringValue.index(startIndex, offsetBy: 2)
            let byteString = stringValue[startIndex..<endIndex]
            bytes.append(UInt8(byteString, radix: 16) ?? 0)
        }
        return Blob.init(bytes: bytes)
    }
    public var stringValue: String {
        return toHex()
    }
}
extension Data: StringValueExpressible {
    public static func fromStringValue(_ stringValue: String) -> Data {
        return fromDatatypeValue(Blob.fromStringValue(stringValue))
    }
    public var stringValue: String {
        return datatypeValue.toHex()
    }
}
extension Date: StringValueExpressible {
    public static func fromStringValue(_ stringValue: String) -> Date {
        return fromDatatypeValue(stringValue)
    }
    public var stringValue: String {
        return datatypeValue
    }
}
//=====================Add New Type =====================
extension Float: Value, StringValueExpressible {
    public static var declaredDatatype: String { Double.declaredDatatype }
    public static func fromDatatypeValue(_ datatypeValue: Double) -> Float {
        return Float(datatypeValue)
    }
    public var datatypeValue: Double {
        return Double(self)
    }
    public static func fromStringValue(_ stringValue: String) -> Float {
        return Float(stringValue) ?? 0
    }
    public var stringValue: String {
        return String(self)
    }
}

//=====================Extension Array=====================
extension Array: Expressible where Element: StringValueExpressible {
    public var expression: Expression<Void> {
        return Expression(value: self).expression
    }
}
extension Array: Value where Element: StringValueExpressible {
    public typealias Datatype = String
    public static var declaredDatatype: String { String.declaredDatatype }
    public static func fromStringValue(_ stringValue: String) -> Self {
        var result = [Element]()
        if let object = try? JSONSerialization.jsonObject(with: Data(stringValue.utf8), options: []) as? [String] {
            for string in object {
                let value = Element.fromStringValue(string) as! Element
                result.append(value)
            }
        }
        return result
    }
    public var stringValue: String {
        let stringArray = self.map { $0.stringValue }
        if let data = try? JSONSerialization.data(withJSONObject: stringArray, options: []) {
            return String(data: data, encoding: .utf8) ?? ""
        }
        return ""
    }
    public static func fromDatatypeValue(_ datatypeValue: Datatype) -> Self {
        return fromStringValue(datatypeValue)
    }
    public var datatypeValue: Datatype {
        return stringValue
    }
}
//=====================Extension Dictionary=====================
extension Dictionary: Expressible where Key: StringValueExpressible, Value: StringValueExpressible {
    public var expression: Expression<Void> {
        return Expression(value: self).expression
    }
}
extension Dictionary: SQLite.Value where Dictionary.Key: StringValueExpressible, Dictionary.Value: StringValueExpressible {
    public typealias Datatype = String
    public static var declaredDatatype: String { String.declaredDatatype }
    public static func fromStringValue(_ stringValue: String) -> Self {
        var result = [Key:Value]()
        if let object = try? JSONSerialization.jsonObject(with: Data(stringValue.utf8), options: []) as? [String:String] {
            for (key, value) in object {
                let resultKey = Key.fromStringValue(key) as! Key
                let resultValue = Value.fromStringValue(value) as! Value
                result[resultKey] = resultValue
            }
        }
        return result
    }
    public var stringValue: String {
        var result = [String:String]()
        for (key, value) in self {
            result[key.stringValue] = value.stringValue
        }
        if let data = try? JSONSerialization.data(withJSONObject: result, options: []) {
            return String(data: data, encoding: .utf8) ?? ""
        }
        return ""
    }
    public static func fromDatatypeValue(_ datatypeValue: Datatype) -> Self {
        return fromStringValue(datatypeValue)
    }
    public var datatypeValue: Datatype {
        return stringValue
    }
}

//=====================For Easy Use=====================
public protocol SQLiteValueStorable: Value, StringValueExpressible { }
public extension SQLiteValueStorable {
    static var declaredDatatype: String { String.declaredDatatype }
    var datatypeValue: String { stringValue }
    static func fromDatatypeValue(_ datatypeValue: String) -> Self {
        return fromStringValue(datatypeValue) as! Self
    }
}
