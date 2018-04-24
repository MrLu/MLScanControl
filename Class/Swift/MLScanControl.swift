//
//  MLScanControl.swift
//  SuperLearn_toelf
//
//  Created by Mrlu on 18/01/2018.
//  Copyright © 2018 xdf. All rights reserved.
//

import UIKit
import AVFoundation

class MLScanControl: UIControl {

    typealias ResultClosure = (_ result:String?) -> (Void)
    
    private var device:AVCaptureDevice?
    private var input:AVCaptureDeviceInput?
    private var output:AVCaptureMetadataOutput?
    private var videoDataOutput:AVCaptureVideoDataOutput?
    private var scanSession:AVCaptureSession?
    
    private var scanPreviewLayer:AVCaptureVideoPreviewLayer!
    private var scanFrameView:MLScanFrameView!
    private var corverLayerView:UIView!
    private var maskShapLayer:CAShapeLayer = {
        let maskShapLayer = CAShapeLayer()
        return maskShapLayer
    }()
    private var torchBtn:UIButton?
    private var isTurnON:Bool = false
    var style:MLScanStyle = .weChat
    var frameSize:CGSize = CGSize(width: 260, height: 260)
    var offsetY:CGFloat = 0
    private var resultClosure:ResultClosure?
    private var zoomTemp:CGFloat = 0
    var isSoundEnable:Bool = false
    
    init(frame: CGRect, style:MLScanStyle = .weChat) {
        super.init(frame: frame)
        self.style = style
        offsetY = -frameSize.height/2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start() {
        if let scanSession = scanSession, !scanSession.isRunning {
            scanSession.startRunning()
            scanFrameView.startAnimation()
        }
    }
    
    func stop() {
        if let scanSession = scanSession, scanSession.isRunning {
            scanSession.stopRunning()
            scanFrameView.stopAnimation()
        }
        torchBtn?.isSelected = false
    }
    
    @discardableResult
    func result(closure:ResultClosure?) -> Self {
        resultClosure = closure
        return self
    }
    
    private func initialize() {
        //设置捕捉设备
        device = AVCaptureDevice.default(for: AVMediaType.video)
        //设置设备输入输出
        if let device = device {
            
            //设置会话
            scanSession = AVCaptureSession()
            scanSession?.canSetSessionPreset(AVCaptureSession.Preset.high)
            
            do {
                input = try AVCaptureDeviceInput(device: device)
            } catch let error as NSError {
                debugPrint(error)
            }
            output = AVCaptureMetadataOutput()
            output?.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput?.setSampleBufferDelegate(self, queue: DispatchQueue.main)
            
            if scanSession!.canAddInput(input!) {
                scanSession!.addInput(input!)
            }
            
            if scanSession!.canAddOutput(output!) {
                scanSession!.addOutput(output!)
            }
            
            if scanSession!.canAddOutput(videoDataOutput!) {
                scanSession!.addOutput(videoDataOutput!)
            }
            
            //设置扫描类型(二维码和条形码)
            output?.metadataObjectTypes = [
                AVMetadataObject.ObjectType.qr,
                AVMetadataObject.ObjectType.code39,
                AVMetadataObject.ObjectType.code93,
                AVMetadataObject.ObjectType.code128,
                AVMetadataObject.ObjectType.code39Mod43,
                AVMetadataObject.ObjectType.ean13,
                AVMetadataObject.ObjectType.ean8
                ]
            
            scanPreviewLayer = AVCaptureVideoPreviewLayer(session:scanSession!)
            scanPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            scanPreviewLayer.frame = layer.bounds
            layer.insertSublayer(scanPreviewLayer, at: 0)
            
            //设置扫描区域
            NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil, queue: nil, using: { [weak self] (noti) in
                if let strongSelf = self {
                    strongSelf.output?.rectOfInterest = (strongSelf.scanPreviewLayer?.metadataOutputRectConverted(fromLayerRect: strongSelf.scanFrameView.frame))!
                }
            })
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(zoomAction(sender:)))
            tapGesture.numberOfTapsRequired = 2
            addGestureRecognizer(tapGesture)
            
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomAction(sender:)))
            addGestureRecognizer(pinchGesture)
        }
    }
    
    private func setUpView() {
        
        backgroundColor = UIColor.black
        
        corverLayerView = UIView(frame: self.bounds)
        corverLayerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        corverLayerView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        addSubview(corverLayerView)
        
        scanFrameView = MLScanFrameView(frame: CGRect(origin: CGPoint.zero, size: frameSize), style:self.style)
        scanFrameView.center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2 + offsetY)
        addSubview(scanFrameView)
        
        torchBtn = UIButton(type: .custom)
        if style == .weChat {
            torchBtn!.setImage(MLScanControl.image(for: "weChatScan/ScanLowLight"), for: .normal)
            torchBtn!.setImage(MLScanControl.image(for: "weChatScan/ScanLowLight_HL"), for: .selected)
        } else if style == .alipay {
            torchBtn!.setImage(MLScanControl.image(for: "zhifuBaoScan/icon_light_off"), for: .normal)
            torchBtn!.setImage(MLScanControl.image(for: "zhifuBaoScan/icon_light_on"), for: .selected)
        } else {
            torchBtn!.setImage(MLScanControl.image(for: "weChatScan/ScanLowLight"), for: .normal)
            torchBtn!.setImage(MLScanControl.image(for: "weChatScan/ScanLowLight_HL"), for: .selected)
        }
        torchBtn!.setTitleColor(UIColor.white, for: .normal)
        torchBtn!.titleLabel?.font = UIFont.systemFont(ofSize: 12)
