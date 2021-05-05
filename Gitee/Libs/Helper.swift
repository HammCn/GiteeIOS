//
//  Helper.swift
//  Gitee
//
//  Created by Hamm on 2021/4/22.
//

import Foundation
import SwiftUI

class Helper {
    public static func getDateFromString(str: String) -> String{
        if str == "" {
            return "未知"
        }
        var stringTime = ""
        let arr = str.matchingStrings(regex: "(.*?)-(.*?)-(.*?)T(.*?):(.*?):(.*?)[+-]")
        if arr.count > 0 && arr[0].count >= 7 {
            stringTime = arr[0][1] + "-" + arr[0][2] + "-" + arr[0][3] + " " + arr[0][4] + ":" + arr[0][5] + ":" + arr[0][6]
        }else{
            return "未知"
        }
        let format = DateFormatter.init()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = format.date(from: stringTime)
        let timeStamp = Int(date!.timeIntervalSince1970)
        let nowDate:Date = Date.init(timeIntervalSinceNow: 0)
        let nowTimestamp = Int(nowDate.timeIntervalSince1970)
        let diffTime = nowTimestamp - timeStamp
        if diffTime > 86400 * 365 {
            return String(Int(diffTime / 86400 / 365)) + "年前"
        }
        if diffTime > 86400 * 31 {
            return String(Int(diffTime / 86400 / 31)) + "月前"
        }
        if diffTime > 86400 * 7 {
            return String(Int(diffTime / 86400 / 7)) + "周前"
        }
        if diffTime > 86400  {
            return String(Int(diffTime / 86400)) + "天前"
        }
        if diffTime > 3600  {
            return String(Int(diffTime / 3600)) + "小时前"
        }
        if diffTime > 60  {
            return String(Int(diffTime / 60)) + "分钟前"
        }
        return "刚刚"
    }
    public static func base64Encoding(plainString:String)->String{
        let plainData = plainString.data(using: String.Encoding.utf8)
        let base64String = plainData?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        return base64String!
    }
    public static func base64Decoding(encodedString:String)->String{
        let decodedData = NSData(base64Encoded: encodedString, options: NSData.Base64DecodingOptions.init(rawValue: 0))
        let decodedString = NSString(data: decodedData! as Data, encoding: String.Encoding.utf8.rawValue)! as String
        return decodedString
    }
    public static func relogin(){
        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController = UIHostingController(rootView: TabBarView(selectedBarIndex: 3))
    }
}

