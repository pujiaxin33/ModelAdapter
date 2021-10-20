//
//  Defines.swift
//  ModelAdapter
//
//  Created by jiaxin on 2020/6/14.
//  Copyright © 2020 jiaxin. All rights reserved.
//

import Foundation
import SQLite

class StorageParams<Value> {
    var key: String? = nil
    var isPrimaryKey: Bool? = nil
    var primaryKey: SQLite.PrimaryKey? = nil
    var unique: Bool = false
    var collate: SQLite.Collation? = nil
    var check: ((Expression<Value>) -> Expression<Bool>)? = nil
    var checkOptional: ((Expression<Value?>) -> Expression<Bool?>)? = nil
    
    init(key: String? = nil, isPrimaryKey: Bool? = nil, primaryKey: SQLite.PrimaryKey? = nil, unique: Bool = false, collate: SQLite.Collation? = nil, check: ((Expression<Value>) -> Expression<Bool>)? = nil, checkOptional: ((Expression<Value?>) -> Expression<Bool?>)? = nil) {
        self.key = key
        self.isPrimaryKey = isPrimaryKey
        self.primaryKey = primaryKey
        self.unique = unique
        self.collate = collate
        self.check = check
        self.checkOptional = checkOptional
    }
}

extension Field: FieldIdentifierProtocol { }

@propertyWrapper public class Field<Value> {
    public var wrappedValue: Value
    public var projectedValue: Field { self }
    let key: String?
    let params: StorageParams<Value>

    public init(wrappedValue: Value, key: String? = nil, primaryKey: Bool? = nil, check: ((Expression<Value>) -> Expression<Bool>)? = nil)  {
        self.wrappedValue = wrappedValue
        self.params = StorageParams(key: key, isPrimaryKey: primaryKey, check: check)
        self.key = key

        if wrappedValue is ExpressibleByNilLiteral {
            assertionFailure("Use @FieldOptional when value is optional")
        }
    }
    public init(wrappedValue: Value, key: String? = nil, unique: Bool = false, check: ((Expression<Value>) -> Expression<Bool>)? = nil)  {
        self.wrappedValue = wrappedValue
        self.params = StorageParams(key: key, unique: unique, check: check)
        self.key = key
        
        if wrappedValue is ExpressibleByNilLiteral {
            assertionFailure("Use @FieldOptional when value is optional")
        }
    }
    
    public init(wrappedValue: Value, key: String? = nil, primaryKey: SQLite.PrimaryKey? = nil, check: ((Expression<Value>) -> Expression<Bool>)? = nil) where Value == Int64  {
        self.wrappedValue = wrappedValue
        self.params = StorageParams(key: key, primaryKey: primaryKey, check: check)
        self.key = key
        
        if wrappedValue is ExpressibleByNilLiteral {
            assertionFailure("Use @FieldOptional when value is optional")
        }
    }
    public init(wrappedValue: Value, key: String? = nil, primaryKey: SQLite.PrimaryKey? = nil, collate: SQLite.Collation? = nil, check: ((Expression<Value>) -> Expression<Bool>)? = nil) where Value == String  {
        self.wrappedValue = wrappedValue
        self.params = StorageParams(key: key, primaryKey: primaryKey, collate: collate, check: check)
        self.key = key
        
        if wrappedValue is ExpressibleByNilLiteral {
            assertionFailure("Use @FieldOptional when value is optional")
        }
    }
    public init(wrappedValue: Value, key: String? = nil, unique: Bool = false, collate: SQLite.Collation? = nil, check: ((Expression<Value>) -> Expression<Bool>)? = nil) where Value == String  {
        self.wrappedValue = wrappedValue
        self.params = StorageParams(key: key, unique: unique, collate: collate, check: check)
        self.key = key
        
        if wrappedValue is ExpressibleByNilLiteral {
            assertionFailure("Use @FieldOptional when value is optional")
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

extension FieldOptional: FieldIdentifierProtocol {}

@propertyWrapper public class FieldOptional<Value> {
    public var wrappedValue: Value?
    public var projectedValue: FieldOptional { self }
    let key: String?
    let params: StorageParams<Value>

    public init(wrappedValue: Value? = nil, key: String? = nil, unique: Bool = false, check: ((Expression<Value?>) -> Expression<Bool?>)? = nil)  {
        self.wrappedValue = wrappedValue
        self.params = StorageParams(key: key, unique: unique, checkOptional: check)
        self.key = key
    }
    public init(wrappedValue: Value? = nil, key: String? = nil, unique: Bool = false, collate: SQLite.Collation? = nil, check: ((Expression<Value?>) -> Expression<Bool?>)? = nil) where Value == String  {
        self.wrappedValue = wrappedValue
        self.params = StorageParams(key: key, unique: unique, collate: collate, checkOptional: check)
        self.key = key
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

