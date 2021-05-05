//
//  PullRequestView.swift
//  Gitee
//
//  Created by Hamm on 2021/4/20.
//

import SwiftUI
import SwiftyJSON
import SwipeCell

struct PullRequestView: View {
    @State var pullRequestList: [PullRequestModel] = []
    @State var repoFullPath:String
    @State var waitPlease = false
    @State var isRefreshing = false
    @State var isLoading: Bool = false
    @State var isModal: Bool = false
    @State var message: String = "数据加载中"
    @State var isFilterShow = false
    @State var page = 1
    var body: some View {
        LoadingView(isLoading:self.$isLoading,message: self.$message,isModal:self.$isModal) {
            ZStack{
                if pullRequestList.count == 0 && !isLoading {
                    VStack{
                        Image(systemName: "doc.text.magnifyingglass")
                            .scaleEffect(3, anchor: .center)
                        Text("暂无查询到的Pull Requests").padding(.top,30)
                    }
                }
                RefreshView(refreshing: $isRefreshing, action: {
                    self.page = 1
                    self.getPullRequestList(page: self.page)
                }) {
                    LazyVStack{
                        ForEach(self.pullRequestList){ item in
                            PullRequestItemView(pullRequestItem: item)
                                .onAppear(){
                                    if !waitPlease && item.id == pullRequestList[pullRequestList.count - 1].id {
                                        self.page = self.page + 1
                                        self.getPullRequestList(page: self.page)
                                    }
                                }
                        }
                    }
                }
            }
        }
        .navigationBarTitle(Text("Pull Requests"), displayMode: .inline)
        .navigationBarItems(trailing:
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
                                    self.getPullRequestList(page: self.page)
                                }){
                                    PullRequestFilterView()
                                        .modifier(DisableModalDismiss(disabled: false))
                                }
        )
        .onAppear(){
            localConfig.setValue("open", forKey: giteeConfig.pull_request_state)
            localConfig.setValue("updated", forKey: giteeConfig.pull_request_sort)
            localConfig.setValue("desc", forKey: giteeConfig.pull_request_direction)
            self.page = 1
            self.getPullRequestList( page: self.page)
        }
    }
    func getPullRequestList(page: Int){
        if self.waitPlease { return }
        self.waitPlease = true
        if pullRequestList.count == 0 {
            self.isLoading = true
        }
        let state = localConfig.string(forKey: giteeConfig.pull_request_state)
        let sort = localConfig.string(forKey: giteeConfig.pull_request_sort)
        let direction = localConfig.string(forKey: giteeConfig.pull_request_direction)
        var url = "repos/"
        url = url + self.repoFullPath + "/pulls?page=" + String(page);
        
        url = url + "&state=" + state!
        url = url + "&sort=" + sort!
        url = url + "&direction=" + direction!
        
        
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
                    var tempList = self.pullRequestList
                    if page == 1{
                        tempList = []
                    }
                    for (_,subJson):(String, JSON) in json {
                        let userInfo = UserItemModel(id: Int(subJson["user"]["id"].intValue), userHead: String(subJson["user"]["avatar_url"].stringValue), userName: String(subJson["user"]["name"].stringValue), userAccount: String(subJson["user"]["login"].stringValue))
                        
                        let fromRepo = RepoModel(id: Int(subJson["head"]["repo"]["id"].intValue), repoName: String(subJson["head"]["repo"]["name"].stringValue), repoPath: String(subJson["head"]["repo"]["path"].stringValue), repoNamespace: RepoNamespace(id: Int(subJson["head"]["repo"]["namespace"]["id"].intValue), name: String(subJson["head"]["repo"]["namespace"]["name"].stringValue), path: String(subJson["head"]["repo"]["namespace"]["path"].stringValue)), repoDesc: String(subJson["head"]["repo"]["description"].stringValue), repoForks: "", repoStars: "",repoWatches:"", repoLicense:"", repoLanguage: "", repoPushDate:"", repoIsFork: false, repoIsOpenSource: Bool(subJson["head"]["repo"]["public"].boolValue), repoIssues:"", repoDefaultBranch:"")
                        
                        let toRepo = RepoModel(id: Int(subJson["base"]["repo"]["id"].intValue), repoName: String(subJson["base"]["repo"]["name"].stringValue), repoPath: String(subJson["base"]["repo"]["path"].stringValue), repoNamespace: RepoNamespace(id: Int(subJson["base"]["repo"]["namespace"]["id"].intValue), name: String(subJson["base"]["repo"]["namespace"]["name"].stringValue), path: String(subJson["base"]["repo"]["namespace"]["path"].stringValue)), repoDesc: String(subJson["base"]["repo"]["description"].stringValue), repoForks: "", repoStars: "",repoWatches:"", repoLicense:"", repoLanguage: "", repoPushDate:"", repoIsFork: false, repoIsOpenSource: Bool(subJson["base"]["repo"]["public"].boolValue), repoIssues:"", repoDefaultBranch:"")
                        
                        tempList.append(PullRequestModel(id: Int(subJson["id"].intValue), prId: Int(subJson["number"].intValue), prStatus: getPullRequestStatus(status: String(subJson["state"].stringValue)), prTitle: String(subJson["title"].stringValue), prBody: String(subJson["body"].stringValue), prUser: userInfo, prFrom: fromRepo, prTo: toRepo, prTime: Helper.getDateFromString(str: String(subJson["updated_at"].stringValue)), prAuthMerge: Bool(subJson["mergeable"].boolValue),prFromBranch: String(subJson["head"]["ref"].stringValue),prToBranch: String(subJson["base"]["ref"].stringValue)))
                    }
                    self.pullRequestList = tempList
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
struct PullRequestItemView:View{
    @State var pullRequestItem: PullRequestModel
    @State var prFromToString:String = ""
    @State var prFromToString2:String = ""
    @State private var isActiveCommit:Bool = false
    @State private var isActivePullRequest:Bool = false
    var body: some View{
        VStack{
            VStack(alignment: .leading){
                HStack(alignment: .top) {
                    VStack{
                        Text(getPullRequestStatusStringShow(pullRequestItem:pullRequestItem))
                            .foregroundColor(getPullRequestColor(pullRequestItem:pullRequestItem))
                            .padding(.vertical,1)
                            .padding(.horizontal,3)
                    }
                    .font(.system(size: 12))
                    .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
                    .foregroundColor(.gray)
                    .cornerRadius(3)
                    VStack(alignment: .leading){
                        Text(self.pullRequestItem.prTitle)
                            .font(.system(size: 16))
                            .lineLimit(1)
                    }
                    .padding(.leading,0)
                    Spacer()
                    Text(self.pullRequestItem.prTime)
                        .padding(.vertical,1)
                        .padding(.horizontal,3)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .padding(5)
                HStack(alignment: .center){
                    Text(self.pullRequestItem.prBody)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .padding(.top,10)
                    Spacer()
                }
                HStack{
                    VStack(alignment: .leading){
                        Text(prFromToString)
                            .padding(.vertical,0)
                            .padding(.horizontal,3)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                        
                        Text(prFromToString2)
                            .padding(.vertical,0)
                            .padding(.horizontal,3)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    Spacer()
                }
            }
            .padding(10)
        }
        .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
        .cornerRadius(10)
        .padding(.horizontal,5)
        .sheet(isPresented: $isActivePullRequest,onDismiss: {
        }){
            PullRequestDetailView(pullRequestItem: $pullRequestItem).foregroundColor(.white)
        }
        .onTapGesture {
            self.isActivePullRequest = true
        }
        .contextMenu(ContextMenu {
            if pullRequestItem.prAutoMerge && pullRequestItem.prStatus == PullRequestStatus.open {
                Button(action: {
                }) {
                    HStack{
                        Image(systemName: "mail.and.text.magnifyingglass").scaleEffect(1, anchor: .center)
                        Spacer()
                        Text("审查通过")
                    }
                }
                Button(action: {
                }) {
                    HStack{
                        Image(systemName: "wrench.and.screwdriver").scaleEffect(1, anchor: .center)
                        Spacer()
                        Text("测试通过")
                    }
                }
                Button(action: {
                }) {
                    HStack{
                        Image(systemName: "shuffle").scaleEffect(1, anchor: .center)
                        Spacer()
                        Text("确认合并")
                    }
                }
            }
            Divider()
            Button(action: {
                self.isActiveCommit = true
            }) {
                HStack{
                    Image(systemName: "icloud.and.arrow.up").scaleEffect(1, anchor: .center)
                    Spacer()
                    Text("提交记录")
                }
            }
            .sheet(isPresented: $isActiveCommit,onDismiss: {
            }){
                CommitView(pullRequestItem: pullRequestItem).foregroundColor(.white)
            }
        })
        .onAppear(){
            if pullRequestItem.prFrom.repoNamespace.path == pullRequestItem.prTo.repoNamespace.path {
                self.prFromToString = "从 " + pullRequestItem.prFromBranch + "分支 到 " + pullRequestItem.prToBranch + "分支"
                self.prFromToString2 = "这是你的自己的合并请求"
            }else{
                self.prFromToString = "从 " + pullRequestItem.prFrom.repoNamespace.name + "/" + pullRequestItem.prFrom.repoName + ":" + pullRequestItem.prFromBranch
                self.prFromToString2 = "到 " + pullRequestItem.prTo.repoNamespace.name + "/" + pullRequestItem.prTo.repoName + ":" + pullRequestItem.prToBranch
            }
        }
    }
}
