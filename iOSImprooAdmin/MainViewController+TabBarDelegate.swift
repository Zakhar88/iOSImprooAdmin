//
//  MainViewController+TabBarDelegate.swift
//  iOSImprooAdmin
//
//  Created by Zakhar Garan on 26.10.17.
//  Copyright © 2017 Zakhar Garan. All rights reserved.
//

import UIKit

extension MainViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        cleanAllFields()
        switch item.title {
            case "Add Items"?:
                disableEditMode()
            case "Edit Items"?:
                enableEditMode()
            default:
                return
        }
        showHideMenu()
    }
}
