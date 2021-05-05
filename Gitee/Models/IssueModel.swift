//
//  IssueModel.swift
//  Gitee
//
//  Created by Hamm on 2021/4/23.
//

import Foundation
import SwiftUI

func getIssueStatus(status: String) -> IssueStatus{
    if status == "open"{
        return IssueStatus.open
    }
    if status == "closed"{
        return IssueStatus.closed
    }
    if status == "rejected"{
        return IssueStatus.rejected
    }
    if status == "progressing"{
        return IssueStatus.progressing
    }
    return IssueStatus.open
}
func getIssueStatusString(status: IssueStatus) -> String{
    switch status {
    case IssueStatus.open:
        return "open"
    case IssueStatus.closed:
        return "closed"
    case IssueStatus.rejected:
        return "rejected"
    case IssueStatus.progressing:
        return "progressing"
    }
}
func getIssueIcon(status: IssueStatus) -> String{
    switch status {
    case IssueStatus.open:
        return "moon.circle"
    case IssueStatus.closed:
        return "checkmark.circle"
    case IssueStatus.rejected:
        return "xmark.circle"
    case IssueStatus.progressing:
        return "timer"
    }
}
func getIssueColor(status: IssueStatus) -> Color{
    switch status {
    case IssueStatus.open:
        return Color(.gray)
    case IssueStatus.closed:
        return Color(.green)
    case IssueStatus.rejected:
        return Color(.red)
    case IssueStatus.progressing:
        return Color(.white)
    }
}
class IssueModel: Identifiable {
    let id: Int
    let issueId: String
    let issueTitle: String
    let issueTime: String
    let issueDesc: String
    let issueStatus: IssueStatus
    let repoInfo: RepoModel
    let userInfo: UserItemModel
    init(
        id:Int,
        issueId:String,
        issueTitle:String,
        issueTime:String,
        issueDesc:String,
        issueStatus:IssueStatus,
        repoInfo: RepoModel,
        userInfo: UserItemModel
    ){
        self.id = id
        self.issueId = issueId
        self.issueTitle = issueTitle
        self.issueTime = issueTime
        self.issueStatus = issueStatus
        self.issueDesc = issueDesc
        self.repoInfo = repoInfo
        self.userInfo = userInfo
    }
}

class IssueCommentModel: Identifiable {
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





enum IssueStatus {
    case open
    case progressing
    case rejected
    case closed
}
