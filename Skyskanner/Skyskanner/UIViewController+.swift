//
//  UIViewController+.swift
//  Skyskanner
//
//  Created by 김인환 on 2021/12/23.
//

import UIKit

extension UIViewController {
    func floatAlertView(title: String?, message: String?, confirmHander: ((UIAlertAction) -> Void)?, completion: (() -> Void)?) {
        let alertView: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirmAction: UIAlertAction = UIAlertAction(title: "확인", style: .default, handler: confirmHander)
        let cancelAction: UIAlertAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        [confirmAction, cancelAction].forEach {alertView.addAction($0)}
        present(alertView, animated: true, completion: completion)
    }
}
