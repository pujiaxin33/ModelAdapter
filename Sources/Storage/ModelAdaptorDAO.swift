//
//  ModelAdaptorDAO.swift
//  ModelAdaptor
//
//  Created by jiaxin on 2020/6/15.
//

import Foundation
import SQLite

extension ModelAdaptorModel {
    var isExpressionsInited: Bool {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.expressionsInit, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.expressionsInit) as? Bool) ?? false
        }
    }
    func initExpressionsIfNeeded() {
        guard !isExpressionsInited else {
            return
        }
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            guard let propertyName = child.label else {
                continue
            }
            if let value = child.value as? FieldStorageWrappedProtocol {
                value.initExpresionIfNeeded(key: KeyManager.storageKey(propertyName: propertyName, key: value.key, storageKey: value.storageKey))
            }else if let value = child.value as? FieldOptionalStorageWrappedProtocol {
                value.initExpresionIfNeeded(key: KeyManager.storageKey(propertyName: propertyName, key: value.key, storageKey: value.storageKey))
            }else if let value = child.value as? FieldCustomStorageWrappedProtocol {
                value.initExpresionIfNeeded(key: KeyManager.storageKey(propertyName: propertyName, key: value.key, storageKey: value.storageKey))
            }
        }
    }
}

public protocol ModelAdaptorDAO {
    associatedtype Entity: ModelAdaptorModel
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
        let entity = Entity(JSON: [String : Any]())!
        let mirror = Mirror(reflecting: entity)
        _ = try? connection.run(table.create(ifNotExists: true) { t in
            for child in mirror.children {
                if let value = child.value as? FieldStorageWrappedProtocol {
                    if !value.storageIsNewField {
                        value.createColumn(tableBuilder: t)
                    }
                }else if let value = child.value as? FieldOptionalStorageWrappedProtocol {
                    if !value.storageIsNewField {
                        value.createColumn(tableBuilder: t)
                    }
                }else if let value = child.value as? FieldCustomStorageWrappedProtocol{
                    if !value.storageIsNewField {
                        value.createColumn(tableBuilder: t)
                    }
                }
            }
            if let customEntity = entity as? ModelAdaptorCustomStorage {
                customEntity.createColumn(tableBuilder: t)
            }
        })
        for child in mirror.children {
            if let value = child.value as? FieldStorageWrappedProtocol {
                if value.storageIsNewField, let statement = value.addColumn(table: table) {
                    _ = try? connection.run(statement)
                }
            }else if let value = child.value as? FieldOptionalStorageWrappedProtocol {
                if value.storageIsNewField, let statement = value.addColumn(table: table) {
                    _ = try? connection.run(statement)
                }
            }else if let value = child.value as? FieldCustomStorageWrappedProtocol {
                if value.storageIsNewField, let statement = value.addColumn(table: table) {
                    _ = try? connection.run(statement)
                }
            }
        }
        if let customEntity = entity as? ModelAdaptorCustomStorage {
            if let statement = customEntity.addColumn(table: table) {
                _ = try? connection.run(statement)
            }
        }
    }

    func insert(entity: Entity) throws {
        try connection.run(table.insert(setters(with: entity)))
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
        try connection.run(alice.update(setters(with: entity)))
    }

    func update(entity: Entity, _ predicate: SQLite.Expression<Bool?>) throws {
        let alice = table.filter(predicate)
        try connection.run(alice.update(setters(with: entity)))
    }

    func query(_ predicate: SQLite.Expression<Bool>) throws -> Entity? {
        let alice = table.filter(predicate)
        guard let rows = try? connection.prepare(alice), let row = rows.first(where: { (_) -> Bool in
            return true
        }) else {
            return nil
        }
        let entity = Entity(JSON: [String : Any]())!
        update(entity: entity, with: row)
        if let customEntity = entity as? ModelAdaptorCustomStorage {
            customEntity.update(with: row)
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
        let entity = Entity(JSON: [String : Any]())!
        update(entity: entity, with: row)
        return entity
    }

    func queryAll() throws -> [Entity]? {
        guard let rows = try? connection.prepare(table) else {
            return nil
        }
        var entities = [Entity]()
        for row in rows {
            let entity = Entity(JSON: [String : Any]())!
            update(entity: entity, with: row)
            entities.append(entity)
        }
        return entities
    }

    private func setters(with entity: Entity) -> [Setter] {
        var setters = [Setter]()
        let mirror = Mirror(reflecting: entity)
        for child in mirror.children {
            if let value = child.value as? FieldStorageWrappedProtocol {
                if let setter = value.setter() {
                    setters.append(setter)
                }
            }else if let value = child.value as? FieldOptionalStorageWrappedProtocol {
                if let setter = value.setter() {
                    setters.append(setter)
                }
            }else if let value = child.value as? FieldCustomStorageWrappedProtocol {
                if let setter = value.setter() {
                    setters.append(setter)
                }
            }
        }
        if let customEntity = entity as? ModelAdaptorCustomStorage {
            setters.append(contentsOf: customEntity.setters())
        }
        return setters
    }

    private func update(entity: Entity, with row: Row) {
        let mirror = Mirror(reflecting: entity)
        for child in mirror.children {
            if let value = child.value as? FieldStorageWrappedProtocol {
                value.update(row: row)
            }else if let value = child.value as? FieldOptionalStorageWrappedProtocol {
                value.update(row: row)
            }else if let value = child.value as? FieldCustomStorageWrappedProtocol {
                value.update(row: row)
            }
        }
        if let customEntity = entity as? ModelAdaptorCustomStorage {
            customEntity.update(with: row)
        }
    }
}
