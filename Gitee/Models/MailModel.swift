//
//  MailModel.swift
//  Gitee
//
//  Created by Hamm on 2021/5/4.
//

import Foundation

struct MailModel: Identifiable{
    let id:Int
    let user:UserItemModel
    let message:String
    let time:String
    let isUnRead:Bool
    init(
        id:Int,
        user:UserItemModel,
        message:String,
        time:String,
        isUnRead:Bool
        ){
        self.id = id
        self.user = user
        self.message = message
        self.time = time
        self.isUnRead = isUnRead
    }
}
