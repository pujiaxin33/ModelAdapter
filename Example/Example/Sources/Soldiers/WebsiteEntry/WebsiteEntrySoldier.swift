//
//  WebsiteSoldier.swift
//  JXCaptain
//
//  Created by jiaxin on 2019/8/23.
//  Copyright © 2019 jiaxin. All rights reserved.
//

import Foundation
import UIKit

public class WebsiteEntrySoldier: Soldier {
    public var name: String
    public var team: String
    public var icon: UIImage?
    public var defaultWebsite: String?
    public var webDetailControllerClosure: ((String)->(UIViewController))?

    deinit {
        webDetailControllerClosure = nil
    }

    public init() {
        name = "H5任意门"
        team = "常用工具"
        icon = ImageManager.imageWithName("JXCaptain_icon_h5")
    }

    public func prepare() {
    }

    public func action(naviController: UINavigationController) {
        naviController.pushViewController(WebsiteEntryViewController(soldier: self), animated: true)
    }
}
