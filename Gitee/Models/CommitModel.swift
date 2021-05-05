//
//  CommitModel.swift
//  Gitee
//
//  Created by Hamm on 2021/4/28.
//

import Foundation

class CommitModel:Identifiable {
    let id: String
    let sha:String
    let author: String
    let commitTime:String
    let message:String
    let addCount:String
    let deleteCount:String
    let totalCount:String
    let user:UserItemModel!
    init(
        id:String,
        sha:String,
        author:String,
        commitTime:String,
        message:String,
        addCount:String,
        deleteCount:String,
        totalCount:String,
        user:UserItemModel
    ){
        self.id = id
        self.sha = sha
        self.author = author
        self.commitTime = commitTime
        self.message = message
        self.addCount = addCount == "" ? "0" : addCount
        self.deleteCount = deleteCount == "" ? "0" : deleteCount
        self.totalCount =  totalCount == "" ? "0" : totalCount
        self.user = user
    }
}
class CommitChangeModel {
    let id: Int
    let sha: String
    let status: String
    let filename: String
    let addCount: String
    let deleteCount: String
    let totalCount: String
    let content: String
    init(
        id: Int,
        sha: String,
        status: String,
        filename: String,
        addCount: String,
        deleteCount: String,
        totalCount: String,
        content: String
    ){
        self.id = id
        self.sha = sha
        self.status = status
        self.filename = filename
        self.addCount = addCount
        self.deleteCount = deleteCount
        self.totalCount = totalCount
        self.content = content
    }
}
enum CommitFromModel {
    case fromRepo
    case fromPullRequest
}
