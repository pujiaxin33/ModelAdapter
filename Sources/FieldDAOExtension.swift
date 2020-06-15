//
//  FieldDAOExtension.swift
//  ModelAdaptor
//
//  Created by jiaxin on 2020/6/15.
//

import Foundation
import SQLite

struct AssociatedKeys {
    static var expression: UInt8 = 0
}

public extension Field where Value: SQLite.Value {
    var expression: Expression<Value?> {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.expression, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.expression) as! Expression<Value?>
        }
    }
    
    func setter() -> Setter? {
        return self.expression <- self.wrappedValue
    }

    func initExpresionIfNeeded(key: String) {
        self.expression = Expression<Value?>(key)
    }

    func update(row: Row) {
        //tood:
        self.wrappedValue = row[expression]!
    }
}
