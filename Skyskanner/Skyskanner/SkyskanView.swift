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
    func didScan(skyskanView : SkyskanView, status: SkyskanStatus)
}

class SkyskanView: UIView {
    
    var previewLayer: AVCaptureVideoPreviewLayer? // 미리보기 레이어
    var captureSession: AVCaptureSession?
    var delegate: SkyskanViewDelegate?
    
    var centerGuideLineView: UIView?
    
    var isRunning: Bool {
        guard let captureSession = captureSession else {
            return false
        }
        return captureSession.isRunning
    }
    
    let metadataOutputTypes: [AVMetadataObject.ObjectType] = [
        // 현재 책에 붙어 있는 바코드들은 EAN-13을 따른다
        .ean13
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setCaptureSession()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setCaptureSession()
    }
    
    private func setCaptureSession() {
        // 캡처 세션 인스턴스 화
        clipsToBounds = true
        captureSession = AVCaptureSession()
        
        // 입력 설정
        guard let inputDevice = AVCaptureDevice.default(for: .video) else { return }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            // 감싸기
            videoInput = try AVCaptureDeviceInput(device: inputDevice)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        
        guard let captureSession = self.captureSession else {
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            fail(errorMessage: "Add Video Input Failed")
            return
        }
        
        // 출력 설정
        let output = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = metadataOutputTypes
        } else {
            fail(errorMessage: "failed")
            return
        }
        
        setPreviewLayer()
        setCenterGuideLineView()
    }
    
    func setPreviewLayer() {
        // 이미 연결이 설정된 세션을 인자로 넣어준다.
        guard let captureSession = captureSession else { return }
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
        
        // 중요!: bounds로 frame 설정시 main스레드에서 실행되어야 한다.
        DispatchQueue.main.async {
            self.previewLayer?.frame = self.layer.bounds
        }
        self.previewLayer?.videoGravity = .resizeAspectFill
    }
    
    private func setCenterGuideLineView() {
        let centerGuideLineView = UIView()
        centerGuideLineView.translatesAutoresizingMaskIntoConstraints = false
        centerGuideLineView.backgroundColor = #colorLiteral(red: 1, green: 0.5411764706, blue: 0.2392156863, alpha: 1)
        
        self.addSubview(centerGuideLineView)
        self.bringSubviewToFront(centerGuideLineView)
        
        centerGuideLineView.snp.makeConstraints{ make in
            make.trailing.equalTo(self.snp.trailing)
            make.leading.equalTo(self.snp.leading)
            make.centerY.equalTo(self.snp.centerY)
            make.height.equalTo(1)
        }


        self.centerGuideLineView = centerGuideLineView
    }
}

extension SkyskanView {
    func start() {
        captureSession?.startRunning()
    }
    
    func stop() {
        captureSession?.stopRunning()
        delegate?.didScan(skyskanView: self, status: .stop)
    }
    
    func fail(errorMessage: String?) {
        captureSession?.stopRunning()
        delegate?.didScan(skyskanView: self, status: .fail(errorMessage: errorMessage))
        captureSession = nil
    }
    
    func success(code: String) {
        captureSession?.stopRunning()
        delegate?.didScan(skyskanView: self, status: .success(code: code))
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
