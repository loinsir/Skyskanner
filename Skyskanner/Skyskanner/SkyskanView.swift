//
//  SkyskanView.swift
//  Skyskanner
//
//  Created by 김인환 on 2021/12/21.
//

import UIKit
import AVFoundation

// 성공, 실패, 멈춤으로 상태케이스를 나눈다
enum SkyskanStatus {
    case success(code: String?)
    case fail(errorMessage: String?)
    case stop
}

// delegate 프로토콜 선언
protocol SkyskanViewDelegate {
    func SkyskanView(_ : SkyskanView, status: SkyskanStatus)
}

class SkyskanView: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer? // 미리보기 레이어
    var captureSession: AVCaptureSession?
    var delegate: SkyskanViewDelegate?
    
    let metadataOutputTypes: [AVMetadataObject.ObjectType] = [
        // 현재 책에 붙어 있는 바코드들은 EAN-13을 따른다
        .ean13
    ]
    
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
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = metadataOutputTypes
        } else {
            return
        }
        
        setPreviewLayer()
    }
    
    private func setPreviewLayer() {
        // 이미 연결이 설정된 세션을 인자로 넣어준다.
        guard let captureSession = captureSession else { return }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        guard let previewLayer = previewLayer else { return }
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = self.layer.bounds
        
        self.layer.addSublayer(previewLayer)
    }
}

extension SkyskanView {
    func start() {
        captureSession?.startRunning()
    }
    
    func stop() {
        captureSession?.stopRunning()
        delegate?.SkyskanView(self, status: .stop)
    }
    
    func fail(errorMessage: String?) {
        captureSession?.stopRunning()
        delegate?.SkyskanView(self, status: .fail(errorMessage: errorMessage))
    }
    
    func success(code: String) {
        captureSession?.stopRunning()
        delegate?.SkyskanView(self, status: .success(code: code))
    }
}

extension SkyskanView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        stop()
        
        if let metadataObject = metadataObjects.first {
            guard let readableCodeObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let code = readableCodeObject.stringValue else {
                fail(errorMessage: "MetadataOutput Error")
                return
            }
            success(code: code) // 성공시 associate value로 delegate에 바코드 문자열을 보낸다
        } else {
            fail(errorMessage: "MetadataOutput does not exists.")
        }
    }
}
