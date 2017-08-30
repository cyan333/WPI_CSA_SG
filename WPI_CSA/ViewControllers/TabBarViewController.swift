//
//  TabBarViewController.swift
//  WPI_CSA
//
//  Created by NingFangming on 8/29/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        //print(123)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let indexOfTab = tabBar.items?.index(of: item)
        
        if indexOfTab == 1 {
            UIApplication.shared.statusBarStyle = .lightContent
        } else {
            UIApplication.shared.statusBarStyle = .default
        }
    }
    
}

