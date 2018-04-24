//
//  ViewController.swift
//  MLScanControl
//
//  Created by Mrlu on 22/01/2018.
//  Copyright © 2018 Mrlu. All rights reserved.
//

import UIKit

class ViewController_swift: UIViewController {

    private var scanControl:MLScanControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        scanControl = MLScanControl(frame: view.bounds, style:.alipay)
        scanControl.offsetY = -100
        view.addSubview(scanControl)
        scanControl.result { (result) -> (Void) in
            if let _ = result {
                let alertVC = UIAlertController(title: "温馨提示", message: result, preferredStyle: UIAlertControllerStyle.alert)
                alertVC.addAction(UIAlertAction(title: "知道了", style: UIAlertActionStyle.cancel, handler: { (action) in
                    
                }))
                UIApplication.shared.keyWindow?.rootViewController?.present(alertVC, animated: true, completion: nil)
            }
        }
        
        self.scanControl.start()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.scanControl.start()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.scanControl.stop()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

