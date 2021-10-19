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
    //fixme:initExpressionsIfNeeded call
    public func initExpressionsIfNeeded() {
        guard !isExpressionsInited else {
            return
        }
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            guard let propertyName = child.label else {
                continue
            }
            if let value = child.value as? FieldStorageIdentifierProtocol {
                value.initExpresionIfNeeded(key: KeyManager.storageKey(propertyName: propertyName, key: value.params.key))
            }else if let value = child.value as? FieldOptionalStorageIdentifierProtocol {
                value.initExpresionIfNeeded(key: KeyManager.storageKey(propertyName: propertyName, key: value.params.key))
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
        let entity = Entity()
        let mirror = Mirror(reflecting: entity)
        _ = try? connection.run(table.create(ifNotExists: true) { t in
            for child in mirror.children {
                if let value = child.value as? FieldStorageIdentifierProtocol {
                    value.createColumn(tableBuilder: t)
                }else if let value = child.value as? FieldOptionalStorageIdentifierProtocol {
                    value.createColumn(tableBuilder: t)
                }
            }
            if let customEntity = entity as? ModelAdaptorModelCustomStorage {
                customEntity.createColumn(tableBuilder: t)
            }
        })
        if let columnNames = try? connection.existedColumnNames(in: table.name) {
            for child in mirror.children {
                guard let propertyName = child.label else {
                    continue
                }
                guard let value = child.value as? FieldStorageIdentifierBaseProtocol  else {
                    continue
                }
                let key = KeyManager.storageKey(propertyName: propertyName, key: value.params.key)
                let isExisted = columnNames.contains(where: { dbColumn -> Bool in
                    return dbColumn.caseInsensitiveCompare(key) == ComparisonResult.orderedSame
                })
                guard !isExisted else {
                    continue
                }
                guard let statement = value.addColumn(table: table) else {
                    continue
                }
                _ = try? connection.run(statement)
            }
        }
        if let customEntity = entity as? ModelAdaptorModelCustomStorage {
            if let statements = customEntity.addColumnStatements(table: table) {
                for statement in statements {
                    _ = try? connection.run(statement)
                }
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
        let entity = Entity()
        update(entity: entity, with: row)
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
        update(entity: entity, with: row)
        return entity
    }

    func queryAll() throws -> [Entity]? {
        guard let rows = try? connection.prepare(table) else {
            return nil
        }
        var entities = [Entity]()
        for row in rows {
            let entity = Entity()
            update(entity: entity, with: row)
            entities.append(entity)
        }
        return entities
    }

    private func setters(with entity: Entity) -> [Setter] {
        var setters = [Setter]()
        let mirror = Mirror(reflecting: entity)
        for child in mirror.children {
            if let value = child.value as? FieldStorageIdentifierProtocol {
                if let setter = value.setter() {
                    setters.append(setter)
                }
            }else if let value = child.value as? FieldOptionalStorageIdentifierProtocol {
                if let setter = value.setter() {
                    setters.append(setter)
                }
            }
        }
        if let customEntity = entity as? ModelAdaptorModelCustomStorage {
            setters.append(contentsOf: customEntity.setters())
        }
        return setters
    }

    private func update(entity: Entity, with row: Row) {
        let mirror = Mirror(reflecting: entity)
        for child in mirror.children {
            if let value = child.value as? FieldStorageIdentifierProtocol {
                value.update(with: row)
            }else if let value = child.value as? FieldOptionalStorageIdentifierProtocol {
                value.update(with: row)
            }
        }
        if let customEntity = entity as? ModelAdaptorModelCustomStorage {
            customEntity.update(with: row)
        }
    }
}

extension Connection {
    func exists(column: String, in table: String) throws -> Bool {
        let stmt = try prepare("PRAGMA table_info(\(table))")
        
        let columnNames = stmt.makeIterator().map { (row) -> String in
            return row[1] as? String ?? ""
        }
        
        return columnNames.contains(where: { dbColumn -> Bool in
            return dbColumn.caseInsensitiveCompare(column) == ComparisonResult.orderedSame
        })
    }
    func existedColumnNames(in table: String) throws -> [String] {
        let stmt = try prepare("PRAGMA table_info(\(table))")
        
        let columnNames = stmt.makeIterator().map { (row) -> String in
            return row[1] as? String ?? ""
        }
        
        return columnNames
    }
}
extension Table {
    var name: String {
        var result: String = ""
        let tableMirror = Mirror(reflecting: self)
        for tableChild in tableMirror.children {
            guard let tableChildLabel = tableChild.label else {
                continue
            }
            guard tableChildLabel == "clauses", let clausesValue = tableChild.value as? QueryClauses else {
                continue
            }
            let clausesValueMirror = Mirror(reflecting: clausesValue)
            for clausesValueChild in clausesValueMirror.children {
                guard let clausesValueChildLabel = clausesValueChild.label else {
                    continue
                }
                guard clausesValueChildLabel == "from", let fromValue = clausesValueChild.value as? (String,String?,String?) else {
                    continue
                }
                result = fromValue.0
            }
        }
        return result
    }
}
