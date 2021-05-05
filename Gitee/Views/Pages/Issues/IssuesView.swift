//
//  IssuesView.swift
//  Gitee
//
//  Created by Hamm on 2021/4/20.
//

import SwiftUI
import SwiftyJSON
import SwipeCell

struct IssuesView: View {
    @State var issuesList: [IssueModel] = []
    @State var waitPlease = false
    @State var isRefreshing = false
    @State var isLoading: Bool = false
    @State var isModal: Bool = false
    @State var message: String = "数据加载中"
    @State var isFilterShow = false
    @State var page = 1
    @State var repoPath: String = ""
    @State var title: String? = "Issues"
    @State var isInserIssueShow:Bool = false
    var body: some View {
        LoadingView(isLoading:self.$isLoading,message: self.$message,isModal:self.$isModal) {
            VStack{
                ZStack{
                    if issuesList.count == 0 && !isLoading {
                        VStack{
                            Image(systemName: "doc.text.magnifyingglass")
                                .scaleEffect(3, anchor: .center)
                            Text("暂无查询到的Issues").padding(.top,30)
                        }
                    }
                    RefreshView(refreshing: $isRefreshing, action: {
                        self.page = 1
                        self.getIssueList(page: self.page)
                    }) {
                        LazyVStack{
                            ForEach(self.issuesList){ item in
                                NavigationLink(destination: IssueItemView(issueItem: item)) {
                                    IssueItemView(issueItem: item)
                                        .onAppear(){
                                            if !waitPlease && item.id == issuesList[issuesList.count - 1].id {
                                                self.page = self.page + 1
                                                self.getIssueList(page: self.page)
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
                if self.repoPath != "" {
                    Spacer()
                    HStack{
                        Spacer()
                        Button {
                            self.isInserIssueShow = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .scaleEffect(1.2, anchor: .center)
                        }
                        .padding(12)
                        .background(Color.yellow)
                        .foregroundColor(Color.black)
                        .cornerRadius(100)
                        .sheet(isPresented: $isInserIssueShow) {
                            let arr = self.repoPath.components(separatedBy: "/")
                            IssueInsertView(repoNamespacePath: arr[0], repoPath: arr[1])
                        }
                    }
                    .padding(.trailing,20)
                }
            }
        }
        .padding(.top,5)
        .navigationBarTitle(Text(title!), displayMode: .inline)
        .navigationBarItems(
            trailing:
                HStack {
                    Button(action: {
                        self.isFilterShow.toggle()
                    }) {
                        Image(systemName: "rectangle.and.text.magnifyingglass")
                            
                            .scaleEffect(1, anchor: .center)
                    }
                }
                .sheet(isPresented: $isFilterShow,onDismiss: {
                    self.isLoading = true
                    self.page = 1
                    self.getIssueList(page: self.page)
                }){
                    IssueFilterView()
                        .modifier(DisableModalDismiss(disabled: false))
                }
        )
        .onAppear(){
            localConfig.setValue("all", forKey: giteeConfig.issue_filter)
            localConfig.setValue("open", forKey: giteeConfig.issue_state)
            localConfig.setValue("created", forKey: giteeConfig.issue_sort)
            localConfig.setValue("desc", forKey: giteeConfig.issue_direction)
            self.page = 1
            self.getIssueList(page: self.page)
        }
    }
    func getIssueList(page: Int){
        if self.waitPlease { return }
        self.waitPlease = true
        if issuesList.count == 0 {
            self.isLoading = true
        }
        let state = localConfig.string(forKey: giteeConfig.issue_state)
        let filter = localConfig.string(forKey: giteeConfig.issue_filter)
        let direction = localConfig.string(forKey: giteeConfig.issue_direction)
        let sort = localConfig.string(forKey: giteeConfig.issue_sort)
        var url = "user/issues?page=" + String(page)
        
        if self.repoPath != "" {
            url = "repos/" + self.repoPath + "/issues?page=" + String(page)
        }
        
        url = url + "&state=" + state!
        url = url + "&filter=" + filter!
        url = url + "&direction=" + direction!
        url = url + "&sort=" + sort!
        
        
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
                    var tempList = self.issuesList
                    if page == 1{
                        tempList = []
                    }
                    for (_,subJson):(String, JSON) in json {
                        let repoNamespace = RepoNamespace(id: Int(subJson["repository"]["namespace"]["id"].stringValue)!, name: String(subJson["repository"]["namespace"]["name"].stringValue), path:  String(subJson["repository"]["namespace"]["path"].stringValue))
                        let repoInfo = RepoModel(id: Int(subJson["repository"]["id"].stringValue)!, repoName: String(subJson["repository"]["name"].stringValue),repoPath:  String(subJson["repository"]["path"].stringValue),repoNamespace: repoNamespace, repoDesc:  String(subJson["repository"]["description"].stringValue), repoForks:  String(subJson["repository"]["forks_count"].stringValue), repoStars:  String(subJson["repository"]["stargazers_count"].stringValue), repoWatches:  String(subJson["repository"]["watchers_count"].stringValue), repoLicense:  String(subJson["repository"]["license"].stringValue), repoLanguage:  String(subJson["repository"]["language"].stringValue), repoPushDate:  String(subJson["repository"]["pushed_at"].stringValue), repoIsFork:  Bool(subJson["repository"]["fork"].boolValue), repoIsOpenSource:  Bool(subJson["repository"]["public"].boolValue), repoIssues:  String(subJson["repository"]["open_issues_count"].stringValue), repoDefaultBranch:  String(subJson["repository"]["default_branch"].stringValue))
                        let userInfo = UserItemModel(id: Int(subJson["user"]["id"].stringValue)!, userHead: String(subJson["user"]["avatar_url"].stringValue), userName: String(subJson["user"]["name"].stringValue), userAccount: String(subJson["user"]["login"].stringValue))
                        let issueInfo = IssueModel(id: Int(subJson["id"].stringValue)!, issueId: String(subJson["number"].stringValue), issueTitle: String(subJson["title"].stringValue), issueTime: Helper.getDateFromString(str: String(subJson["created_at"].stringValue)), issueDesc: String(subJson["body"].stringValue), issueStatus: getIssueStatus(status: subJson["state"].stringValue), repoInfo:repoInfo, userInfo: userInfo)
                        tempList.append(
                            issueInfo
                        )
                    }
                    self.issuesList = tempList
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

struct IssueItemView:View{
    @State var issueItem: IssueModel
    @State private var isActiveIsssueDetail:Bool = false
    @State private var isActiveRepoDetail:Bool = false
    var body: some View{
        ZStack{
            VStack{
                NavigationLink(destination: RepoDetailView(repoFullPath: issueItem.repoInfo.repoNamespace.path + "/" + issueItem.repoInfo.repoPath), isActive: $isActiveRepoDetail) { EmptyView() }
            }
            .frame(width: 0, height: 0)
            .opacity(0)
            VStack{
                VStack(alignment: .leading){
                    HStack(alignment: .top) {
                        Image(systemName:getIssueIcon(status: issueItem.issueStatus))
                            .scaleEffect(1, anchor: .center)
                            .foregroundColor(getIssueColor(status: issueItem.issueStatus))
                        VStack(alignment: .leading){
                            Text(issueItem.issueTitle)
                                .font(.system(size: 16))
                                .lineLimit(1)
                        }
                        Spacer()
                        Text(issueItem.issueTime)
                            .padding(.vertical,1)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                    }
                    .padding(5)
                    HStack{
                        Text(issueItem.repoInfo.repoName)
                            .padding(.leading,35)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: 0xCCCCCC))
                        Text(issueItem.issueDesc)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    HStack{
                        Image(systemName:"person.circle")
                            .scaleEffect(0.7, anchor: .center)
                            .foregroundColor(.gray)
                            .padding(.leading,30)
                        Text(issueItem.userInfo.userName)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(.leading,-8)
                        Spacer()
                    }
                    .padding(.top,5)
                }
                .padding(10)
            }
            .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
            .cornerRadius(10)
            .padding(.horizontal,5)
            .padding(.bottom,-3)
            .sheet(isPresented: self.$isActiveIsssueDetail) {
                self.reloadIssue()
            } content: {
                IssuesDetailView(issueItem: $issueItem)
                    .foregroundColor(.white)
            }
            .onTapGesture {
                self.isActiveIsssueDetail = true
            }
            .contextMenu(ContextMenu {
                if issueItem.issueStatus != IssueStatus.open {
                    Button(action: {
                        self.changeIssueStatus(issueItem: issueItem,  issueStatus: IssueStatus.open)
                    }) {
                        HStack{
                            Image(systemName: "moon.circle").scaleEffect(1, anchor: .center)
                            Spacer()
                            Text("标记为已开启")
                        }
                    }
                }
                if issueItem.issueStatus != IssueStatus.progressing {
                    Button(action: {
                        self.changeIssueStatus(issueItem: issueItem,  issueStatus: IssueStatus.progressing)
                    }) {
                        HStack{
                            Image(systemName: "timer").scaleEffect(1, anchor: .center)
                            Spacer()
                            Text("标记为进行中")
                        }
                    }
                }
                if issueItem.issueStatus != IssueStatus.rejected {
                    Button(action: {
                        UIAlertController.alert(message: "请期待Gitee开放这个API吧~", title: "即将上线", confirmText: "安排")
                    }) {
                        HStack{
                            Image(systemName: "xmark.circle").scaleEffect(1, anchor: .center)
                            Spacer()
                            Text("标记为已拒绝")
                        }
                    }
                }
                if issueItem.issueStatus != IssueStatus.closed {
                    Button(action: {
                        self.changeIssueStatus(issueItem: issueItem, issueStatus: IssueStatus.closed)
                    }) {
                        HStack{
                            Image(systemName: "checkmark.circle").scaleEffect(1, anchor: .center)
                            Spacer()
                            Text("标记为完成")
                        }
                    }
                }
                Divider()
                Button(action: {
                    self.isActiveRepoDetail = true
                }) {
                    HStack{
                        Image(systemName: "archivebox.circle").scaleEffect(1, anchor: .center)
                        Spacer()
                        Text("进入所属仓库")
                    }
                }
            })
        }
    }
    
    func reloadIssue(){
        let url = "repos/" + self.issueItem.repoInfo.repoNamespace.path + "/" + self.issueItem.repoInfo.repoPath + "/issues/" + self.issueItem.issueId
        HttpRequest(url: url, withAccessToken: true)
            .doGet { (value) in
                let subJson = JSON(value)
                print(subJson)
                if subJson["message"].string != nil {
                    print("error")
                }else{
                    let repoNamespace = RepoNamespace(id: Int(subJson["repository"]["namespace"]["id"].stringValue)!, name: String(subJson["repository"]["namespace"]["name"].stringValue), path:  String(subJson["repository"]["namespace"]["path"].stringValue))
                    let repoInfo = RepoModel(id: Int(subJson["repository"]["id"].stringValue)!, repoName: String(subJson["repository"]["name"].stringValue),repoPath:  String(subJson["repository"]["path"].stringValue),repoNamespace: repoNamespace, repoDesc:  String(subJson["repository"]["description"].stringValue), repoForks:  String(subJson["repository"]["forks_count"].stringValue), repoStars:  String(subJson["repository"]["stargazers_count"].stringValue), repoWatches:  String(subJson["repository"]["watchers_count"].stringValue), repoLicense:  String(subJson["repository"]["license"].stringValue), repoLanguage:  String(subJson["repository"]["language"].stringValue), repoPushDate:  String(subJson["repository"]["pushed_at"].stringValue), repoIsFork:  Bool(subJson["repository"]["fork"].boolValue), repoIsOpenSource:  Bool(subJson["repository"]["public"].boolValue), repoIssues:  String(subJson["repository"]["open_issues_count"].stringValue), repoDefaultBranch:  String(subJson["repository"]["default_branch"].stringValue))
                    let userInfo = UserItemModel(id: Int(subJson["user"]["id"].stringValue)!, userHead: String(subJson["user"]["avatar_url"].stringValue), userName: String(subJson["user"]["name"].stringValue), userAccount: String(subJson["user"]["login"].stringValue))
                    let issueInfo = IssueModel(id: Int(subJson["id"].stringValue)!, issueId: String(subJson["number"].stringValue), issueTitle: String(subJson["title"].stringValue), issueTime: Helper.getDateFromString(str: String(subJson["created_at"].stringValue)), issueDesc: String(subJson["body"].stringValue), issueStatus: getIssueStatus(status: subJson["state"].stringValue), repoInfo:repoInfo, userInfo: userInfo)
                    
                    self.issueItem = issueInfo
                }
            } errorCallback: {
                
            }
    }
    func changeIssueStatus(issueItem:IssueModel,issueStatus:IssueStatus){
        let status = getIssueStatusString(status: issueStatus)
        let url = "repos/" + issueItem.repoInfo.repoNamespace.path + "/issues/" + issueItem.issueId
        HttpRequest(url: url,withAccessToken: true).doPatch(postData: ["state":status,"repo":issueItem.repoInfo.repoPath]) { (result) in
            let json = JSON(result)
            let repoNamespace = RepoNamespace(id: Int(json["repository"]["namespace"]["id"].stringValue)!, name: String(json["repository"]["namespace"]["name"].stringValue), path:  String(json["repository"]["namespace"]["path"].stringValue))
            let repoInfo = RepoModel(id: Int(json["repository"]["id"].stringValue)!, repoName: String(json["repository"]["name"].stringValue),repoPath:  String(json["repository"]["path"].stringValue),repoNamespace: repoNamespace, repoDesc:  String(json["repository"]["description"].stringValue), repoForks:  String(json["repository"]["forks_count"].stringValue), repoStars:  String(json["repository"]["stargazers_count"].stringValue), repoWatches:  String(json["repository"]["watchers_count"].stringValue), repoLicense:  String(json["repository"]["license"].stringValue), repoLanguage:  String(json["repository"]["language"].stringValue), repoPushDate:  String(json["repository"]["pushed_at"].stringValue), repoIsFork:  Bool(json["repository"]["fork"].boolValue), repoIsOpenSource:  Bool(json["repository"]["public"].boolValue), repoIssues:  String(json["repository"]["open_issues_count"].stringValue), repoDefaultBranch:  String(json["repository"]["default_branch"].stringValue))
            let userInfo = UserItemModel(id: Int(json["user"]["id"].stringValue)!, userHead: String(json["user"]["avatar_url"].stringValue), userName: String(json["user"]["name"].stringValue), userAccount: String(json["user"]["login"].stringValue))
            
            let issueInfo = IssueModel(id: Int(json["id"].stringValue)!, issueId: String(json["number"].stringValue), issueTitle: String(json["title"].stringValue), issueTime: Helper.getDateFromString(str: String(json["created_at"].stringValue)), issueDesc: String(json["body"].stringValue), issueStatus: getIssueStatus(status: json["state"].stringValue), repoInfo:repoInfo, userInfo: userInfo)
            
            self.issueItem = issueInfo
        } errorCallback: {
            print("error")
        }
    }
}
