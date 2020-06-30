//
//  Defines.swift
//  ModelAdaptor
//
//  Created by jiaxin on 2020/6/14.
//  Copyright © 2020 jiaxin. All rights reserved.
//

import Foundation
import ObjectMapper
import SQLite

open class CodingParams<Convertor: TransformType>{
    public let key: String?
    public let convertor: Convertor?
    public let nested: Bool?
    public let delimiter: String
    public let ignoreNil: Bool

    public init(key: String? = nil, convertor: Convertor? = nil, nested: Bool? = nil, delimiter: String = ".", ignoreNil: Bool = false) {
        self.key = key
        self.convertor = convertor
        self.nested = nested
        self.delimiter = delimiter
        self.ignoreNil = ignoreNil
    }
}

open class StorageParams<Value> {
    public let key: String?
    public let version: Int
    public let defaultValue: Value?
    public init(key: String? = nil, version: Int = 1, defaultValue: Value? = nil) {
        self.key = key
        self.version = version
        self.defaultValue = defaultValue
    }
}

@propertyWrapper public class Field<Value> {
    public var wrappedValue: Value
    public var projectedValue: Field { self }
    let key: String?
    var codingKey: String?
    var storageKey: String?
    var storageVersion: Int?
    var storageParams: StorageParams<Value>?
    var mapperClosure: ((String, Map) -> ())?
    var immutableMapperClosure: ((String, Map) -> ())?

    public init<Convertor: TransformType>(wrappedValue: Value, key: String? = nil, codingParams: CodingParams<Convertor>? = nil, storageParams: StorageParams<Value>? = nil) where Convertor.Object == Value {
        self.wrappedValue = wrappedValue
        self.key = key
        self.codingKey = codingParams?.key
        self.storageParams = storageParams
        self.storageKey = storageParams?.key
        self.storageVersion = storageParams?.version

        if wrappedValue is ExpressibleByNilLiteral {
            assertionFailure("Use FieldOptional when value is optional")
        }
        if let aClass = self as? BaseMappableWrappedProtocol {
            aClass.configBaseMappableMapperClosure()
        }else {
            configMapperConvertorClosure(codingParams: codingParams)
        }
    }
    convenience public init(wrappedValue: Value) {
        self.init(wrappedValue: wrappedValue, key: nil, storageParams: nil)
    }
    convenience public init(wrappedValue: Value, key: String?) {
        self.init(wrappedValue: wrappedValue, key: key, storageParams: nil)
    }
    convenience public init<Convertor: TransformType>(wrappedValue: Value, codingParams: CodingParams<Convertor>?) where Convertor.Object == Value {
        self.init(wrappedValue: wrappedValue, key: nil, codingParams: codingParams, storageParams: nil)
    }
    convenience public init(wrappedValue: Value, storageParams: StorageParams<Value>?) {
        self.init(wrappedValue: wrappedValue, key: nil, storageParams: storageParams)
    }
    convenience public init<Convertor: TransformType>(wrappedValue: Value, key: String?, codingParams: CodingParams<Convertor>?) where Convertor.Object == Value {
        self.init(wrappedValue: wrappedValue, key: key, codingParams: codingParams, storageParams: nil)
    }
    public init(wrappedValue: Value, key: String?, storageParams: StorageParams<Value>?) {
        self.wrappedValue = wrappedValue
        self.key = key
        self.storageParams = storageParams
        self.storageKey = storageParams?.key
        self.storageVersion = storageParams?.version

        if wrappedValue is ExpressibleByNilLiteral {
            assertionFailure("Use FieldOptional when value is optional")
        }
        if let aClass = self as? BaseMappableWrappedProtocol {
            aClass.configBaseMappableMapperClosure()
        }else {
            configMapperClosure()
        }
    }
    convenience public init<Convertor: TransformType>(wrappedValue: Value, codingParams: CodingParams<Convertor>?, storageParams: StorageParams<Value>?) where Convertor.Object == Value {
        self.init(wrappedValue: wrappedValue, key: nil, codingParams: codingParams, storageParams: storageParams)
    }
}

@propertyWrapper public class FieldOptional<Value> {
    public var wrappedValue: Value?
    public var projectedValue: FieldOptional { self }
    let key: String?
    var codingKey: String?
    var storageParams: StorageParams<Value>?
    var storageKey: String?
    var storageVersion: Int?
    var mapperClosure: ((String, Map) -> ())?
    var immutableMapperClosure: ((String, Map) -> ())?

    public init<Convertor: TransformType>(wrappedValue: Value?, key: String? = nil, codingParams: CodingParams<Convertor>? = nil, storageParams: StorageParams<Value>? = nil) where Convertor.Object == Value {
        self.wrappedValue = wrappedValue
        self.key = key
        self.codingKey = codingParams?.key
        self.storageParams = storageParams
        self.storageKey = storageParams?.key
        self.storageVersion = storageParams?.version

        if let aClass = self as? BaseMappableWrappedProtocol {
            aClass.configBaseMappableMapperClosure()
        }else {
            configMapperConvertorClosure(codingParams: codingParams)
        }
    }
    convenience public init(wrappedValue: Value?) {
        self.init(wrappedValue: wrappedValue, key: nil, storageParams: nil)
    }
    convenience public init(wrappedValue: Value? = nil, key: String?) {
        self.init(wrappedValue: wrappedValue, key: key, storageParams: nil)
    }
    convenience public init<Convertor: TransformType>(wrappedValue: Value? = nil, codingParams: CodingParams<Convertor>?) where Convertor.Object == Value {
        self.init(wrappedValue: wrappedValue, key: nil, codingParams: codingParams, storageParams: nil)
    }
    convenience public init(wrappedValue: Value? = nil, storageParams: StorageParams<Value>?) {
        self.init(wrappedValue: wrappedValue, key: nil, storageParams: storageParams)
    }
    convenience public init<Convertor: TransformType>(wrappedValue: Value? = nil, key: String?, codingParams: CodingParams<Convertor>?) where Convertor.Object == Value {
        self.init(wrappedValue: wrappedValue, key: key, codingParams: codingParams, storageParams: nil)
    }
    public init(wrappedValue: Value? = nil, key: String?, storageParams: StorageParams<Value>?) {
        self.wrappedValue = wrappedValue
        self.key = key
        self.storageParams = storageParams
        self.storageKey = storageParams?.key
        self.storageVersion = storageParams?.version

        if let aClass = self as? BaseMappableWrappedProtocol {
            aClass.configBaseMappableMapperClosure()
        }else {
            configMapperClosure()
        }
    }
    convenience public init<Convertor: TransformType>(wrappedValue: Value? = nil, codingParams: CodingParams<Convertor>?, storageParams: StorageParams<Value>?) where Convertor.Object == Value {
        self.init(wrappedValue: wrappedValue, key: nil, codingParams: codingParams, storageParams: storageParams)
    }
}



