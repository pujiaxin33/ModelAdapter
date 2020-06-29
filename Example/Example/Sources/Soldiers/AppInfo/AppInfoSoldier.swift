//
//  AppInfoSoldier.swift
//  JXCaptain
//
//  Created by jiaxin on 2019/8/22.
//  Copyright © 2019 jiaxin. All rights reserved.
//

import Foundation
import UIKit

public class AppInfoSoldier: Soldier {
    public var name: String
    public var team: String
    public var icon: UIImage?
    
    public init() {
        name = "APP信息"
        team = "常用工具"
        icon = ImageManager.imageWithName("JXCaptain_icon_app_info")
    }

    public func prepare() {
    }

    public func action(naviController: UINavigationController) {
        naviController.pushViewController(AppInfoViewController(style: .grouped), animated: true)
    }
}
