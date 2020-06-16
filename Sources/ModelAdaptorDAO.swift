//
//  ModelAdaptorDAO.swift
//  ModelAdaptor
//
//  Created by jiaxin on 2020/6/15.
//

import Foundation
import SQLite

public protocol NormalInitialize: class {
    init()
}

public protocol ModelAdaptorDAO {
    associatedtype Entity: NormalInitialize
    var connection: Connection { get }
    var table: Table { get }

    init()

    func initExpressions()
    func insert(entity: Entity) throws
    func inset(entities: [Entity]) throws
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
    func initExpressions() {
        let mirror = Mirror(reflecting: self)

        for child in mirror.children {
            guard let propertyName = child.label else {
                continue
            }
            guard let value = child.value as? FieldWrappedProtocol else {
                continue
            }
            value.initExpresionIfNeeded(key: codingKey(propertyName: propertyName, key: value.key, storageKey: value.storageKey))
        }
    }
    func insert(entity: Entity) throws {
        let mirror = Mirror(reflecting: self)
        var setters = [Setter]()
        for child in mirror.children {
            guard let _ = child.label else {
                continue
            }
            guard let value = child.value as? FieldWrappedProtocol else {
                continue
            }
            guard let setter = value.setter() else {
                continue
            }
            setters.append(setter)
        }
        try connection.run(table.insert(setters))
    }

    func inset(entities: [Entity]) throws {
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
        let mirror = Mirror(reflecting: self)
        var setters = [Setter]()
        for child in mirror.children {
            guard let _ = child.label else {
                continue
            }
            guard let value = child.value as? FieldWrappedProtocol else {
                continue
            }
            guard let setter = value.setter() else {
                continue
            }
            setters.append(setter)
        }
        try connection.run(alice.update(setters))
    }

    func update(entity: Entity, _ predicate: SQLite.Expression<Bool?>) throws {
        //todo:
        let alice = table.filter(predicate)
        let mirror = Mirror(reflecting: self)
        var setters = [Setter]()
        for child in mirror.children {
            guard let _ = child.label else {
                continue
            }
            guard let value = child.value as? FieldWrappedProtocol else {
                continue
            }
            guard let setter = value.setter() else {
                continue
            }
            setters.append(setter)
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
            guard let _ = child.label else {
                continue
            }
            guard let value = child.value as? FieldWrappedProtocol else {
                continue
            }
            value.update(row: row)
        }
        return entity
    }

    func query(_ predicate: SQLite.Expression<Bool?>) throws -> Entity? {
        //todo:
        let alice = table.filter(predicate)
        guard let rows = try? connection.prepare(alice), let row = rows.first(where: { (_) -> Bool in
            return true
        }) else {
            return nil
        }
        let entity = Entity()
        let mirror = Mirror(reflecting: entity)
        for child in mirror.children {
            guard let _ = child.label else {
                continue
            }
            guard let value = child.value as? FieldWrappedProtocol else {
                continue
            }
            value.update(row: row)
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
                guard let _ = child.label else {
                    continue
                }
                guard let value = child.value as? FieldWrappedProtocol else {
                    continue
                }
                value.update(row: row)
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
