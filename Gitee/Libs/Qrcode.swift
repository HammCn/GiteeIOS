//
//  Qrcode.swift
//  Gitee
//
//  Created by Hamm on 2021/4/22.
//

import Foundation
import SwiftUI
class Qrcode {
    static func setQRCodeToImageView(url: String) -> UIImage {
        // 创建二维码滤镜
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        // 恢复滤镜默认设置
        filter?.setDefaults()
        
        // 设置滤镜输入数据
        let data = url.data(using: String.Encoding.utf8)
        filter?.setValue(data, forKey: "inputMessage")
        
        // 设置二维码的纠错率
        filter?.setValue("H", forKey: "inputCorrectionLevel")
        
        // 从二维码滤镜里面, 获取结果图片
        var image = filter?.outputImage
        
        // 生成一个高清图片
        let transform = CGAffineTransform.init(scaleX: 20, y: 20)
        image = image?.transformed(by: transform)
        
        // 图片处理
        var resultImage = UIImage(ciImage: image!)
        
        // 设置二维码中心显示的小图标
        let center = UIImage(named: "qrcode_center.png")
        resultImage = getClearImage(sourceImage: resultImage, center: center!)
        
        // 显示图片
        return resultImage
    }
    
    // 使图片放大也可以清晰
    static func getClearImage(sourceImage: UIImage, center: UIImage) -> UIImage {
        
        let size = sourceImage.size
        // 开启图形上下文
        UIGraphicsBeginImageContext(size)
        
        // 绘制大图片
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        // 绘制二维码中心小图片
        let width: CGFloat = 160
        let height: CGFloat = 160
        let x: CGFloat = (size.width - width) * 0.5
        let y: CGFloat = (size.height - height) * 0.5
        center.draw(in: CGRect(x: x, y: y, width: width, height: height))
        
        // 取出结果图片
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // 关闭上下文
        UIGraphicsEndImageContext()
 
        return resultImage!
    }
}
