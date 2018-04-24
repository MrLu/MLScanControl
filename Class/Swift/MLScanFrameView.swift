//
//  MLScanFrameView.swift
//  SuperLearn_toelf
//
//  Created by Mrlu on 18/01/2018.
//  Copyright © 2018 xdf. All rights reserved.
//

import UIKit

protocol MLScanFrameViewProtocol:NSObjectProtocol {
    func startAnimation() -> Void
    func stopAnimation() -> Void
}

extension MLScanFrameViewProtocol {
    func startAnimation() -> Void {}
    func stopAnimation() -> Void {}
}

public enum MLScanStyle {
    case weChat
    case alipay
    case custom
}

enum MLMaskContentStyle {
    case full
    case center
}

class MLScanFrameView: UIView, MLScanFrameViewProtocol {

    private var corners:[String]?
    var style:MLScanStyle = .weChat
    var _maskContentStyle:MLMaskContentStyle = .center
    var maskContentStyle:MLMaskContentStyle {
        get {
            if style == .weChat {
                _maskContentStyle = .center
            }
            if style == .alipay {
                _maskContentStyle = .full
            }
            return _maskContentStyle
        }
    }
    
    private var corner1:UIImageView = {
        let corner = UIImageView()
        corner.contentMode = UIViewContentMode.scaleAspectFill
        return corner
    }()
    
    private var corner2:UIImageView = {
        let corner = UIImageView()
        corner.contentMode = UIViewContentMode.scaleAspectFill
        return corner
    }()
    
    private var corner3:UIImageView = {
        let corner = UIImageView()
        corner.contentMode = UIViewContentMode.scaleAspectFill
        return corner
    }()
    
    private var corner4:UIImageView = {
        let corner = UIImageView()
        corner.contentMode = UIViewContentMode.scaleAspectFill
        return corner
    }()
    
    private var maskImageView:UIImageView = {
        let maskImageView = UIImageView()
        maskImageView.contentMode = UIViewContentMode.scaleToFill
        return maskImageView
    }()
    
    init(frame: CGRect, style:MLScanStyle) {
        super.init(frame: frame)
        self.style = style
        setUpView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    func setUpView() {
        layer.masksToBounds = true
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 0.5
        
        addSubview(maskImageView)
        addSubview(corner1)
        addSubview(corner2)
        addSubview(corner3)
        addSubview(corner4)
        layoutCornersViews()
        loadMaskImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutCornersViews() {
        let bundle = Bundle(path:Bundle.main.path(forResource: "MLScan", ofType: "bundle")!)
        if style == .weChat {
            corner1.image = UIImage(named: "images/weChatScan/ScanQR1.png", in: bundle, compatibleWith: nil)
            corner2.image = UIImage(named: "images/weChatScan/ScanQR2.png", in: bundle, compatibleWith: nil)
            corner3.image = UIImage(named: "images/weChatScan/ScanQR3.png", in: bundle, compatibleWith: nil)
            corner4.image = UIImage(named: "images/weChatScan/ScanQR4.png", in: bundle, compatibleWith: nil)
        } else if style == .alipay {
            corner1.image = UIImage(named: "images/zhifuBaoScan/scan_1.png", in: bundle, compatibleWith: nil)
            corner2.image = UIImage(named: "images/zhifuBaoScan/scan_2.png", in: bundle, compatibleWith: nil)
            corner3.image = UIImage(named: "images/zhifuBaoScan/scan_3.png", in: bundle, compatibleWith: nil)
            corner4.image = UIImage(named: "images/zhifuBaoScan/scan_4.png", in: bundle, compatibleWith: nil)
        } else if style == .custom {
            if let corners = corners, corners.count >= 4 {
                corner1.image = UIImage(named: corners[0])
                corner2.image = UIImage(named: corners[1])
                corner3.image = UIImage(named: corners[2])
                corner4.image = UIImage(named: corners[3])
            }
        }
        if let size = corner1.image?.size {
            corner1.frame = CGRect(origin: CGPoint.zero, size:size)
        }
        if let size = corner2.image?.size {
            corner2.frame = CGRect(origin: CGPoint(x: bounds.width - size.width, y: 0) , size:size)
        }
        if let size = corner3.image?.size {
            corner3.frame = CGRect(origin: CGPoint(x: 0, y: bounds.height - size.height), size:size)
        }
        if let size = corner4.image?.size {
            corner4.frame = CGRect(origin: CGPoint(x: bounds.width - size.width, y: bounds.height - size.height), size:size)
        }
    }
    
    private func loadMaskImage() {
        let bundle = Bundle(path:Bundle.main.path(forResource: "MLScan", ofType: "bundle")!)
        if style == .weChat {
            maskImageView.image = UIImage(named: "images/weChatScan/ff_QRCodeScanLine.png", in: bundle, compatibleWith: nil)
        } else if style == .alipay {
            maskImageView.image = UIImage(named: "images/zhifuBaoScan/scan_net@2x.png", in: bundle, compatibleWith: nil)
        }
        if let size = maskImageView.image?.size {
            let height = min(self.bounds.height, size.height)
            if maskContentStyle == .full {
                maskImageView.frame = CGRect(origin: CGPoint(x: 0, y: -height), size:CGSize(width: bounds.width, height:height))
            } else {
                maskImageView.frame = CGRect(origin: CGPoint(x: 0, y: -height/2), size:CGSize(width: bounds.width, height:height))
            }
        }
    }
    
    func startAnimation() {
        UIView.animate(withDuration: 1.5, delay: 0, options: [.curveEaseInOut,.repeat], animations: {
            self.maskImageView.transform = CGAffineTransform(translationX: 0, y: self.bounds.height)
        }) { (finished) in

        }
    }
    
    func stopAnimation() {
        maskImageView.layer.removeAllAnimations()
        self.maskImageView.transform = CGAffineTransform.identity
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
