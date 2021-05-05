//
//  NotificationView.swift
//  Gitee
//
//  Created by Hamm on 2021/5/2.
//

import SwiftUI
import SwiftyJSON
import SwipeCell

struct NotificationView: View {
    @State var notificationList: [NotificationModel] = []
    @State var waitPlease = false
    @State var isRefreshing = false
    @State var isLoading: Bool = false
    @State var isModal: Bool = false
    @State var message: String = "数据加载中"
    @State var page = 1
    var body: some View {
        LoadingView(isLoading:self.$isLoading,message: self.$message,isModal:self.$isModal) {
            ZStack{
                if notificationList.count == 0 && !isLoading {
                    VStack{
                        Image(systemName: "doc.text.magnifyingglass")
                            .scaleEffect(3, anchor: .center)
                        Text("暂无查询到的通知").padding(.top,30)
                    }
                }
                RefreshView(refreshing: $isRefreshing, action: {
                    self.page = 1
                    self.getNotificationList(page: self.page)
                }) {
                    LazyVStack{
                        ForEach(self.notificationList){ item in
                            NotificationItemView(notificationItem: item)
                                .onAppear(){
                                    if !waitPlease && item.id == notificationList[notificationList.count - 1].id {
                                        self.page = self.page + 1
                                        self.getNotificationList(page: self.page)
                                    }
                                }
                        }
                    }
                }
            }
        }
        .padding(.top,5)
        .navigationBarTitle(Text("消息通知"), displayMode: .inline)
        .onAppear(){
            self.page = 1
            self.getNotificationList(page: self.page)
        }
    }
    func getNotificationList(page: Int){
        if self.waitPlease { return }
        self.waitPlease = true
        if notificationList.count == 0 {
            self.isLoading = true
        }
        let url = "notifications/threads?page=" + String(page)
        
        HttpRequest(url: url, withAccessToken: true)
            .doGet { (value) in
                let json = JSON(value)
                if json["message"].string != nil {
                    print("error")
                    DispatchQueue.main.async {
                        UIAlertController.confirm(message: json["message"].stringValue, title: "发生错误", confirmText: "重新登录", cancelText: "返回") { (action) in
                            Helper.relogin()
                        }
                    }
                }else{
                    var tempList = self.notificationList
                    if page == 1{
                        tempList = []
                    }
                    for (_,subJson):(String, JSON) in json["list"] {
                        var userInfo:UserItemModel
                        if subJson["actor"]["id"].intValue > 0 {
                            userInfo = UserItemModel(id: subJson["actor"]["id"].intValue, userHead: subJson["actor"]["avatar_url"].stringValue, userName: subJson["actor"]["name"].stringValue, userAccount: subJson["actor"]["login"].stringValue)
                        }else{
                            userInfo = UserItemModel(id: 0, userHead: "", userName: "Gitee", userAccount: "hamm")
                        }
                        let repoInfo = NotificationRepoModel(id: subJson["repository"]["id"].intValue, fullName: subJson["repository"]["full_name"].stringValue, humanName: subJson["repository"]["human_name"].stringValue, namespace: RepoNamespace(id: subJson["repository"]["namespace"]["id"].intValue, name: subJson["repository"]["namespace"]["name"].stringValue, path: subJson["repository"]["namespace"]["path"].stringValue))
                        let notification = NotificationModel(id: subJson["id"].intValue, message: subJson["content"].stringValue, type: getNotificationType(str: subJson["type"].stringValue), isUnRead: subJson["unread"].boolValue, time: Helper.getDateFromString(str: subJson["updated_at"].stringValue), user: userInfo, repo: repoInfo)
                        tempList.append(notification)
                    }
                    self.notificationList = tempList
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

struct NotificationItemView:View{
    @State var notificationItem: NotificationModel
    @State var placeholderImage = UIImage(named: "Logo")!
    @State var isRepoDetailShow:Bool = false
    @State var isPullRequestShow:Bool = false
    @State var isCommitShow:Bool = false
    @State var isIssueShow:Bool = false
    var body: some View{
        ZStack{
            VStack{
                NavigationLink(destination: RepoDetailView(repoFullPath: self.notificationItem.repo.fullName), isActive: $isRepoDetailShow) { EmptyView() }
                NavigationLink(destination: PullRequestView(repoFullPath: self.notificationItem.repo.fullName), isActive: $isPullRequestShow) { EmptyView() }
                NavigationLink(destination: CommitView(repoFullPath: self.notificationItem.repo.fullName, repoDefaultBranch: "master"), isActive: $isCommitShow) { EmptyView() }
                NavigationLink(destination:  IssuesView(repoPath: self.notificationItem.repo.fullName), isActive: $isIssueShow) { EmptyView() }

            }
            .frame(width: 0, height: 0)
            .opacity(0)
            VStack{
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
                            guard let url = URL(string: notificationItem.user.userHead) else {
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
                            Text(notificationItem.user.userName)
                                .padding(0)
                            Spacer()
                            Text(notificationItem.time).font(.system(size:12)).foregroundColor(.gray)
                        }
                        Text(notificationItem.message).font(.system(size:14)).foregroundColor(.gray)
                            .padding(.top,1)
                            .lineLimit(10)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(10)
            }
            .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
            .cornerRadius(10)
            .padding(.horizontal,5)
            .padding(.bottom,-3)
            .onTapGesture {
            }
            .contextMenu(ContextMenu {
                Button(action: {
                    self.isRepoDetailShow = true
                }) {
                    HStack{
                        Image(systemName: "archivebox.circle").scaleEffect(1, anchor: .center)
                        Spacer()
                        Text("进入仓库")
                    }
                }
                Divider()
                Button(action: {
                    self.isCommitShow = true
                }) {
                    HStack{
                        Image(systemName: "icloud.and.arrow.up").scaleEffect(1, anchor: .center)
                        Spacer()
                        Text("查看提交")
                    }
                }
                Button(action: {
                    self.isPullRequestShow = true
                }) {
                    HStack{
                        Image(systemName: "shuffle.circle").scaleEffect(1, anchor: .center)
                        Spacer()
                        Text("查看Pull Request")
                    }
                }
                Button(action: {
                    self.isIssueShow = true
                }) {
                    HStack{
                        Image(systemName: "exclamationmark.circle").scaleEffect(1, anchor: .center)
                        Spacer()
                        Text("查看Issue")
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
}