//        torchBtn!.setTitle("轻点开启", for: .normal)
//        torchBtn!.setTitle("轻点关闭", for: .selected)
        torchBtn!.isHidden = true
        torchBtn?.addTarget(self, action: #selector(torchBtnAction(sender:)), for: .touchUpInside)
        torchBtn!.frame = CGRect(origin: CGPoint.zero, size:CGSize(width: 40, height: 40))
        torchBtn!.center = CGPoint(x: scanFrameView.frame.midX, y: scanFrameView.frame.maxY + 30 + torchBtn!.frame.height/2)
        addSubview(torchBtn!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //mask
        let path = UIBezierPath(rect: self.bounds)
        path.append(UIBezierPath(rect: scanFrameView.frame).reversing())
        self.maskShapLayer.path = path.cgPath
        corverLayerView.layer.mask = self.maskShapLayer
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let _ = self.superview {
            setUpView()
            
            authorization(authorized: { [weak self] in
                self?.initialize()
                self?.start()
            }) { [weak self] in
                self?.showErrorAlertView()
            }
        }
    }
    
    private func setTorchBtn(enable:Bool){
        guard let torchBtn = torchBtn, !torchBtn.isSelected else {
            return
        }
        torchBtn.isHidden = !enable
        if !enable {
            torch(isTurnON: false)
            torchBtn.isSelected = false
        }
    }
    
    @objc
    private func torchBtnAction(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        torch(isTurnON: sender.isSelected)
    }
    
    @objc
    private func zoomAction(sender:UIGestureRecognizer) {
        guard let device = device else {
            return
        }
        if sender is UITapGestureRecognizer {
            if device.videoZoomFactor == device.activeFormat.videoMaxZoomFactor {
                zoom(value: 1, rate: 10)
            } else {
                zoom(value: device.activeFormat.videoMaxZoomFactor, rate: 10)
            }
        }
        if let pinchGestureRecognizer = sender as? UIPinchGestureRecognizer {
            if pinchGestureRecognizer.state == UIGestureRecognizerState.began {
                zoomTemp = device.videoZoomFactor
            }
            if pinchGestureRecognizer.state == .changed || pinchGestureRecognizer.state == .ended {
                zoom(value: pinchGestureRecognizer.scale*zoomTemp)
            }
        }
    }
    
    private func authorization(authorized:(()->())?, error:(()->())?) {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authorizationStatus {
        case.notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted:  Bool) -> Void in
                DispatchQueue.main.async {
                    if granted {
                        authorized?()
                    } else {
                        error?()
                    }
                }
            })
        case.authorized:
            authorized?()
        default:
            error?()
        }
    }
    
    private func showErrorAlertView() {
        let alertVC = UIAlertController(title: "温馨提示", message: "请您设置允许该应用访问您的相机", preferredStyle: UIAlertControllerStyle.alert)
        alertVC.addAction(UIAlertAction(title: "去设置", style:
            UIAlertActionStyle.cancel, handler: { (action) in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }))
        UIApplication.shared.keyWindow?.rootViewController?.present(alertVC, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension MLScanControl: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        //停止扫描
        self.stop()
        playSound()
        
        //扫完完成
        if metadataObjects.count > 0 {
            if let resultObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
                // 展示扫描的结果或者其他处理
                resultClosure?(resultObj.stringValue)
            }
        }
    }
}

extension MLScanControl: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let metadataDict:CFDictionary? = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate)
        let metadata:Dictionary<String,Any>? = metadataDict as? Dictionary<String,Any>
        let exifMetadata:Dictionary<String,Any>? = metadata?[kCGImagePropertyExifDictionary as String] as? Dictionary<String,Any>
        let brightnessValue:Float? = exifMetadata?[kCGImagePropertyExifBrightnessValue as String] as? Float
        if let brightValue = brightnessValue {
            if brightValue <= 0 {
                setTorchBtn(enable: true)
            } else {
                setTorchBtn(enable: false)
            }
        }
    }
}

//MARK - util
extension MLScanControl {
    private func playSound() {
        
        guard self.isSoundEnable else {
            return
        }
        //播放声音
        guard let soundPath = Bundle(path: MLScanControl.bundlePath())?.path(forResource: "sound/noticeMusic.caf", ofType: nil) else { return }
        guard let soundUrl = NSURL(string: soundPath) else { return }
        var soundID:SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundUrl, &soundID)
        AudioServicesPlaySystemSound(soundID)
    }
    
    private class func bundlePath() -> String {
        return Bundle.main.path(forResource: "MLScan", ofType: "bundle")!
    }
    
    private class func image(for name:String) -> UIImage? {
        let bundle = Bundle(path:Bundle.main.path(forResource: "MLScan", ofType: "bundle")!)
        let image = UIImage(named: "images/" + name, in: bundle, compatibleWith: nil)
        return image
    }
    
    /// torch
    ///
    /// - Parameter isTurnON: isTurnON
    private func torch(isTurnON:Bool) {
        guard let device = device else {
            return
        }
        if device.hasTorch {
            if isTurnON {
                try? device.lockForConfiguration()
                device.torchMode =  AVCaptureDevice.TorchMode.on
                device.unlockForConfiguration()
            } else {
                try? device.lockForConfiguration()
                device.torchMode =  AVCaptureDevice.TorchMode.off
                device.unlockForConfiguration()
            }
        }
    }
    
    /// zoom
    ///
    /// - Parameter value: //1..videoMaxZoomFactor
    private func zoom(value:CGFloat, rate:Float = 0) {
        guard let device = device else {
            return
        }
        try? device.lockForConfiguration()
        if rate > 0 {
            device.ramp(toVideoZoomFactor: min(max(value, 1),device.activeFormat.videoMaxZoomFactor), withRate: rate)
        } else {
            device.videoZoomFactor = min(max(value, 1),device.activeFormat.videoMaxZoomFactor)
        }
        device.unlockForConfiguration()
    }
}
