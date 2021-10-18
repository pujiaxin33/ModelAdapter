//
//  Defines.swift
//  ModelAdaptor
//
//  Created by jiaxin on 2020/6/14.
//  Copyright © 2020 jiaxin. All rights reserved.
//

import Foundation
import SQLite

//enum StorageParamsEnum<Value> {
//    case key(String)
//    case primaryKey(SQLite.PrimaryKey)
//    case unique(Bool)
//    case defaultValue(Value)
//}

open class StorageParams<Value> {
    public let key: String?
    public let primaryKey: Bool
    public init(key: String? = nil, primaryKey: Bool = false) {
        self.key = key
        self.primaryKey = primaryKey
    }
}

extension Field: FieldIdentifierProtocol { }

@propertyWrapper public class Field<Value> {
    public var wrappedValue: Value
    public var projectedValue: Field { self }
    let key: String?
    var storageParams: StorageParams<Value>?
    var storageNormalParams: StorageNormalParams?

    public init(wrappedValue: Value, key: String? = nil, storageParams: StorageParams<Value>? = nil)  {
        self.wrappedValue = wrappedValue
        self.key = key
        self.storageParams = storageParams
        if let params = storageParams {
            self.storageNormalParams = StorageNormalParams(params: params)
        }

        if wrappedValue is ExpressibleByNilLiteral {
            assertionFailure("Use FieldOptional when value is optional")
        }
    }
}
extension Field: CustomStringConvertible {
    public var description: String {
        if let desc = self.wrappedValue as? CustomStringConvertible {
            return desc.description
        }else {
            let mirror = Mirror(reflecting: self.wrappedValue)
            return mirrorDescriptionPrettyPrinted(mirror.description)
        }
    }
}

@propertyWrapper public class FieldOptional<Value> {
    public var wrappedValue: Value?
    public var projectedValue: FieldOptional { self }
    let key: String?
    var storageParams: StorageParams<Value>?
    var storageNormalParams: StorageNormalParams?

    public init(wrappedValue: Value? = nil, key: String? = nil, storageParams: StorageParams<Value>? = nil) {
        self.wrappedValue = wrappedValue
        self.key = key
        self.storageParams = storageParams
        if let params = storageParams {
            self.storageNormalParams = StorageNormalParams(params: params)
        }
    }
}
extension FieldOptional: CustomStringConvertible {
    public var description: String {
        if let desc = self.wrappedValue as? CustomStringConvertible {
            return desc.description
        }else if let value = self.wrappedValue {
            let mirror = Mirror(reflecting: value)
            return mirrorDescriptionPrettyPrinted(mirror.description)
        }else {
            return "nil"
        }
    }
}

