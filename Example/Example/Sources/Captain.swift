//
//  Captain.swift
//  JXCaptain
//
//  Created by jiaxin on 2019/8/20.
//  Copyright © 2019 jiaxin. All rights reserved.
//

import Foundation
import UIKit

public class Captain {
    public static let `default` = Captain()
    public var configSoldierClosure: ((Soldier)->())?
    public var screenEdgeInsets: UIEdgeInsets
//    public var logoImage: UIImage 
    internal var soldiers = [Soldier]()
    internal let floatingWindow = CaptainFloatingWindow(frame: CGRect.zero)

    init() {
        let defaultSoldiers: [Soldier] = [AppInfoSoldier(), SanboxBrowserSoldier(), CrashSoldier(), WebsiteEntrySoldier(), FPSSoldier(), MemorySoldier(), CPUSoldier(), ANRSoldier(), NetworkObserverSoldier.shared, UserDefaultsSoldier()]
        soldiers.append(contentsOf: defaultSoldiers)
        var topEdgeInset: CGFloat = 20
        var bottomEdgeInset: CGFloat = 12
        if #available(iOS 11.0, *) {
            let safeAreaInsets = floatingWindow.safeAreaInsets
            if safeAreaInsets.top > 0 {
                topEdgeInset = safeAreaInsets.top
            }
            if safeAreaInsets.bottom > 0 {
                bottomEdgeInset = safeAreaInsets.bottom
            }
        }
        screenEdgeInsets = UIEdgeInsets(top: topEdgeInset, left: 12, bottom: bottomEdgeInset, right: 12)
//        logoImage = ImageManager.imageWithName("JXCaptain_icon_shield")!
    }

    public func show() {
        floatingWindow.isHidden = false
    }

    public func hide() {
        floatingWindow.rootViewController?.dismiss(animated: false, completion: nil)
        floatingWindow.isHidden = true
    }

    public func prepare() {
        soldiers.forEach { configSoldierClosure?($0) }
        soldiers.forEach { $0.prepare() }
    }

    public func enqueueSoldiers(_ soldiers: [Soldier]) {
        self.soldiers.append(contentsOf: soldiers)
    }

    public func removeAllSoldiers() {
        soldiers.removeAll()
    }

    public func dequeueSoldiers(soldierTypes: [Soldier.Type]) {
        for (index, soldier) in soldiers.enumerated() {
            let currentSoldierType = type(of: soldier)
            let isExisted = soldierTypes.contains { (type) -> Bool in
                if type == currentSoldierType {
                    return true
                }else {
                    return false
                }
            }
            if isExisted {
                soldiers.remove(at: index)
                break
            }
        }
    }
}
