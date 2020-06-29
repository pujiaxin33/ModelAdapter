//
//  ModelAdaptorDAO.swift
//  ModelAdaptor
//
//  Created by jiaxin on 2020/6/15.
//

import Foundation
import SQLite

public protocol NormalInitialize {
    init()
}

public protocol ModelAdaptorDAO {
    associatedtype Entity: NormalInitialize
    var connection: Connection { get }
    var table: Table { get }

    init()

    func createTable(ifNotExists: Bool)
    func insert(entity: Entity) throws
    func insert(entities: [Entity]) throws
    func deleteAll() throws
    func delete(_ predicate: SQLite.Expression<Bool>) throws
    func delete(_ predicate: SQLite.Expression<Bool?>) throws
    func update(entity: Entity, _ predicate: SQLite.Expression<Bool>) throws
    func update(entity: Entity, _ predicate: SQLite.Expression<Bool?>) throws
    func query(_ predicate: SQLite.Expression<Bool>) throws -> Entity?
    func query(_ predicate: SQLite.Expression<Bool?>) throws -> Entity?
    func queryAll() throws -> [Entity]?
}

public extension ModelAdaptorDAO {
    func createTable(ifNotExists: Bool = true) {
        let object = Entity()
        let mirror = Mirror(reflecting: object)
        for child in mirror.children {
            guard let propertyName = child.label else {
                continue
            }
            if var value = child.value as? FieldStorgeWrappedProtocol {
                value.storageKey = codingKey(propertyName: propertyName, key: value.key, storageKey: value.storageKey)
            }else if var value = child.value as? FieldOptionalStorgeWrappedProtocol {
                value.storageKey = codingKey(propertyName: propertyName, key: value.key, storageKey: value.storageKey)
            }
        }
        _ = try? connection.run(table.create(ifNotExists: true) { t in
            for child in mirror.children {
                if let value = child.value as? FieldStorgeWrappedProtocol {
                    if value.storageVersion ?? 1 == 1 {
                        value.createColumn(tableBuilder: t)
                    }
                }else if let value = child.value as? FieldOptionalStorgeWrappedProtocol {
                    if value.storageVersion ?? 1 == 1 {
                        value.createColumn(tableBuilder: t)
                    }
                }
            }
        })
        for child in mirror.children {
            if let value = child.value as? FieldStorgeWrappedProtocol {
                if value.storageVersion ?? 1 > 1 {
                    value.addColumn(table: table)
                }
            }else if let value = child.value as? FieldOptionalStorgeWrappedProtocol {
                if value.storageVersion ?? 1 > 1 {
                    value.addColumn(table: table)
                }
            }
        }
    }

    func insert(entity: Entity) throws {
        let mirror = Mirror(reflecting: entity)
        var setters = [Setter]()
        for child in mirror.children {
            guard let propertyName = child.label else {
                continue
            }
            if var value = child.value as? FieldStorgeWrappedProtocol {
                value.storageKey = codingKey(propertyName: propertyName, key: value.key, storageKey: value.storageKey)
                if let setter = value.setter() {
                    setters.append(setter)
                }
            }else if var value = child.value as? FieldOptionalStorgeWrappedProtocol {
                value.storageKey = codingKey(propertyName: propertyName, key: value.key, storageKey: value.storageKey)
                if let setter = value.setter() {
                    setters.append(setter)
                }
            }
        }
        try connection.run(table.insert(setters))
    }

    func insert(entities: [Entity]) throws {
        for entity in entities {
            try insert(entity: entity)
        }
    }

    func deleteAll() throws {
        try connection.run(table.delete())
    }

    func delete(_ predicate: SQLite.Expression<Bool>) throws {
        try connection.run(table.filter(predicate).delete())
    }

    func delete(_ predicate: SQLite.Expression<Bool?>) throws {
        try connection.run(table.filter(predicate).delete())
    }

