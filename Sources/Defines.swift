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

open class StorageParams {
    public let key: String?
    public let version: Int
    public init(key: String?, version: Int = 1) {
        self.key = key
        self.version = version
    }
}

@propertyWrapper public class Field<Value> {
    public var wrappedValue: Value
    public let key: String?
    public var codingKey: String?
    public var storageKey: String?
    public var storageVersion: Int?
    public var projectedValue: Field { self }
    var convertorClosure: ((String, Map) -> ())?
    var immutableConvertorClosure: ((String, Map) -> ())?

    public init<Convertor: TransformType>(wrappedValue: Value, key: String?, codingParams: CodingParams<Convertor>?, storageParams: StorageParams?) where Convertor.Object == Value {
        self.wrappedValue = wrappedValue
        self.key = key
        self.codingKey = codingParams?.key
        self.storageKey = storageParams?.key
        self.storageVersion = storageParams?.version

        configMapperClosure(codingParams: codingParams)
    }
    convenience public init(wrappedValue: Value) {
        self.init(wrappedValue: wrappedValue, key: nil, codingParams: CodingParams(key: nil, convertor: NilTransform<Value>()), storageParams: nil)
    }
    convenience public init(wrappedValue: Value, key: String?) {
        self.init(wrappedValue: wrappedValue, key: key, codingParams: CodingParams(key: nil, convertor: NilTransform<Value>()), storageParams: nil)
    }
    convenience public init<Convertor: TransformType>(wrappedValue: Value, codingParams: CodingParams<Convertor>?) where Convertor.Object == Value {
        self.init(wrappedValue: wrappedValue, key: nil, codingParams: codingParams, storageParams: nil)
    }
    convenience public init(wrappedValue: Value, storageParams: StorageParams?) {
        self.init(wrappedValue: wrappedValue, key: nil, codingParams: CodingParams(key: nil, convertor: NilTransform<Value>()), storageParams: storageParams)
    }
    convenience public init<Convertor: TransformType>(wrappedValue: Value, key: String?, codingParams: CodingParams<Convertor>?) where Convertor.Object == Value {
        self.init(wrappedValue: wrappedValue, key: key, codingParams: codingParams, storageParams: nil)
    }
    convenience public init(wrappedValue: Value, key: String?, storageParams: StorageParams?) {
        self.init(wrappedValue: wrappedValue, key: key, codingParams: CodingParams(key: nil, convertor: NilTransform<Value>()), storageParams: storageParams)
    }
    convenience public init<Convertor: TransformType>(wrappedValue: Value, codingParams: CodingParams<Convertor>?, storageParams: StorageParams?) where Convertor.Object == Value {
        self.init(wrappedValue: wrappedValue, key: nil, codingParams: codingParams, storageParams: storageParams)
    }
}

public extension Field where Value: ExpressibleByNilLiteral {
    convenience init<Convertor: TransformType>(key: String? = nil, codingParams: CodingParams<Convertor>? = nil, storageParams: StorageParams? = nil) where Convertor.Object? == Value {
        self.init(wrappedValue: nil, key: key, storageParams: storageParams)
        self.codingKey = codingParams?.key

        configMapperOptionalClosure(codingParams: codingParams)
    }

    convenience init(key: String? = nil) {
        self.init(wrappedValue: nil, key: nil)
    }
    convenience init<Convertor: TransformType>(codingParams: CodingParams<Convertor>?) where Convertor.Object? == Value {
        self.init(key: nil, codingParams: codingParams, storageParams: nil)
    }
    convenience init(key: String?, storageParams: StorageParams?) {
        self.init(wrappedValue: nil, key: key, storageParams: storageParams)
    }
    convenience init<Convertor: TransformType>(key: String?, codingParams: CodingParams<Convertor>?) where Convertor.Object? == Value {
        self.init(key: key, codingParams: codingParams, storageParams: nil)
    }
    convenience init(wrappedValue: Value, key: String?, storageParams: StorageParams?) {
        self.init(wrappedValue: wrappedValue, key: key, codingParams: CodingParams(key: nil, convertor: NilTransform<Value>()), storageParams: storageParams)
    }
    convenience init<Convertor: TransformType>(wrappedValue: Value, codingParams: CodingParams<Convertor>?, storageParams: StorageParams?) where Convertor.Object == Value {
        self.init(wrappedValue: wrappedValue, key: nil, codingParams: codingParams, storageParams: storageParams)
    }
}




