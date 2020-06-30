//
//  ObjectMapperAdaptor.swift
//  ModelAdaptor
//
//  Created by jiaxin on 2020/6/14.
//

import Foundation
import ObjectMapper
import SQLite

public protocol ModelAdaptorMappable: Mappable { }

public extension ModelAdaptorMappable {
    mutating func mapping(map: Map) {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            guard let propertyName = child.label else {
                continue
            }
            if let value = child.value as? FieldMappableWrappedProtocol {
                value.convertorClosure?(KeyManager.codingKey(propertyName: propertyName, key: value.key, codingKey: value.codingKey), map)
            }else if let value =  child.value as? FieldOptionalMappableWrappedProtocol {
                value.convertorClosure?(KeyManager.codingKey(propertyName: propertyName, key: value.key, codingKey: value.codingKey), map)
            }
        }
        if let aClass = self as? ModelAdaptorStorable {
            //fixme:找一个更好的地方进行数据库expresstion属性初始化
            aClass.initExpressionsIfNeeded()
        }
    }
}

public protocol ModelAdaptorImmutableMappable: ImmutableMappable { }

public extension ModelAdaptorImmutableMappable {
    mutating func mapping(map: Map) {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            guard let propertyName = child.label else {
                continue
            }
            guard let value = child.value as? FieldMappableWrappedProtocol else {
                continue
            }
            value.immutableConvertorClosure?(KeyManager.codingKey(propertyName: propertyName, key: value.key, codingKey: value.codingKey), map)
        }
        if let aClass = self as? ModelAdaptorStorable {
            //fixme:找一个更好的地方进行数据库expresstion属性初始化
            aClass.initExpressionsIfNeeded()
        }
    }
}


public struct NilJSON {
}

public class NilTransform<NilValue>: TransformType {
    public typealias Object = NilValue
    public typealias JSON = NilJSON
    public func transformFromJSON(_ value: Any?) -> Object? {
        return nil
    }
    public func transformToJSON(_ value: Object?) -> NilJSON? {
        return NilJSON()
    }
    public init() { }
}
