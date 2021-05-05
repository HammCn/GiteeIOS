//
//  PublicKeyModel.swift
//  Gitee
//
//  Created by Hamm on 2021/4/30.
//


import Foundation
import SwiftUI

struct PublicKeyModel:Identifiable {
    let id : Int
    let title : String
    let key : String
    let createTime: String
    init(
        id:Int,
        title: String,
        key: String,
        createTime: String
    ){
        self.id = id
        self.title = title
        self.key = key
        self.createTime = createTime
    }
}
