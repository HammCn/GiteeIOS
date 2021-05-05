//
//  ActivityModel.swift
//  Gitee
//
//  Created by Hamm on 2021/4/29.
//

import Foundation
func getActivityContent(activity:ActivityModel) -> String{
    switch activity.type {
    case .StarEvent:
        return "Star了项目 " + activity.repoInfo.humanName
    case .PushEvent:
        return "推送了 " + String(activity.pushEvent!.commitList.count) + " 个提交到仓库 " + activity.repoInfo.humanName
    case .IssueEvent:
        switch activity.issueEvent!.action {
        case IssueEventAction.open:
            return "在项目 " + activity.repoInfo.humanName + "创建了Issue: “" + activity.issueEvent!.title + "”"
        case IssueEventAction.closed:
            return "关闭了项目 " + activity.repoInfo.humanName + "的Issue: " + activity.issueEvent!.title
        case IssueEventAction.progressing:
            return "设置项目 " + activity.repoInfo.humanName + "的Issue为进行中: " + activity.issueEvent!.title
        case IssueEventAction.rejected:
            return "拒绝了项目 " + activity.repoInfo.humanName + "的Issue: " + activity.issueEvent!.title
        }
    case .IssueCommentEvent:
//        return "评论了仓库 " + activity.repoInfo.humanName + " 的Issue: " + activity.issueCommentEvent!.issue.title  + "\n" + "“" + activity.issueCommentEvent!.commentBody + "”"
        return "评论了仓库 " + activity.repoInfo.humanName + " 的Issue: “" + activity.issueCommentEvent!.commentBody + "”"
    case .PullRequestEvent:
        switch activity.pullRequestEvent!.action {
        case PullRequestStatus.open:
            return "在项目 " + activity.repoInfo.humanName + "创建了Pull Request: “" + activity.pullRequestEvent!.title + "”"
        case .merged:
            return "合并了项目 " + activity.repoInfo.humanName + "的Pull Request: “" + activity.pullRequestEvent!.title + "”"
        case .closed:
            return "拒绝了项目 " + activity.repoInfo.humanName + "的Pull Request: “" + activity.pullRequestEvent!.title + "”"
        }
    case .CreateEvent:
        switch activity.createEvent!.refType {
        case CreateEventRef.branch:
            return "推送了分支 " + activity.createEvent!.ref + " 到仓库 " + activity.repoInfo.humanName
        case CreateEventRef.repository:
            return "创建了新仓库 " + activity.repoInfo.humanName
        }
    case .ProjectCommentEvent:
        return "评论了仓库 " + activity.repoInfo.humanName + " : “" + activity.projectCommentEvent!.commentBody + "”"
    case .MemberEvent:
        return "人员发生变动,这里还有很多事件没解析"
    case .MilestoneEvent:
        return "添加了里程碑,暂未解析细节数据"
    case .DeleteEvent:
        return "删除了仓库 " + activity.repoInfo.humanName
    case .CommitCommentEvent:
        return "评论了代码提交，这里需要解析提交的内容"
    case .PullRequestCommentEvent:
        return "评论了Pull Request,这里需要解析PR的详细信息"
    case .ForkEvent:
        return "Fork了一个仓库"
    }
}
class ActivityModel: Identifiable {
    let id:Int
    let type:ActivityType
    let createTime: String
    let repoInfo: ActivityRepoModel
    let userInfo: UserItemModel
    let starEvent: ActivityStarEvent?
    let pushEvent: ActivityPushEvent?
    let createEvent: ActivityCreateEvent?
    let issueEvent: ActivityIssueEvent?
    let projectCommentEvent: ActivityProjectCommentEvent?
    let issueCommentEvent: ActivityIssueCommentEvent?
    let pullRequestEvent: ActivityPullRequestEvent?
    init(
        id:Int,
        type:ActivityType,
        createTime: String,
        repoInfo: ActivityRepoModel,
        userInfo: UserItemModel,
        starEvent: ActivityStarEvent?,
        pushEvent: ActivityPushEvent?,
        createEvent: ActivityCreateEvent?,
        issueEvent: ActivityIssueEvent?,
        projectCommentEvent: ActivityProjectCommentEvent?,
        issueCommentEvent: ActivityIssueCommentEvent?,
        pullRequestEvent: ActivityPullRequestEvent?
    ){
        self.id = id
        self.type = type
        self.createTime = createTime
        self.repoInfo = repoInfo
        self.userInfo = userInfo
        self.starEvent = starEvent
        self.pushEvent = pushEvent
        self.createEvent = createEvent
        self.issueEvent = issueEvent
        self.projectCommentEvent = projectCommentEvent
        self.issueCommentEvent = issueCommentEvent
        self.pullRequestEvent = pullRequestEvent
    }
}
class ActivityRepoModel:Identifiable{
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
class ActivityIssueModel: Identifiable {
    let id : Int
    let number: String
    let title: String
    init(
        id: Int,
        number: String,
        title: String
    ){
        self.id = id
        self.number = number
        self.title = title
    }
}
class ActivityPullRequestEvent {
    let number:Int
    let title:String
    let action:PullRequestStatus
    init(
        number:Int,
        title:String,
        action:PullRequestStatus
    ){
        self.number = number
        self.title = title
        self.action = action
    }
}
class ActivityIssueCommentEvent {
    let commentBody:String
    let issue: ActivityIssueModel
    init(
        commentBody:String,
        issue: ActivityIssueModel
    ){
        self.commentBody = commentBody
        self.issue = issue
    }
}
class ActivityProjectCommentEvent {
    let commentBody:String
    init(commentBody:String){
        self.commentBody = commentBody
    }
}
class ActivityCreateEvent {
    let refType: CreateEventRef
    let ref: String
    init(refType: CreateEventRef,ref:String){
        self.refType = refType
        self.ref = ref
    }
}
enum CreateEventRef{
    case branch
    case repository
}
class ActivityIssueEvent {
    let action: IssueEventAction
    let title: String
    init(action: IssueEventAction,title:String){
        self.action = action
        self.title = title
    }
}
enum IssueEventAction{
    case open
    case closed
    case progressing
    case rejected
}

class ActivityStarEvent {
    let action: StarEvent
    init(action: StarEvent){
        self.action = action
    }
}

enum StarEvent{
    case starred
}

class ActivityPushEvent{
    let commitList: [ActivityCommitModel]
    init(
        commitList: [ActivityCommitModel]
    ){
        self.commitList = commitList
    }
}

class ActivityCommitModel{
    let name: String
    let message: String
    let sha: String
    init(
        name:String,
        message: String,
        sha: String
    ){
        self.name = name
        self.message = message
        self.sha = sha
    }
}


enum ActivityType {
    case StarEvent
    case PushEvent
    case IssueEvent
    case IssueCommentEvent
    case ProjectCommentEvent
    case PullRequestEvent
    case CreateEvent
    case ForkEvent
    case MemberEvent
    case MilestoneEvent
    case DeleteEvent
    case CommitCommentEvent
    case PullRequestCommentEvent
}

