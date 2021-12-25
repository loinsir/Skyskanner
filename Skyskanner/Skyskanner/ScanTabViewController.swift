//
//  ViewController.swift
//  Skyskanner
//
//  Created by 김인환 on 2021/12/21.
//

import UIKit
import SnapKit
import AVFoundation

class ScanTabViewController: UIViewController {
    
    // MARK: - Properties
    
    var scanner: SkyskanView?
    var scanButton: UIButton = UIButton(type: .system)
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        requestCameraPermission()
        setScanViewLayout()
        setScanButtonLayout()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setTabbarItem()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func requestCameraPermission(){
           AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
               if granted {
                   print("Camera: 권한 허용")
               } else {
                   print("Camera: 권한 거부")
               }
           })
       }
    
    private func setTabbarItem() {
        tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
    }
    
    private func setScanViewLayout() {
        scanner = SkyskanView()
        guard let scanner = scanner else { return }
        scanner.delegate = self
    
        view.addSubview(scanner)
        view.bringSubviewToFront(scanner)
        scanner.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.5)
            make.width.equalToSuperview().inset(40)
            make.height.equalTo(scanner.snp.width).multipliedBy(0.5)
        }
    }
    
    private func setScanButtonLayout() {
        scanButton.setTitle("SCAN", for: .normal)
        scanButton.addTarget(self, action: #selector(touchScanButton(_:)), for: .touchUpInside)
    
        view.addSubview(scanButton)
        
        scanButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.5)
        }
    }
    
    @objc func touchScanButton(_ sender: UIButton) {
        guard let scanner = scanner else {
            return
        }
        if scanner.isRunning {
            scanner.stop()
        } else {
            scanner.start()
        }
        
        sender.isSelected = scanner.isRunning
    }
}

extension ScanTabViewController: SkyskanViewDelegate {
    func didScan(skyskanView: SkyskanView, status: SkyskanStatus) {
        switch status {
        case .success(let code):
            guard let code = code else {
                return
            }
            floatAlertView(title: "스캔 성공", message: "ISBN: \(code)", confirmHander: nil, completion: nil)
        case .fail(let errorMessage):
            floatAlertView(title: "실패", message: "Error: \(String(describing: errorMessage))", confirmHander: nil, completion: nil)
        case .stop:
            return
        }
    }
}
