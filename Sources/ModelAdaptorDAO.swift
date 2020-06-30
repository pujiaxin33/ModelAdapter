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
    func initExpressionsIfNeeded()
}

public extension NormalInitialize {
    func initExpressionsIfNeeded() {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            guard let propertyName = child.label else {
                continue
            }
            if let value = child.value as? FieldStorgeWrappedProtocol {
                value.initExpresionIfNeeded(key: KeyManager.storageKey(propertyName: propertyName, key: value.key, storageKey: value.storageKey))
            }else if let value = child.value as? FieldOptionalStorgeWrappedProtocol {
                value.initExpresionIfNeeded(key: KeyManager.storageKey(propertyName: propertyName, key: value.key, storageKey: value.storageKey))
            }
        }
    }
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
        let entity = Entity()
        entity.initExpressionsIfNeeded()
        let mirror = Mirror(reflecting: entity)
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
            if let value = child.value as? FieldStorgeWrappedProtocol {
                if let setter = value.setter() {
                    setters.append(setter)
                }
            }else if let value = child.value as? FieldOptionalStorgeWrappedProtocol {
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
            if let value = child.value as? FieldStorgeWrappedProtocol {
                if let setter = value.setter() {
                    setters.append(setter)
                }
            }else if let value = child.value as? FieldOptionalStorgeWrappedProtocol {
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
            if let value = child.value as? FieldStorgeWrappedProtocol {
                if let setter = value.setter() {
                    setters.append(setter)
                }
            }else if let value = child.value as? FieldOptionalStorgeWrappedProtocol {
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
        entity.initExpressionsIfNeeded()
        let mirror = Mirror(reflecting: entity)
        for child in mirror.children {
            if let value = child.value as? FieldStorgeWrappedProtocol {
                value.update(row: row)
            }else if let value = child.value as? FieldOptionalStorgeWrappedProtocol {
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
        entity.initExpressionsIfNeeded()
        let mirror = Mirror(reflecting: entity)
        for child in mirror.children {
            if let value = child.value as? FieldStorgeWrappedProtocol {
                value.update(row: row)
            }else if let value = child.value as? FieldOptionalStorgeWrappedProtocol {
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
            entity.initExpressionsIfNeeded()
            let mirror = Mirror(reflecting: entity)
            for child in mirror.children {
                if let value = child.value as? FieldStorgeWrappedProtocol {
                    value.update(row: row)
                }else if let value = child.value as? FieldOptionalStorgeWrappedProtocol {
                    value.update(row: row)
                }
            }
            entities.append(entity)
        }
        return entities
    }
}
