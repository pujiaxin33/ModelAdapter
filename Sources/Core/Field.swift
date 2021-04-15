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

/// 因为TransformType协议有关联类型，所以导致CodingParams变成了泛型类型。某些情况不需要配置convertor，只需要配置key、nested、delimiter等参数时，就传递一个NilTransform的实例即可，防止编译器报错。
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
    public let isNewField: Bool
    public let defaultValue: Value?
    public init(key: String? = nil, isNewField: Bool = false, defaultValue: Value? = nil) {
        self.key = key
        self.isNewField = isNewField
        self.defaultValue = defaultValue
    }
}

extension Field: FieldWrappedProtocol { }

@propertyWrapper public class Field<Value> {
    public var wrappedValue: Value
    public var projectedValue: Field { self }
    let key: String?
    var codingKey: String?
    var storageKey: String?
    var storageIsNewField: Bool = false
    var storageParams: StorageParams<Value>?
    var mapperClosure: ((String, Map) -> ())?
    var immutableMapperClosure: ((String, Map) -> ())?

    public init<Convertor: TransformType>(wrappedValue: Value, key: String? = nil, codingParams: CodingParams<Convertor>? = nil, storageParams: StorageParams<Value>? = nil) where Convertor.Object == Value {
        self.wrappedValue = wrappedValue
        self.key = key
        self.codingKey = codingParams?.key
        self.storageParams = storageParams
        self.storageKey = storageParams?.key
        self.storageIsNewField = storageParams?.isNewField ?? false

        if wrappedValue is ExpressibleByNilLiteral {
            assertionFailure("Use FieldOptional when value is optional")
        }
        if let aClass = self as? BaseMappableValueWrappedProtocol {
            aClass.configBaseMappableMapperClosure()
        }else {
            configMapperConvertorClosure(codingParams: codingParams)
        }
    }

    public init(wrappedValue: Value, key: String? = nil, storageParams: StorageParams<Value>? = nil) {
        self.wrappedValue = wrappedValue
        self.key = key
        self.storageParams = storageParams
        self.storageKey = storageParams?.key
        self.storageIsNewField = storageParams?.isNewField ?? false

        if wrappedValue is ExpressibleByNilLiteral {
            assertionFailure("Use FieldOptional when value is optional")
        }
        if let aClass = self as? BaseMappableValueWrappedProtocol {
            aClass.configBaseMappableMapperClosure()
        }else {
            configMapperClosure()
        }
    }
}

@propertyWrapper public class FieldOptional<Value> {
    public var wrappedValue: Value?
    public var projectedValue: FieldOptional { self }
    let key: String?
    var codingKey: String?
    var storageParams: StorageParams<Value>?
    var storageKey: String?
    var storageIsNewField: Bool = false
    var mapperClosure: ((String, Map) -> ())?
    var immutableMapperClosure: ((String, Map) -> ())?

    public init<Convertor: TransformType>(wrappedValue: Value? = nil, key: String? = nil, codingParams: CodingParams<Convertor>? = nil, storageParams: StorageParams<Value>? = nil) where Convertor.Object == Value {
        self.wrappedValue = wrappedValue
        self.key = key
        self.codingKey = codingParams?.key
        self.storageParams = storageParams
        self.storageKey = storageParams?.key
        self.storageIsNewField = storageParams?.isNewField ?? false

        if let aClass = self as? BaseMappableValueWrappedProtocol {
            aClass.configBaseMappableMapperClosure()
        }else {
            configMapperConvertorClosure(codingParams: codingParams)
        }
    }
    public init(wrappedValue: Value? = nil, key: String? = nil, storageParams: StorageParams<Value>? = nil) {
        self.wrappedValue = wrappedValue
        self.key = key
        self.storageParams = storageParams
        self.storageKey = storageParams?.key
        self.storageIsNewField = storageParams?.isNewField ?? false

        if let aClass = self as? BaseMappableValueWrappedProtocol {
            aClass.configBaseMappableMapperClosure()
        }else {
            configMapperClosure()
        }
    }
}

extension FieldCustom: FieldWrappedProtocol { }
@propertyWrapper public class FieldCustom<Value> {
    public var wrappedValue: Value
    public var projectedValue: FieldCustom { self }
    let key: String?
    var storageKey: String?
    var storageIsNewField: Bool = false
    var storageParams: StorageParams<Value>?

    public init(wrappedValue: Value, key: String? = nil, storageParams: StorageParams<Value>? = nil) {
        self.wrappedValue = wrappedValue
        self.key = key
        self.storageParams = storageParams
        self.storageKey = storageParams?.key
        self.storageIsNewField = storageParams?.isNewField ?? false
        if wrappedValue is ExpressibleByNilLiteral {
            assertionFailure("Use FieldOptionalCustom when value is optional")
        }
    }
}

extension FieldOptionalCustom: FieldWrappedProtocol { }
@propertyWrapper public class FieldOptionalCustom<Value> {
    public var wrappedValue: Value?
    public var projectedValue: FieldOptionalCustom { self }
    let key: String?
    var storageKey: String?
    var storageIsNewField: Bool = false
    var storageParams: StorageParams<Value>?

    public init(wrappedValue: Value? = nil, key: String? = nil, storageParams: StorageParams<Value>? = nil) {
        self.wrappedValue = wrappedValue
        self.key = key
        self.storageParams = storageParams
        self.storageKey = storageParams?.key
        self.storageIsNewField = storageParams?.isNewField ?? false
    }
}
