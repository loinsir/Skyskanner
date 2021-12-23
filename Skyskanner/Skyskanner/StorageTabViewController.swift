//
//  StorageTabViewController.swift
//  Skyskanner
//
//  Created by 김인환 on 2021/12/23.
//

import UIKit

class StorageTabViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setTabbarItem()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTabbarItem() {
        tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 2)
    }
}
