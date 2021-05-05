//
//  Extensions.swift
//  Gitee
//
//  Created by Hamm on 2021/4/23.
//

import Foundation
import SwiftUI

extension UIAlertController {
    static func _showAlert(message: String,title: String? ,confirmText: String?,in viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: confirmText, style: .cancel))
        viewController.present(alert, animated: true)
    }
    
    static func alert(message: String,title: String? ,confirmText: String?) {
        if let vc = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            _showAlert(message: message,title: title ,confirmText: confirmText,in: vc)
        }
    }
    
    static func _showConfirm(message: String,title: String? ,confirmText: String?,cancelText: String?,confirm: @escaping((UIAlertAction)->Void), in viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: confirmText, style: .cancel, handler: confirm))
        alert.addAction(UIAlertAction(title: cancelText, style: .destructive))
        viewController.present(alert, animated: true)
    }
    
    static func confirm(message: String,title: String? ,confirmText: String?,cancelText: String?,confirm: @escaping((UIAlertAction)->Void)) {
        if let vc = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            _showConfirm(message: message,title: title ,confirmText: confirmText, cancelText: cancelText,confirm: confirm, in: vc)
        }
    }
    
    static func _showDanger(message: String,title: String? ,confirmText: String?,cancelText: String?,confirm: @escaping((UIAlertAction)->Void), in viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: confirmText, style: .destructive, handler: confirm))
        alert.addAction(UIAlertAction(title: cancelText, style: .cancel))
        viewController.present(alert, animated: true)
    }
    
    static func danger(message: String,title: String? ,confirmText: String?,cancelText: String?,confirm: @escaping((UIAlertAction)->Void)) {
        if let vc = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            _showDanger(message: message,title: title ,confirmText: confirmText, cancelText: cancelText,confirm: confirm, in: vc)
        }
    }
    
    static func _showToast(title: String, in viewController: UIViewController) {
        let alert = UIAlertController(title: title,message: "ces", preferredStyle: .alert)
        viewController.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            viewController.presentedViewController?.dismiss(animated: false, completion: nil)
        }
    }
    
    static func toast(title: String) {
        if let vc = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            _showToast(title: title, in: vc)
        }
    }
    static func _showActionSheet(list: [String],title: String?, callback: @escaping((String)->Void), in viewController: UIViewController) {
        let alert = UIAlertController(title: title,message: nil, preferredStyle: .actionSheet)
        let cancel=UIAlertAction(title:"取消", style: .cancel, handler: nil)
        alert.addAction(cancel)
        for item in list {
            let _item = UIAlertAction(title:item, style: .default)
            {
                action in
                callback(item)
            }
            alert.addAction(_item)
        }
        viewController.present(alert, animated:true, completion:nil)
    }
    
    static func actionSheet(list: [String],title: String?, callback: @escaping((String)->Void)) {
        if let vc = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            _showActionSheet(list: list,title: title,callback: callback, in: vc)
        }
    }
}

extension UIApplication {
    func visibleViewController() -> UIViewController? {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return nil }
        guard let rootViewController = window.rootViewController else { return nil }
        return UIApplication.getVisibleViewControllerFrom(vc: rootViewController)
    }
    
    private static func getVisibleViewControllerFrom(vc:UIViewController) -> UIViewController {
        if let navigationController = vc as? UINavigationController,
           let visibleController = navigationController.visibleViewController  {
            return UIApplication.getVisibleViewControllerFrom( vc: visibleController )
        } else if let tabBarController = vc as? UITabBarController,
                  let selectedTabController = tabBarController.selectedViewController {
            return UIApplication.getVisibleViewControllerFrom(vc: selectedTabController )
        } else {
            if let presentedViewController = vc.presentedViewController {
                return UIApplication.getVisibleViewControllerFrom(vc: presentedViewController)
            } else {
                return vc
            }
        }
    }
}

extension Color {
    init(hex: Int, alpha: Double = 1) {
        let components = (
            R: Double((hex >> 16) & 0xff) / 255,
            G: Double((hex >> 08) & 0xff) / 255,
            B: Double((hex >> 00) & 0xff) / 255
        )
        self.init(
            .sRGB,
            red: components.R,
            green: components.G,
            blue: components.B,
            opacity: alpha
        )
    }
}
extension String {
    func matchingStrings(regex: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        return results.map { result in
            (0..<result.numberOfRanges).map { result.range(at: $0).location != NSNotFound
                ? nsString.substring(with: result.range(at: $0))
                : ""
            }
        }
    }
}
