//
//  Defines.swift
//  ModelAdaptor
//
//  Created by jiaxin on 2020/6/14.
//  Copyright © 2020 jiaxin. All rights reserved.
//

import Foundation
import SQLite

class StorageParams {
    var key: String? = nil
    var primaryKey: SQLite.PrimaryKey? = nil
    var unique: Bool = false
    var collate: SQLite.Collation? = nil
    
    init(key: String? = nil, primaryKey: SQLite.PrimaryKey? = nil, unique: Bool = false, collate: SQLite.Collation? = nil) {
        self.key = key
        self.primaryKey = primaryKey
        self.unique = unique
        self.collate = collate
    }
}

extension Field: FieldIdentifierProtocol { }

@propertyWrapper public class Field<Value> {
    public var wrappedValue: Value
    public var projectedValue: Field { self }
    let params: StorageParams

    public init(wrappedValue: Value, key: String? = nil, primaryKey: SQLite.PrimaryKey? = nil, unique: Bool = false, collate: SQLite.Collation? = nil)  {
        self.wrappedValue = wrappedValue
        self.params = StorageParams(key: key, primaryKey: primaryKey, unique: unique, collate: collate)

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

@propertyWrapper public class FieldOptional<Value> {
    public var wrappedValue: Value?
    public var projectedValue: FieldOptional { self }
    let params: StorageParams

    public init(wrappedValue: Value? = nil, key: String? = nil, collate: SQLite.Collation? = nil) {
        self.wrappedValue = wrappedValue
        self.params = StorageParams(key: key, collate: collate)
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

