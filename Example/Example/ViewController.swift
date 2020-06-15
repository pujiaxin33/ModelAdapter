//
//  ViewController.swift
//  Example
//
//  Created by jiaxin on 2020/6/14.
//  Copyright © 2020 jiaxin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let dao = CustomDAO()
        let model = CustomModel()
        try? dao.insert(entity: model)
//        try? dao.update(entity: model, model.&accountID.expression == 123)
//        try? dao.delete(model.$amount.expression == Double(123))
    }


}

