//
//  FieldWrappedProtocol.swift
//  ModelAdapter
//
//  Created by jiaxin on 2020/6/15.
//

import Foundation
import SQLite

public protocol ModelAdapterModel: CustomStringConvertible {
    init()
}

public extension ModelAdapterModel {
    var description: String {
        let mirror = Mirror(reflecting: self)
        var infoDict = [String:Any]()
        for child in mirror.children {
            guard let propertyName = child.label else {
                continue
            }
            if let valueDesc = child.value as? CustomStringConvertible {
                infoDict[propertyName] = valueDesc.description
            }else if  JSONSerialization.isValidJSONObject(child.value) {
                infoDict[propertyName] = child.value
            }else {
                let valueMirror = Mirror(reflecting: child.value)
                infoDict[propertyName] = mirrorDescriptionPrettyPrinted(valueMirror.description)
            }
        }
        if JSONSerialization.isValidJSONObject(infoDict),
           let data = try? JSONSerialization.data(withJSONObject: infoDict, options: .prettyPrinted),
           let string = String(data: data, encoding: .utf8) {
            return "\(mirrorDescriptionPrettyPrinted(mirror.description)):\(string)"
        }
        return mirrorDescriptionPrettyPrinted(mirror.description)
    }
}

public protocol ModelAdapterModelCustomStorage {
    func createColumn(tableBuilder: TableBuilder)
    func addColumnStatements(table: Table) -> [String]?
    func setters() -> [Setter]
    func update(with row: Row)
}

public extension ModelAdapterModelCustomStorage {
    func addColumnStatements(table: Table) -> [String]? {
        return nil
    }
}

protocol FieldIdentifierProtocol {
    var key: String? { get }
}

protocol FieldStorageIdentifierBaseProtocol: FieldIdentifierProtocol {
    func createColumn(tableBuilder: TableBuilder)
    func addColumn(table: Table) -> String?
    func setter() -> Setter?
    func initExpresionIfNeeded(key: String)
    func update(with row: Row)
}
protocol FieldStorageIdentifierProtocol: FieldStorageIdentifierBaseProtocol { }
protocol FieldOptionalStorageIdentifierProtocol: FieldStorageIdentifierBaseProtocol { }


internal func mirrorDescriptionPrettyPrinted(_ string: String) -> String {
    return string.replacingOccurrences(of: "Mirror for ", with: "")
}
