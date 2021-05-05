//
//  PullRequestModel.swift
//  Gitee
//
//  Created by Hamm on 2021/4/27.
//

import SwiftUI

struct PullRequestModel: Identifiable {
    let id: Int
    let prId: Int
    let prStatus: PullRequestStatus
    let prTitle:String
    let prBody:String
    let prUser:UserItemModel
    let prFrom: RepoModel
    let prTo: RepoModel
    let prFromBranch: String
    let prToBranch: String
    let prTime: String
    let prAutoMerge:Bool
    init(
        id:Int,
        prId:Int,
        prStatus:PullRequestStatus,
        prTitle:String,
        prBody:String,
        prUser:UserItemModel,
        prFrom:RepoModel,
        prTo:RepoModel,
        prTime:String,
        prAuthMerge:Bool ,
        prFromBranch:String,
        prToBranch:String
    ){
        self.id = id
        self.prId = prId
        self.prStatus = prStatus
        self.prTitle = prTitle
        self.prBody = prBody
        self.prUser = prUser
        self.prFrom = prFrom
        self.prTo = prTo
        self.prFromBranch = prFromBranch
        self.prToBranch = prToBranch
        self.prTime = prTime
        self.prAutoMerge = prAuthMerge
    }
}

func getPullRequestStatus(status: String) -> PullRequestStatus{
    if status == "open"{
        return PullRequestStatus.open
    }
    if status == "closed"{
        return PullRequestStatus.closed
    }
    if status == "merged"{
        return PullRequestStatus.merged
    }
    return PullRequestStatus.open
}
func getPullRequestStatusString(status: PullRequestStatus) -> String{
    switch status {
    case PullRequestStatus.open:
        return "open"
    case PullRequestStatus.closed:
        return "closed"
    case PullRequestStatus.merged:
        return "merged"
    }
}
func getPullRequestIcon(status: PullRequestStatus) -> String{
    switch status {
    case PullRequestStatus.open:
        return "moon.circle"
    case PullRequestStatus.merged:
        return "checkmark.circle"
    case PullRequestStatus.closed:
        return "xmark.circle"
    }
}
func getPullRequestStatusStringShow(pullRequestItem: PullRequestModel) -> String{
    switch pullRequestItem.prStatus {
    case PullRequestStatus.open:
        if pullRequestItem.prAutoMerge{
            return "可合并"
        }else{
            return "有冲突"
        }
    case PullRequestStatus.closed:
        return "已拒绝"
    case PullRequestStatus.merged:
        return "已合并"
    }
}
func getPullRequestColor(pullRequestItem: PullRequestModel) -> Color{
    switch pullRequestItem.prStatus {
    case PullRequestStatus.open:
        if pullRequestItem.prAutoMerge{
            return Color(.white)
        }else{
            return Color(.yellow)
        }
    case PullRequestStatus.closed:
        return Color(.red)
    case PullRequestStatus.merged:
        return Color(.green)
    }
}


class PullRequestCommentModel {
    let id: Int
    let commentBody: String
    let createTime: String
    let commentUser: UserItemModel
    init(
        id:Int,
        commentBody:String,
        createTime:String,
        commentUser:UserItemModel
    ){
        self.id = id
        self.commentBody = commentBody
        self.createTime = createTime
        self.commentUser = commentUser
    }
}



enum PullRequestStatus {
    case open
    case merged
    case closed
}
