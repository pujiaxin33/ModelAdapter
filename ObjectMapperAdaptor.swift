//
//  ObjectMapperAdaptor.swift
//  ModelAdaptor
//
//  Created by jiaxin on 2020/6/14.
//

import Foundation
import ObjectMapper

public protocol ModelAdaptorObjectMappable: Mappable {
    func mapping(map: Map)
}

public extension ModelAdaptorObjectMappable {
    func mapping(map: Map) {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            guard let propertyName = child.label else {
                continue
            }
            guard let value = child.value as? EntityWrappedAny else {
                continue
            }
            value.convertorClosure?(codingKey(propertyName: propertyName, key: value.key, codingKey: value.codingKey), map)
        }
    }

    func codingKey(propertyName: String, key: String?, codingKey: String?) -> String {
        if codingKey?.isEmpty == false {
            return codingKey!
        }else if key?.isEmpty == false {
            return key!
        }else if propertyName.hasPrefix("_") {
            let from = propertyName.index(after: propertyName.startIndex)
            return String(propertyName[from...])
        }else {
            return propertyName
        }
    }

}

protocol EntityWrappedAny {
    var wrappedValueAny: Any { get set }
    var key: String? { get }
    var codingKey: String? { get }
    var storageKey: String? { get }
    var convertorClosure: ((String, Map)->())? { get }
}
