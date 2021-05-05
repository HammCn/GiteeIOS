//
//  OrgModel.swift
//  Gitee
//
//  Created by Hamm on 2021/5/4.
//

import SwiftUI

struct OrgModel: Identifiable{
    let id:Int
    let account:String
    let name:String
    let head:String
    let desc:String
    let fans:Int
    init(
        id:Int,
        account:String,
        name:String,
        head:String,
        desc:String,
        fans:Int
    ){
        self.id = id
        self.account = account
        self.name = name
        self.head = head
        self.desc = desc
        self.fans = fans
    }
}

