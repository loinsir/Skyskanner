//
//  BaseTabBarController.swift
//  Skyskanner
//
//  Created by 김인환 on 2021/12/22.
//

import UIKit

class BaseTabBarController: UITabBarController {
    
    let ViewControllers = [
        ScanTabViewController(),
        StorageTabViewController(),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewControllers(ViewControllers, animated: true)
        setTabBarUI()
    }
    
    func setTabBarUI() {
        tabBar.tintColor = .systemGray
    }

}
