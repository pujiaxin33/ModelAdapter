//
//  Defines.swift
//  ModelAdaptor
//
//  Created by jiaxin on 2020/6/14.
//  Copyright © 2020 jiaxin. All rights reserved.
//

import Foundation
import ObjectMapper

@propertyWrapper public class Entity<Value> {
    public var wrappedValue: Value
    public let key: String?
    public let codingKey: String?
    public let storageKey: String?
    var convertorClosure: ((String,Map) -> ())?

    public init(wrappedValue: Value, key: String?, codingKey: String?, storageKey: String?) {
        self.wrappedValue = wrappedValue
        self.key = key
        self.codingKey = codingKey
        self.storageKey = storageKey
    }
    convenience public init(wrappedValue: Value) {
        self.init(wrappedValue: wrappedValue, key: nil, codingKey: nil, storageKey: nil)
    }
    convenience public init(wrappedValue: Value, key: String?) {
        self.init(wrappedValue: wrappedValue, key: key, codingKey: nil, storageKey: nil)
    }
    convenience public init(wrappedValue: Value, codingKey: String?) {
        self.init(wrappedValue: wrappedValue, key: nil, codingKey: codingKey, storageKey: nil)
    }
    convenience public init(wrappedValue: Value, storageKey: String?) {
        self.init(wrappedValue: wrappedValue, key: nil, codingKey: nil, storageKey: storageKey)
    }
    convenience public init(wrappedValue: Value, key: String?, codingKey: String?) {
        self.init(wrappedValue: wrappedValue, key: key, codingKey: codingKey, storageKey: nil)
    }
    convenience public init(wrappedValue: Value, key: String?, storageKey: String?) {
        self.init(wrappedValue: wrappedValue, key: key, codingKey: nil, storageKey: storageKey)
    }
    convenience public init(wrappedValue: Value, codingKey: String?, storageKey: String?) {
        self.init(wrappedValue: wrappedValue, key: nil, codingKey: codingKey, storageKey: storageKey)
    }

    convenience public init<Convertor: TransformType>(wrappedValue: Value, convertor: Convertor?) where Convertor.Object == Value {
        self.init(wrappedValue: wrappedValue, key: nil, codingKey: nil, storageKey: nil)

        self.convertorClosure = {[weak self] (key, map) in
            guard let self = self else { return }
            if let convertor = convertor {
                self.wrappedValue <- (map[key], convertor)
            }else {
                self.wrappedValue <- map[key]
            }
        }
    }
}

public extension Entity where Value: ExpressibleByNilLiteral {
    convenience init(key: String? = nil, codingKey: String? = nil, storageKey: String? = nil) {
        self.init(wrappedValue: nil, key: key, codingKey: codingKey, storageKey: storageKey)
    }
    convenience init<Convertor: TransformType>(convertor: Convertor?) where Convertor.Object? == Value {
        self.init(wrappedValue: nil, key: nil, codingKey: nil, storageKey: nil)

        self.convertorClosure = {[weak self] (key, map) in
            guard let self = self else { return }
            if let convertor = convertor {
                self.wrappedValue <- (map[key], convertor)
            }else {
                self.wrappedValue <- map[key]
            }
        }
    }
}

extension Entity: EntityWrappedAny {}




