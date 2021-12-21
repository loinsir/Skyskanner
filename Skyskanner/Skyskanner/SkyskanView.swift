//
//  SkyskanView.swift
//  Skyskanner
//
//  Created by 김인환 on 2021/12/21.
//

import UIKit
import AVFoundation

class SkyskanView: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureSession: AVCaptureSession?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setCaptureSession()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setCaptureSession() {
        // 캡처 세션 인스턴스 화
        captureSession = AVCaptureSession()
        
        // 입력 설정
        guard let inputDevice = AVCaptureDevice.default(for: .video) else { return }
        
        guard let captureSession = captureSession else { return }
        
        do {
            // 감싸기
            let videoInput = try AVCaptureDeviceInput(device: inputDevice)
            
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                return
            }
        } catch let error {
            print(error.localizedDescription)
        }
        
        // 출력 설정
        let output = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        } else {
            return
        }
    }
}
