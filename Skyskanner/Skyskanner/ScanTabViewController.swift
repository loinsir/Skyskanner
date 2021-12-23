//
//  ViewController.swift
//  Skyskanner
//
//  Created by 김인환 on 2021/12/21.
//

import UIKit
import SnapKit

class ScanTabViewController: UIViewController {
    
    // MARK: - Properties
    var scanner: SkyskanView?

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
    
    private func setTabbarItem() {
        tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
    }
}

