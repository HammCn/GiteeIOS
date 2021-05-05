//
//  CommitView.swift
//  Gitee
//
//  Created by Hamm on 2021/4/28.
//

import Foundation
import SwiftUI
import SwiftyJSON
import SwipeCell

struct CommitView: View {
    @State var commitList: [CommitModel] = []
    private var repoFullPath:String?
    private var repoDefaultBranch:String?
    private var pullRequestItem:PullRequestModel?
    @State var waitPlease = false
    @State var isRefreshing = false
    @State var isLoading: Bool = false
    @State var isModal: Bool = false
    @State var message: String = "数据加载中"
    @State var isFilterShow = false
    @State var isLoginShow = false
    @State var page = 1
    @State var branch = "master"
    @State var branchList:[String] = []
    private var showCommitFrom: CommitFromModel
    init(pullRequestItem:PullRequestModel){
        self.pullRequestItem = pullRequestItem
        self.repoFullPath = pullRequestItem.prTo.repoNamespace.path + "/" + pullRequestItem.prTo.repoPath
        self.showCommitFrom = CommitFromModel.fromPullRequest
    }
    init(repoFullPath:String,repoDefaultBranch:String?){
        self.repoFullPath = repoFullPath
        if repoDefaultBranch != nil {
            self.repoDefaultBranch = repoDefaultBranch
        }else{
            self.repoDefaultBranch = "master"
        }
        self.showCommitFrom = CommitFromModel.fromRepo
    }
    var body: some View {
        LoadingView(isLoading:self.$isLoading,message: self.$message,isModal:self.$isModal) {
            ZStack{
                if commitList.count == 0 && !isLoading {
                    VStack{
                        Image(systemName: "doc.text.magnifyingglass")
                            .scaleEffect(3, anchor: .center)
                        Text("暂无查询到的提交").padding(.top,30)
                    }
                }
                RefreshView(refreshing: $isRefreshing, action: {
                    self.page = 1
                    self.getCommitList(page: self.page)
                }) {
                    LazyVStack{
                        ForEach(self.commitList){ item in
                            CommitItemView(commitItem: item, repoFullPath: self.repoFullPath!)
                                .onAppear(){
                                    if !waitPlease && item.id == commitList[commitList.count - 1].id {
                                        self.page = self.page + 1
                                        self.getCommitList(page: self.page)
                                    }
                                }
                        }
                    }
                }
            }
            .padding(.top,5)
            .navigationBarTitle(Text(self.showCommitFrom == CommitFromModel.fromRepo ? branch : "包含的提交"), displayMode: .inline)
            .navigationBarItems(
                trailing:
                    HStack {
                        if self.showCommitFrom == CommitFromModel.fromRepo{
                            Button {
                            } label: {
                                Menu {
                                    ForEach (0 ..< self.branchList.count, id: \.self) {index in
                                        Button(self.branchList[index], action: {
                                            self.branch = self.branchList[index]
                                            self.page = 1
                                            self.isLoading = true
                                            self.getCommitList(page: self.page)
                                        })
                                    }
                                } label: {
                                    VStack{
                                        Text("分支").foregroundColor(.yellow)
                                    }
                                }
                            }
                        }
                    }
            )
            .onAppear(){
                if self.showCommitFrom == CommitFromModel.fromRepo{
                    self.branch = self.repoDefaultBranch!
                }else{
                    self.branch = "master"
                }
                self.page = 1
                self.getCommitList( page: self.page)
                self.getBranchList()
            }
        }
    }
    func getCommitList(page: Int){
        if self.waitPlease { return }
        self.waitPlease = true
        if commitList.count == 0 {
            self.isLoading = true
        }
        var url = "repos/"
        if self.showCommitFrom == CommitFromModel.fromRepo{
            url = url + self.repoFullPath! + "/commits?page=" + String(page)
            url = url + "&sha=" + self.branch
        }else if self.showCommitFrom == CommitFromModel.fromPullRequest{
            url = url + (self.pullRequestItem?.prTo.repoNamespace.path)! + "/"
            url = url + (self.pullRequestItem?.prTo.repoPath)! + "/pulls/"
            url = url + String(self.pullRequestItem!.prId) + "/commits";
        }
        
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
                    var tempList = self.commitList
                    if page == 1{
                        tempList = []
                    }
                    for (_,subJson):(String, JSON) in json {
                        let author = subJson["commit"]["author"]["name"].stringValue
                        let userInfo = UserItemModel(id: Int(subJson["author"]["id"].intValue), userHead: String(subJson["author"]["avatar_url"].stringValue), userName: String(subJson["author"]["name"].stringValue), userAccount: String(subJson["author"]["login"].stringValue))
                        tempList.append(CommitModel(id: subJson["sha"].stringValue, sha: String(subJson["sha"].stringValue), author: author, commitTime: String(subJson["commit"]["author"]["date"].stringValue), message: String(subJson["commit"]["message"].stringValue), addCount:  String(subJson["stats"]["additions"].stringValue), deleteCount: String(subJson["stats"]["deletions"].stringValue), totalCount: String(subJson["stats"]["total"].stringValue), user: userInfo))
                    }
                    self.commitList = tempList
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
    func getBranchList(){
        var url = "repos/"
        url = url + self.repoFullPath! + "/branches";
        HttpRequest(url: url, withAccessToken: true)
            .doGet { (value) in
                let json = JSON(value)
                if json["message"].string != nil {
                    DispatchQueue.main.async {
                        UIAlertController.confirm(message: json["message"].stringValue, title: "发生错误", confirmText: "重新登录", cancelText: "返回") { (action) in
                            Helper.relogin()
                        }
                    }
                }else{
                    if page == 1{
                        branchList = []
                    }
                    for (_,subJson):(String, JSON) in json {
                        branchList.append(subJson["name"].stringValue)
                    }
                }
            } errorCallback: {
                
            }
    }
}
struct CommitItemView:View{
    @State var commitItem: CommitModel
    @State var repoFullPath: String
    @State var userHead:UIImage? = nil
    let placeholderImage = UIImage(named: "nohead")!
    @State var isCommitChangeShow: Bool = false
    var body: some View{
        VStack{
            VStack(alignment: .leading){
                VStack(alignment: .leading){
                    HStack(alignment: .top) {
                        Image(uiImage: self.userHead ?? placeholderImage)
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width:20,height:20,
                                alignment: .center
                            )
                            .cornerRadius(5)
                            .onAppear(){
                                guard let url = URL(string: commitItem.user.userHead) else {
                                    return
                                }
                                URLSession.shared.dataTask(with: url) { (data, response, error) in
                                    if let data = data, let image = UIImage(data: data) {
                                        self.userHead = image
                                    }
                                }.resume()
                            }
                        VStack(alignment: .leading){
                            Text(commitItem.message)
                                .font(.system(size: 16))
                                .lineLimit(1)
                        }
                        Spacer()
                        Text("+" + commitItem.addCount).foregroundColor(.green).font(.system(size:14)).fontWeight(.bold).padding(.leading,0)
                        Text("-" + commitItem.deleteCount).foregroundColor(.red).font(.system(size:14)).fontWeight(.bold).padding(.leading,0)
                        
                    }
                }
                .padding(.vertical,5)
                HStack{
                    Text(Helper.getDateFromString(str: commitItem.commitTime)).font(.system(size:14)).foregroundColor(.gray)
                    Text("由 ").font(.system(size:14)).foregroundColor(.gray).padding(.leading,-5)
                    Text(commitItem.author + "(" + commitItem.user.userAccount + ")").font(.system(size:14)).foregroundColor(Color(hex: 0xaaaaaa)).padding(.leading,0).padding(.leading,-5)
                    Text(" 提交").font(.system(size:14)).foregroundColor(.gray).padding(.leading,0).padding(.leading,-5)
                    Spacer()
                }
            }
            .padding(10)
        }
        .onTapGesture {
            self.isCommitChangeShow = true
        }
        .sheet(isPresented: $isCommitChangeShow,onDismiss: {
            
        }){
            CommitChangesView(sha: self.commitItem.sha, repoFullPath:
                                self.repoFullPath)
        }
        .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
        .cornerRadius(10)
        .padding(.horizontal,5)
        .padding(.bottom,-5)
    }
}
