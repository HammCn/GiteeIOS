//
//  UserInfo.swift
//  Gitee
//
//  Created by Hamm on 2021/4/21.
//

import Foundation
import SwiftUI
import SwiftyJSON
class UserModel {
    init(){
        
    }
    public func getMyInfo(success:@escaping((JSON)->Void),error:@escaping(()->Void)){
        HttpRequest(url: "user",withAccessToken: true).doGet { (value) in
            let json = JSON(value)
            if json["message"].stringValue != "" {
                error()
            }else{
                success(json)
            }
        } errorCallback: {
            error()
        }
    }
}

class UserItemModel: Identifiable {
    let id: Int
    let userHead: String
    let userName: String
    let userAccount: String
    init(
        id:Int,
        userHead: String,
        userName: String,
        userAccount: String
    ){
        self.id = id
        self.userHead = userHead
        self.userName = userName
        self.userAccount = userAccount
    }
}

class UserForkModel: Identifiable {
    let id: Int
    let userInfo: UserItemModel
    let repoPath:String
    let repoName:String
    init(
        id:Int,
        repoPath:String,
        repoName:String,
        userInfo:UserItemModel
    ){
        self.id = id
        self.userInfo = userInfo
        self.repoPath = repoPath
        self.repoName = repoName
    }
}
