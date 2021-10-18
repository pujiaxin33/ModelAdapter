//
//  KeyManager.swift
//  ModelAdaptor
//
//  Created by jiaxin on 2020/6/30.
//

import Foundation

class KeyManager {
    static func storageKey(propertyName: String, key: String?, storageKey: String?) -> String {
        if storageKey?.isEmpty == false {
            return storageKey!
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