    func update(entity: Entity, _ predicate: SQLite.Expression<Bool>) throws {
        let alice = table.filter(predicate)
        let mirror = Mirror(reflecting: entity)
        var setters = [Setter]()
        for child in mirror.children {
            guard let propertyName = child.label else {
                continue
            }
            if var value = child.value as? FieldStorgeWrappedProtocol {
                value.storageKey = codingKey(propertyName: propertyName, key: value.key, storageKey: value.storageKey)
                if let setter = value.setter() {
                    setters.append(setter)
                }
            }else if var value = child.value as? FieldOptionalStorgeWrappedProtocol {
                value.storageKey = codingKey(propertyName: propertyName, key: value.key, storageKey: value.storageKey)
                if let setter = value.setter() {
                    setters.append(setter)
                }
            }
        }
        try connection.run(alice.update(setters))
    }

    func update(entity: Entity, _ predicate: SQLite.Expression<Bool?>) throws {
        let alice = table.filter(predicate)
        let mirror = Mirror(reflecting: entity)
        var setters = [Setter]()
        for child in mirror.children {
            guard let propertyName = child.label else {
                continue
            }
            if var value = child.value as? FieldStorgeWrappedProtocol {
                value.storageKey = codingKey(propertyName: propertyName, key: value.key, storageKey: value.storageKey)
                if let setter = value.setter() {
                    setters.append(setter)
                }
            }else if var value = child.value as? FieldOptionalStorgeWrappedProtocol {
                value.storageKey = codingKey(propertyName: propertyName, key: value.key, storageKey: value.storageKey)
                if let setter = value.setter() {
                    setters.append(setter)
                }
            }
        }
        try connection.run(alice.update(setters))
    }

    func query(_ predicate: SQLite.Expression<Bool>) throws -> Entity? {
        let alice = table.filter(predicate)
        guard let rows = try? connection.prepare(alice), let row = rows.first(where: { (_) -> Bool in
            return true
        }) else {
            return nil
        }
        let entity = Entity()
        let mirror = Mirror(reflecting: entity)
        for child in mirror.children {
            guard let propertyName = child.label else {
                continue
            }
            if var value = child.value as? FieldStorgeWrappedProtocol {
                value.storageKey = codingKey(propertyName: propertyName, key: value.key, storageKey: value.storageKey)
                value.update(row: row)
            }else if var value = child.value as? FieldOptionalStorgeWrappedProtocol {
                value.storageKey = codingKey(propertyName: propertyName, key: value.key, storageKey: value.storageKey)
                value.update(row: row)
            }
        }
        return entity
    }

    func query(_ predicate: SQLite.Expression<Bool?>) throws -> Entity? {
        let alice = table.filter(predicate)
        guard let rows = try? connection.prepare(alice), let row = rows.first(where: { (_) -> Bool in
            return true
        }) else {
            return nil
        }
        let entity = Entity()
        let mirror = Mirror(reflecting: entity)
        for child in mirror.children {
            guard let propertyName = child.label else {
                continue
            }
            if var value = child.value as? FieldStorgeWrappedProtocol {
                value.storageKey = codingKey(propertyName: propertyName, key: value.key, storageKey: value.storageKey)
                value.update(row: row)
            }else if var value = child.value as? FieldOptionalStorgeWrappedProtocol {
                value.storageKey = codingKey(propertyName: propertyName, key: value.key, storageKey: value.storageKey)
                value.update(row: row)
            }
        }
        return entity
    }

    func queryAll() throws -> [Entity]? {
        guard let rows = try? connection.prepare(table) else {
            return nil
        }
        var entities = [Entity]()
        for row in rows {
            let entity = Entity()
            let mirror = Mirror(reflecting: entity)
            for child in mirror.children {
                guard let propertyName = child.label else {
                    continue
                }
                if var value = child.value as? FieldStorgeWrappedProtocol {
                    value.storageKey = codingKey(propertyName: propertyName, key: value.key, storageKey: value.storageKey)
                    value.update(row: row)
                }else if var value = child.value as? FieldOptionalStorgeWrappedProtocol {
                    value.storageKey = codingKey(propertyName: propertyName, key: value.key, storageKey: value.storageKey)
                    value.update(row: row)
                }
            }
            entities.append(entity)
        }
        return entities
    }

    private func codingKey(propertyName: String, key: String?, storageKey: String?) -> String {
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
