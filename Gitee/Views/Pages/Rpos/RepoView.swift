//
//  RepoView.swift
//  Gitee
//
//  Created by Hamm on 2021/4/19.
//

import SwiftUI
import SwiftyJSON
import SwipeCell


struct RepoView: View {
    @State var repoList: [RepoModel] = []
    @State var waitPlease = false
    @State var isRefreshing = false
    @State var isLoading: Bool = false
    @State var isModal: Bool = false
    @State var message: String = "数据加载中"
    @State var isFilterShow = false
    @State var isLoginShow = false
    @State var page = 1
    var body: some View {
        LoadingView(isLoading:self.$isLoading,message: self.$message,isModal:self.$isModal) {
            ZStack{
                if repoList.count == 0 && !isLoading {
                    VStack{
                        Image(systemName: "doc.text.magnifyingglass")
                            .scaleEffect(3, anchor: .center)
                        Text("暂无查询到的仓库").padding(.top,30)
                    }
                }
                RefreshView(refreshing: $isRefreshing, action: {
                    self.page = 1
                    self.getRepoList(page: self.page)
                }) {
                    LazyVStack{
                        ForEach(self.repoList){ item in
                            NavigationLink(destination: RepoDetailView(repoFullPath: item.repoNamespace.path + "/" + item.repoPath)) {
                                RepoItemView(repoItem: item)
                                    .onAppear(){
                                        if !waitPlease && item.id == repoList[repoList.count - 1].id {
                                            self.page = self.page + 1
                                            self.getRepoList(page: self.page)
                                        }
                                    }
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isLoginShow,onDismiss: {
            UserModel().getMyInfo { (userInfo) in
                self.page = 1
                self.getRepoList(page: self.page)
            } error: {
                self.isLoginShow.toggle()
            }
        }){
            LoginView()
                .modifier(DisableModalDismiss(disabled: true))
        }
        .padding(.top,5)
        .navigationBarTitle(Text("代码仓库"), displayMode: .inline)
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
                    self.getRepoList(page: self.page)
                }){
                    RepoFilterView()
                        .modifier(DisableModalDismiss(disabled: false))
                }
        )
        .onAppear(){
            localConfig.setValue("all", forKey: giteeConfig.repo_type)
            localConfig.setValue("pushed", forKey: giteeConfig.repo_sort)
            localConfig.setValue("desc", forKey: giteeConfig.repo_direction)
            self.page = 1
            self.getRepoList( page: self.page)
            print("activity onappear")
        }
    }
    func getRepoList(page: Int){
        if self.waitPlease { return }
        self.waitPlease = true
        if repoList.count == 0 {
            self.isLoading = true
        }
        let type = localConfig.string(forKey: giteeConfig.repo_type)
        let direction = localConfig.string(forKey: giteeConfig.repo_direction)
        let sort = localConfig.string(forKey: giteeConfig.repo_sort)
        var url = "user/repos?page=" + String(page);
        
        url = url + "&type=" + type!
        url = url + "&direction=" + direction!
        url = url + "&sort=" + sort!
        
        HttpRequest(url: url, withAccessToken: true)
            .doGet { (value) in
                let json = JSON(value)
                if json["message"].string != nil {
                    print("error")
                    self.isLoginShow.toggle()
                }else{
                    var tempList = repoList
                    if page == 1{
                        tempList = []
                    }
                    for (_,subJson):(String, JSON) in json {
                        let repoNamespace = RepoNamespace(id: Int(subJson["namespace"]["id"].stringValue)!, name: String(subJson["namespace"]["name"].stringValue), path: String(subJson["namespace"]["path"].stringValue))
                        tempList.append(RepoModel(id: Int(subJson["id"].int!) , repoName:  String(subJson["name"].stringValue), repoPath:   String(subJson["path"].stringValue), repoNamespace: repoNamespace, repoDesc: String(subJson["description"].stringValue), repoForks: String(subJson["forks_count"].stringValue), repoStars: String(subJson["stargazers_count"].stringValue), repoWatches: String(subJson["watchers_count"].stringValue), repoLicense: String(subJson["license"].stringValue), repoLanguage: String(subJson["language"].stringValue), repoPushDate: Helper.getDateFromString(str: String(subJson["pushed_at"].stringValue)), repoIsFork: subJson["fork"].bool ?? false, repoIsOpenSource: subJson["public"].bool ?? false,repoIssues: String(subJson["open_issues_count"].stringValue),repoDefaultBranch:  String(subJson["default_branch"].stringValue)))
                    }
                    repoList = tempList
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

struct RepoItemView:View{
    @State var repoItem: RepoModel
    @State private var isActiveCommit:Bool = false
    @State private var isActivePullRequest:Bool = false
    @State private var isActiveIssues:Bool = false
    
    var body: some View{
        VStack{
            VStack{
                NavigationLink(destination: CommitView(repoFullPath: repoItem.repoNamespace.path + "/" + repoItem.repoPath,repoDefaultBranch: repoItem.repoDefaultBranch), isActive: $isActiveCommit) { EmptyView() }
                NavigationLink(destination: PullRequestView(repoFullPath: repoItem.repoNamespace.path + "/" + repoItem.repoPath), isActive: $isActivePullRequest) { EmptyView() }
                NavigationLink(destination: IssuesView(repoPath: repoItem.repoNamespace.path + "/" + repoItem.repoPath),isActive: $isActiveIssues) { EmptyView() }
            }
            .frame(width: 0, height: 0)
            .opacity(0)
            VStack(alignment: .leading){
                HStack(alignment: .top) {
                    if !self.repoItem.repoIsOpenSource {
                        Image(systemName: "lock.square.fill")
                            .foregroundColor(Color(hex: 0xffc55a))
                            .padding(.trailing,-5)
                            .scaleEffect(1, anchor: .center)
                    }
                    VStack(alignment: .leading){
                        Text(self.repoItem.repoNamespace.name + "/" + self.repoItem.repoName)
                            .font(.system(size: 16))
                            .lineLimit(1)
                    }
                    Spacer()
                    Text(self.repoItem.repoPushDate)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                }
                .padding(5)
                Text(self.repoItem.repoDesc == "" ? "很尴尬,该项目暂无介绍..." : self.repoItem.repoDesc)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .padding(.top,10)
                    .padding(.leading,5)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                HStack{
                    if self.repoItem.repoLanguage != "" {
                        VStack{
                            Text(self.repoItem.repoLanguage)
                                .padding(.vertical,1)
                                .padding(.horizontal,3)
                        }
                        .font(.system(size: 12))
                        .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
                        .foregroundColor(.gray)
                        .cornerRadius(3)
                    }
                    if self.repoItem.repoLicense != "" {
                        VStack{
                            Text(self.repoItem.repoLicense)
                                .padding(.vertical,1)
                                .padding(.horizontal,3)
                        }
                        .font(.system(size: 12))
                        .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
                        .foregroundColor(.gray)
                        .cornerRadius(3)
                    }
                    Spacer()
                    HStack{
                        Image(systemName: "star.fill")
                            .foregroundColor(.gray)
                            .scaleEffect(0.6, anchor: .center)
                            .padding(0)
                        Text(self.repoItem.repoStars)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(0)
                            .padding(.leading,-12)
                    }
                    HStack{
                        Image(systemName: "eye.fill")
                            .foregroundColor(.gray)
                            .scaleEffect(0.6, anchor: .center)
                            .padding(0)
                        Text(self.repoItem.repoWatches)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(0)
                            .padding(.leading,-12)
                    }
                    .padding(.horizontal,-8)
                    HStack{
                        Image(systemName: "arrowshape.turn.up.backward.2.fill")
                            .foregroundColor(.gray)
                            .scaleEffect(0.7, anchor: .center)
                            .padding(0)
                        Text(self.repoItem.repoForks)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(0)
                            .padding(.leading,-12)
                    }
                }
                .padding(.top,5)
            }
            .padding(10)
        }
        .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
        .cornerRadius(10)
        .padding(.horizontal,5)
        .padding(.bottom,5)
        //        .swipeCell(
        //            cellPosition: .both,
        //            leftSlot: nil,
        //            rightSlot: SwipeCellSlot(
        //                slots:
        //                    [
        //                        SwipeCellButton(
        //                            buttonStyle: .titleAndImage,
        //                            title: "Mark",
        //                            systemImage: "bookmark",
        //                            titleColor: .white,
        //                            imageColor: .white,
        //                            view: nil,
        //                            backgroundColor: .green,
        //                            action: {
        //                                print("123")
        //                            },
        //                            feedback:true
        //                        )
        //                    ]
        //            )
        //        )
        .contextMenu(ContextMenu {
            Button(action: {
                self.isActiveCommit = true
            }) {
                HStack{
                    Image(systemName: "icloud.and.arrow.up").scaleEffect(1, anchor: .center)
                    Spacer()
                    Text("提交记录")
                }
            }
            Divider()
            Button(action: {
                self.isActivePullRequest = true
            }) {
                HStack{
                    Image(systemName: "shuffle.circle").scaleEffect(1, anchor: .center)
                    Spacer()
                    Text("Pull Requests")
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
        })
    }
}
