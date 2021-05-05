//
//  NotificationModel.swift
//  Gitee
//
//  Created by Hamm on 2021/5/2.
//

import Foundation
class NotificationModel: Identifiable {
    let id: Int
    let message:String
    let type:NotificationType
    let isUnRead:Bool
    let time:String
    let user:UserItemModel
    let repo:NotificationRepoModel
    init(
        id:Int,
        message:String,
        type:NotificationType,
        isUnRead:Bool,
        time:String,
        user:UserItemModel,
        repo:NotificationRepoModel
    ){
        self.id = id
        self.message = message
        self.type = type
        self.isUnRead = isUnRead
        self.time = time
        self.user = user
        self.repo = repo
    }
    
}
enum NotificationType {
    case project_acquire_donation
    case note_comment
    case pull_request_test
    case issue_new
    case issue_state_change
    case referer
    case project_release
    case project_push
    case note_pull_request
    case project_transfer
    case project_enable_donation
    case pull_request_close
    case pull_request_merge
    case project_refuse_donation
    case pull_request_assign
    case note_reply
}
func getNotificationType(str:String) -> NotificationType{
    switch str {
    case "project_acquire_donation":
        return NotificationType.project_acquire_donation
    case "note_comment":
        return NotificationType.note_comment
    case "pull_request_test":
        return NotificationType.pull_request_test
    case "issue_new":
        return NotificationType.issue_new
    case "issue_state_change":
        return NotificationType.issue_state_change
    case "referer":
        return NotificationType.referer
    case "project_release":
        return NotificationType.project_release
    case "project_push":
        return NotificationType.project_push
    case "note_pull_request":
        return NotificationType.note_pull_request
    case "project_transfer":
        return NotificationType.project_transfer
    case "project_enable_donation":
        return NotificationType.project_enable_donation
    case "pull_request_close":
        return NotificationType.pull_request_close
    case "pull_request_merge":
        return NotificationType.pull_request_merge
    case "project_refuse_donation":
        return NotificationType.project_refuse_donation
    case "pull_request_assign":
        return NotificationType.pull_request_assign
    case "note_reply":
        return NotificationType.note_reply
    default:
        return NotificationType.note_comment
    }
}

class NotificationRepoModel:Identifiable{
    let id : Int
    let fullName:String
    let humanName:String
    let namespace: RepoNamespace
    init(
        id : Int,
        fullName:String,
        humanName:String,
        namespace: RepoNamespace
    ){
        self.id = id
        self.fullName = fullName
        self.humanName = humanName
        self.namespace = namespace
    }
}
