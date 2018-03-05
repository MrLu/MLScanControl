# MLScanControl

[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
             )](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat)](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](http://mit-license.org)

> swift 二维码扫描

> 支持闪关灯自动检测

> 支持焦距调整

##使用:
###示例代码
```
        scanControl = MLScanControl(frame: view.bounds, style:.alipay)
        scanControl.offsetY = -100
        view.addSubview(scanControl)
        
        scanControl.result { (result) -> (Void) in
            if let _ = result {
                
            }
        }
        
        self.scanControl.start()
```



### 注意事项
>代码下载实现依赖 `import AVFoundation` 库，如果利用此控件，必须导入。

>或者自己实现现在存储，修改此库原文件。

### by
* 问题建议 to mail
* mail：haozi370198370@gmail.com
