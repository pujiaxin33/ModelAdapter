//
//  ViewController.swift
//  Example
//
//  Created by jiaxin on 2020/6/14.
//  Copyright © 2020 jiaxin. All rights reserved.
//

import UIKit
import SQLite
import ModelAdaptor

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let dao = CustomDAO()
        let model = CustomModel()
        try? dao.insert(entity: model)
//        let entity: Field<Bool> = model.&isExchangePasswordValid
//        try? dao.update(entity: model, model.&accountID.expression == 123)
        let some = model.$accountID
        let name = model.$nickName
        try? dao.delete(model.$vipLevel.expression == 123)
//        try? dao.update(entity: model, model.$accountID.expression == 123)
        let ex = Expression<String?>("123")
    }


}

