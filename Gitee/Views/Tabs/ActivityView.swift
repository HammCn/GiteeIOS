//
//  Activities.swift
//  Gitee
//
//  Created by Hamm on 2021/4/29.
//
import SwiftUI
import SwiftyJSON
import SwipeCell

struct ActivityView: View {
    @State var activityList: [ActivityModel] = []
    @State var waitPlease = false
    @State var isRefreshing = false
    @State var isLoading: Bool = false
    @State var isModal: Bool = false
    @State var message: String = "数据加载中"
    @State var isLoginShow = false
    @State var lastId = 0 //331672539
    
    @State var myInfoString:JSON? = nil;
    var body: some View {
        LoadingView(isLoading:self.$isLoading,message: self.$message,isModal:self.$isModal) {
            ZStack{
                if activityList.count == 0 && !isLoading {
                    VStack{
                        Image(systemName: "doc.text.magnifyingglass")
                            .scaleEffect(3, anchor: .center)
                        Text("动态读取中").padding(.top,30)
                    }
                }
                RefreshView(refreshing: $isRefreshing, action: {
                    self.lastId = 0
                    self.getActivityList()
                }) {
                    LazyVStack{
                        ForEach(self.activityList){ item in
                            ActivityItemView(activity: item)
                            .onAppear(){
                                if !waitPlease && item.id == activityList[activityList.count - 1].id {
                                    self.getActivityList()
                                }
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $isLoginShow,onDismiss: {
                self.lastId = 0
                self.getActivityList()
            }){
                LoginView()
                    .modifier(DisableModalDismiss(disabled: true))
            }
            .onAppear(){
                self.lastId = 0
                self.getActivityList()
            }
        }
    }
    func getActivityList(){
        if self.waitPlease { return }
        self.waitPlease = true
        if activityList.count == 0 {
            self.isLoading = true
        }
        let user_name = localConfig.string(forKey: giteeConfig.user_name)
        if user_name == nil {
            self.isLoginShow = true
            return
        }
        let url = "users/" + user_name! + "/received_events?limit=30&prev_id=" + String(lastId)
        HttpRequest(url: url, withAccessToken: true)
            .doGet { (value) in
                let json = JSON(value)
                if json["message"].string != nil {
                    print("error")
                    print(json["message"].stringValue)
                    self.isLoginShow.toggle()
                }else{
                    var tempList = activityList
                    if lastId == 0{
                        tempList = []
                    }
                    for (_,subJson):(String, JSON) in json {
                        lastId = subJson["id"].intValue
                        let repoNamespace = RepoNamespace(id: Int(subJson["repo"]["namespace"]["id"].intValue), name: String(subJson["repo"]["namespace"]["name"].stringValue), path: String(subJson["repo"]["namespace"]["path"].stringValue))
                        let repoInfo = ActivityRepoModel(id: Int(subJson["repo"]["id"].intValue), fullName: String(subJson["repo"]["full_name"].stringValue), humanName: String(subJson["repo"]["human_name"].stringValue), namespace: repoNamespace)
                        
                        let userInfo = UserItemModel(id: Int(subJson["actor"]["id"].stringValue)!, userHead: String(subJson["actor"]["avatar_url"].stringValue), userName: String(subJson["actor"]["name"].stringValue), userAccount: String(subJson["actor"]["login"].stringValue))
                        
                        let activityType = subJson["type"]
                        switch activityType {
                        case "StarEvent":
                            //Star
                            var action:StarEvent? = nil
                            switch subJson["payload"]["action"].stringValue {
                            case "starred":
                                action = StarEvent.starred
                            default:
                                action = nil
                            }
                            
                            if action != nil {
                                tempList.append(ActivityModel(id: Int(subJson["id"].intValue), type: ActivityType.StarEvent, createTime: Helper.getDateFromString(str: String(subJson["created_at"].stringValue)), repoInfo: repoInfo, userInfo: userInfo, starEvent: ActivityStarEvent(action: StarEvent.starred), pushEvent: nil, createEvent: nil, issueEvent: nil, projectCommentEvent: nil, issueCommentEvent: nil, pullRequestEvent: nil))
                            }
                        case "PushEvent":
                            //代码推送
                            var commitList:[ActivityCommitModel] = []
                            for (_,commitJson):(String, JSON) in subJson["payload"]["commits"] {
                                commitList.append(ActivityCommitModel(name: String(commitJson["author"]["name"].stringValue), message: String(commitJson["message"].stringValue), sha: String(commitJson["sha"].stringValue)))
                            }
                            
                            tempList.append(ActivityModel(id: Int(subJson["id"].intValue), type: ActivityType.PushEvent, createTime: Helper.getDateFromString(str: String(subJson["created_at"].stringValue)), repoInfo: repoInfo, userInfo: userInfo,starEvent: nil,pushEvent: ActivityPushEvent(commitList: commitList), createEvent: nil, issueEvent: nil, projectCommentEvent: nil, issueCommentEvent: nil, pullRequestEvent: nil))
                        case "IssueEvent":
                            var action: IssueEventAction = IssueEventAction.open
                            if subJson["payload"]["action"].stringValue == "open"{
                                action = IssueEventAction.open
                            }
                            if subJson["payload"]["action"].stringValue == "closed"{
                                action = IssueEventAction.closed
                            }
                            if subJson["payload"]["action"].stringValue == "rejected"{
                                action = IssueEventAction.rejected
                            }
                            if subJson["payload"]["action"].stringValue == "progressing"{
                                action = IssueEventAction.progressing
                            }
                            
                            tempList.append(ActivityModel(id: Int(subJson["id"].intValue), type: ActivityType.IssueEvent, createTime: Helper.getDateFromString(str: String(subJson["created_at"].stringValue)), repoInfo: repoInfo, userInfo: userInfo,starEvent: nil,pushEvent:nil, createEvent: nil, issueEvent: ActivityIssueEvent(action: action,title: subJson["payload"]["title"].stringValue), projectCommentEvent: nil, issueCommentEvent: nil, pullRequestEvent: nil))
                        case "CreateEvent":
                            var ref: CreateEventRef = CreateEventRef.repository
                            if subJson["payload"]["ref_type"].stringValue == "repository"{
                                ref = CreateEventRef.repository
                            }
                            if subJson["payload"]["ref_type"].stringValue == "branch"{
                                ref = CreateEventRef.branch
                            }
                            
                            tempList.append(ActivityModel(id: Int(subJson["id"].intValue), type: ActivityType.CreateEvent, createTime: Helper.getDateFromString(str: String(subJson["created_at"].stringValue)), repoInfo: repoInfo, userInfo: userInfo,starEvent: nil,pushEvent:nil, createEvent: ActivityCreateEvent(refType: ref, ref: subJson["payload"]["ref"].stringValue), issueEvent: nil, projectCommentEvent: nil, issueCommentEvent: nil, pullRequestEvent: nil))
                        case "ProjectCommentEvent":
                            tempList.append(ActivityModel(id: Int(subJson["id"].intValue), type: ActivityType.ProjectCommentEvent, createTime: Helper.getDateFromString(str: String(subJson["created_at"].stringValue)), repoInfo: repoInfo, userInfo: userInfo,starEvent: nil,pushEvent:nil, createEvent: nil, issueEvent: nil, projectCommentEvent: ActivityProjectCommentEvent(commentBody: subJson["payload"]["comment"]["body"].stringValue), issueCommentEvent: nil, pullRequestEvent: nil))
                            
                        case "IssueCommentEvent":
                            let repoInfo = ActivityRepoModel(id: subJson["payload"]["repository"]["id"].intValue, fullName: subJson["payload"]["repository"]["full_name"].stringValue, humanName: subJson["payload"]["repository"]["human_name"].stringValue, namespace: repoNamespace)
                            let issue = ActivityIssueModel(id: subJson["payload"]["issue"]["id"].intValue, number: subJson["payload"]["issue"]["number"].stringValue, title: subJson["payload"]["issue"]["title"].stringValue)
                            tempList.append(ActivityModel(id: Int(subJson["id"].intValue), type: ActivityType.IssueCommentEvent, createTime: Helper.getDateFromString(str: String(subJson["created_at"].stringValue)), repoInfo: repoInfo, userInfo: userInfo,starEvent: nil,pushEvent:nil, createEvent: nil, issueEvent: nil, projectCommentEvent: nil, issueCommentEvent: ActivityIssueCommentEvent(commentBody: subJson["payload"]["comment"]["body"].stringValue, issue: issue), pullRequestEvent: nil))
                            
                        case "PullRequestEvent":
                            var action = PullRequestStatus.open
                            if subJson["payload"]["action"].stringValue == "open"{
                                action = PullRequestStatus.open
                            }
                            if subJson["payload"]["action"].stringValue == "closed"{
                                action = PullRequestStatus.closed
                            }
                            if subJson["payload"]["action"].stringValue == "merged"{
                                action = PullRequestStatus.merged
                            }
                            tempList.append(ActivityModel(id: Int(subJson["id"].intValue), type: ActivityType.PullRequestEvent, createTime: Helper.getDateFromString(str: String(subJson["created_at"].stringValue)), repoInfo: repoInfo, userInfo: userInfo,starEvent: nil,pushEvent:nil, createEvent: nil, issueEvent: nil, projectCommentEvent: nil, issueCommentEvent: nil, pullRequestEvent: ActivityPullRequestEvent(number: subJson["payload"]["number"].intValue, title: subJson["payload"]["title"].stringValue,action: action)))
                        default:
                            print(activityType)
                            continue
                        }
                    }
                    self.activityList = tempList
                }
                self.isRefreshing = false
                self.isLoading = false
                self.waitPlease = false
            } errorCallback: {
                self.isRefreshing = false
                self.isLoading = false
                self.waitPlease = false
            }
    }
}

struct ActivityItemView:View{
    @State var activity: ActivityModel
    @State var placeholderImage = UIImage(named: "nohead")!
    @State var isActivePullRequest:Bool = false
    @State var isActiveRepoDetail:Bool = false
    @State var isActiveCommit:Bool = false
    @State var isActiveIssues:Bool = false
    var body: some View{
        NavigationLink(destination: PullRequestView(repoFullPath: activity.repoInfo.fullName), isActive: $isActivePullRequest) { EmptyView() }
        NavigationLink(destination: RepoDetailView(repoFullPath: activity.repoInfo.fullName), isActive: $isActiveRepoDetail) { EmptyView() }
        NavigationLink(destination:
                        CommitView(repoFullPath: activity.repoInfo.fullName, repoDefaultBranch: "master"), isActive: $isActiveCommit) { EmptyView() }
        NavigationLink(destination:  IssuesView(repoPath:activity.repoInfo.fullName), isActive: $isActiveIssues) { EmptyView() }
        
        VStack(alignment: .leading){
            VStack(alignment: .leading){
                HStack(alignment: .top) {
                    Image(uiImage: placeholderImage)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width:40,height:40,
                            alignment: .center
                        )
                        .cornerRadius(5)
                        .onAppear(){
                            guard let url = URL(string: activity.userInfo.userHead) else {
                                return
                            }
                            URLSession.shared.dataTask(with: url) { (data, response, error) in
                                if let data = data, let image = UIImage(data: data) {
                                    placeholderImage = image
                                }
                            }.resume()
                        }
                    VStack(alignment: .leading){
                        HStack(alignment:.top){
                            Text(activity.userInfo.userName)
                                .padding(0)
                            Spacer()
                            Text(activity.createTime).font(.system(size:12)).foregroundColor(.gray)
                        }
                        Text(getActivityContent(activity:activity)).font(.system(size:14)).foregroundColor(.gray)
                            .padding(.top,1)
                            .lineLimit(10)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(10)
            Spacer()
        }
//        .frame(height:100)
        .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
        .cornerRadius(10)
        .padding(.horizontal,5)
        .padding(.top,5)
        .contextMenu(ContextMenu {
            Button(action: {
                self.isActiveRepoDetail = true
            }) {
                HStack{
                    Image(systemName: "archivebox.circle").scaleEffect(1, anchor: .center)
                    Spacer()
                    Text("进入仓库")
                }
            }
            Divider()
            Button(action: {
                self.isActiveCommit = true
            }) {
                HStack{
                    Image(systemName: "icloud.and.arrow.up").scaleEffect(1, anchor: .center)
                    Spacer()
                    Text("查看提交")
                }
            }
            Button(action: {
                self.isActivePullRequest = true
            }) {
                HStack{
                    Image(systemName: "shuffle.circle").scaleEffect(1, anchor: .center)
                    Spacer()
                    Text("查看Pull Requests")
                }
            }
            Button(action: {
                self.isActiveIssues = true
            }) {
                HStack{
                    Image(systemName: "exclamationmark.circle").scaleEffect(1, anchor: .center)
                    Spacer()
                    Text("查看Issues")
                }
            }
            Divider()
            Button(action: {
            }) {
                HStack{
                    Image(systemName: "person.circle").scaleEffect(1, anchor: .center)
                    Spacer()
                    Text("用户资料")
                }
            }
        })
    }
}
