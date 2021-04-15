//
//  ObjectMapperAdaptor.swift
//  ModelAdaptor
//
//  Created by jiaxin on 2020/6/14.
//

import Foundation
import ObjectMapper
import SQLite

public extension ModelAdaptorModel {
    mutating func mapping(map: Map) {
        initExpressionsIfNeeded()
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            guard let propertyName = child.label else {
                continue
            }
            if let value = child.value as? FieldMappableWrappedProtocol {
                value.mapperClosure?(KeyManager.codingKey(propertyName: propertyName, key: value.key, codingKey: value.codingKey), map)
            }else if let value =  child.value as? FieldOptionalMappableWrappedProtocol {
                value.mapperClosure?(KeyManager.codingKey(propertyName: propertyName, key: value.key, codingKey: value.codingKey), map)
            }
        }
        if let customModel = self as? ModelAdaptorCustomMap {
            customModel.customMap(map: map)
        }
    }
}

public struct NilJSON {}
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
