//
//  HttpRequest.swift
//  Gitee
//
//  Created by Hamm on 2021/4/20.
//

import Foundation
class HttpRequest {
    var url:String = ""
    var baseUrl:String = "https://gitee.com/api/v5/"
    //    var url:String = "https://api.bbbug.com/api/"
    var access_token:String = "";
    
    init(url: String) {
        self.url = self.baseUrl
        if url.contains("http://") || url.contains("https://"){
            self.url = url
        }else {
            self.url = self.baseUrl + url
        }
    }
    init(url: String, withAccessToken: Bool) {
        self.url = self.baseUrl
        if url.contains("http://") || url.contains("https://"){
            self.url = url
        }else {
            self.url = self.baseUrl + url
        }
        if withAccessToken {
            let access_token = localConfig.string(forKey: giteeConfig.access_token)
            if access_token != nil{
                self.access_token = access_token!
            }
        }
        print(self.url)
    }
    public func doPost(postData:[String:String],successCallback:@escaping((Data)->Void),errorCallback:@escaping(()->Void)){
        globalConfig.canOpenByMoveToRight = false
        if self.access_token != ""{
            if self.url.contains("?") {
                self.url = self.url + "&access_token=" + self.access_token
            }else{
                self.url = self.url + "?access_token=" + self.access_token
            }
        }
        print(self.url)
        var urlSession:URLSession = URLSession(configuration: .default)
        var urlRequest:URLRequest = URLRequest(url: URL(string: self.url)!)
        urlSession = URLSession(configuration: .default)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        let postString = postData.compactMap({ (key, value) -> String in
            return "\(key)=\(value)"
        }).joined(separator: "&")
        urlRequest.httpBody = postString.data(using: .utf8)
        let task = urlSession.dataTask(with: urlRequest) {(data, response, error) in
            if data != nil{
                successCallback(data!)
            }else{
                errorCallback()
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                globalConfig.canOpenByMoveToRight = true
                print("允许左滑了")
            }
        }
        task.resume()
    }
    public func doGet(successCallback:@escaping((Data)->Void),errorCallback:@escaping(()->Void)){
        globalConfig.canOpenByMoveToRight = false
        if self.access_token != ""{
            if self.url.contains("?") {
                self.url = self.url + "&access_token=" + self.access_token
            }else{
                self.url = self.url + "?access_token=" + self.access_token
            }
        }
        print(self.url)
        var urlSession:URLSession = URLSession(configuration: .default)
        var urlRequest:URLRequest = URLRequest(url: URL(string: self.url)!)
        urlSession = URLSession(configuration: .default)
        urlRequest.httpMethod = "GET"
        let task = urlSession.dataTask(with: urlRequest) {(data, response, error) in
            if data != nil{
                successCallback(data!)
            }else{
                errorCallback()
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                globalConfig.canOpenByMoveToRight = true
                print("允许左滑了")
            }
        }
        task.resume()
    }
    public func doPut(postData:[String:String],successCallback:@escaping((Data)->Void),errorCallback:@escaping(()->Void)){
        globalConfig.canOpenByMoveToRight = false
        if self.access_token != ""{
            if self.url.contains("?") {
                self.url = self.url + "&access_token=" + self.access_token
            }else{
                self.url = self.url + "?access_token=" + self.access_token
            }
        }
        print(self.url)
        var urlSession:URLSession = URLSession(configuration: .default)
        var urlRequest:URLRequest = URLRequest(url: URL(string: self.url)!)
        urlSession = URLSession(configuration: .default)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "PUT"
        let postString = postData.compactMap({ (key, value) -> String in
            return "\(key)=\(value)"
        }).joined(separator: "&")
        urlRequest.httpBody = postString.data(using: .utf8)
        let task = urlSession.dataTask(with: urlRequest) {(data, response, error) in
            if data != nil{
                successCallback(data!)
            }else{
                errorCallback()
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                globalConfig.canOpenByMoveToRight = true
                print("允许左滑了")
            }
        }
        task.resume()
    }
    public func doDelete(postData:[String:String],successCallback:@escaping((Data)->Void),errorCallback:@escaping(()->Void)){
        globalConfig.canOpenByMoveToRight = false
        if self.access_token != ""{
            if self.url.contains("?") {
                self.url = self.url + "&access_token=" + self.access_token
            }else{
                self.url = self.url + "?access_token=" + self.access_token
            }
        }
        print(self.url)
        var urlSession:URLSession = URLSession(configuration: .default)
        var urlRequest:URLRequest = URLRequest(url: URL(string: self.url)!)
        urlSession = URLSession(configuration: .default)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "DELETE"
        let postString = postData.compactMap({ (key, value) -> String in
            return "\(key)=\(value)"
        }).joined(separator: "&")
        urlRequest.httpBody = postString.data(using: .utf8)
        let task = urlSession.dataTask(with: urlRequest) {(data, response, error) in
            if data != nil{
                successCallback(data!)
            }else{
                errorCallback()
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                globalConfig.canOpenByMoveToRight = true
                print("允许左滑了")
            }
        }
        task.resume()
    }
    public func doPatch(postData:[String:String],successCallback:@escaping((Data)->Void),errorCallback:@escaping(()->Void)){
        globalConfig.canOpenByMoveToRight = false
        if self.access_token != ""{
            if self.url.contains("?") {
                self.url = self.url + "&access_token=" + self.access_token
            }else{
                self.url = self.url + "?access_token=" + self.access_token
            }
        }
        print(self.url)
        var urlSession:URLSession = URLSession(configuration: .default)
        var urlRequest:URLRequest = URLRequest(url: URL(string: self.url)!)
        urlSession = URLSession(configuration: .default)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "PATCH"
        let postString = postData.compactMap({ (key, value) -> String in
            return "\(key)=\(value)"
        }).joined(separator: "&")
        urlRequest.httpBody = postString.data(using: .utf8)
        let task = urlSession.dataTask(with: urlRequest) {(data, response, error) in
            if data != nil{
                successCallback(data!)
            }else{
                errorCallback()
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                globalConfig.canOpenByMoveToRight = true
                print("允许左滑了")
            }
        }
        task.resume()
    }
}
