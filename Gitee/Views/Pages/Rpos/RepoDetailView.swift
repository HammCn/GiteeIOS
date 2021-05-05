//
//  RepoDetailView.swift
//  Gitee
//
//  Created by Hamm on 2021/4/23.
//

import SwiftUI
import SwiftyJSON
import UIKit
import MDText

struct RepoDetailView: View {
    @State var size:CGSize = .zero
    @State var isLoading: Bool = false
    @State var isModal: Bool = false
    @State var message: String = "数据加载中"
    @State var repoItem: RepoModel?
    @State var repoReadme = ""
    @State var repoIsStarred:Bool = false
    @State var repoIsWatched:Bool = false
    @State var isLoginShow = false
    @State var isIssueInsertShow = false
    @State var repoFullPath: String
    var body: some View {
        LoadingView(isLoading:self.$isLoading,message: self.$message,isModal:self.$isModal) {
            VStack{
                if self.repoItem != nil {
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack{
                            RepoDetailInfoView(repoItem: self.repoItem!)
                            HStack{
                                NavigationLink(destination: UserStarsView(repoPath: self.repoFullPath)) {
                                    VStack{
                                        Text(self.repoItem!.repoStars).font(.system(size:20))
                                            .fontWeight(.bold)
                                        Text("Stars").foregroundColor(Color(hex: 0x999999)).font(.system(size:12))
                                    }
                                }
                                Spacer()
                                NavigationLink(destination: UserWatchesView(repoPath:self.repoFullPath)) {
                                    VStack{
                                        Text(self.repoItem!.repoWatches).font(.system(size:20))
                                            .fontWeight(.bold)
                                        Text("Watches").foregroundColor(Color(hex: 0x999999)).font(.system(size:12))
                                    }
                                }
                                Spacer()
                                NavigationLink(destination: UserForksView(repoPath:self.repoFullPath)) {
                                    VStack{
                                        Text(self.repoItem!.repoForks).font(.system(size:20))
                                            .fontWeight(.bold)
                                        Text("Forks").foregroundColor(Color(hex: 0x999999)).font(.system(size:12))
                                    }
                                }
                                Spacer()
                                NavigationLink(destination: IssuesView(repoPath:self.repoFullPath)) {
                                    VStack{
                                        Text(self.repoItem!.repoIssues).font(.system(size:20))
                                            .fontWeight(.bold)
                                        Text("Issues").foregroundColor(Color(hex: 0x999999)).font(.system(size:12))
                                    }
                                }
                            }
                            .padding(.top,10)
                            .padding(.horizontal,20)
                            .padding(.bottom,20)
                        }
                        .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
                        .cornerRadius(10)
                        .padding(5)
                        
                        VStack{
                            VStack{
                                NavigationLink(destination: SettingQrcode(userAccount: "hamm")) {
                                    HStack{
                                        Text("代码").font(.system(size:16))
                                        Spacer()
                                        HStack{
                                            //                                            Text("master").font(.system(size:14))
                                            Image(systemName: "chevron.forward")
                                        }
                                        .foregroundColor(.gray)
                                    }
                                    .padding(.vertical,12)
                                    .padding(.leading,20)
                                    .padding(.trailing,10)
                                }
                                Divider().background(Color(hex: 0x111111))
                                NavigationLink(destination: CommitView(repoFullPath: self.repoItem!.repoNamespace.path + "/" + self.repoItem!.repoPath,repoDefaultBranch: self.repoItem!.repoDefaultBranch)) {
                                    HStack{
                                        Text("提交").font(.system(size:16))
                                        Spacer()
                                        HStack{
                                            Text(self.repoItem!.repoPushDate).font(.system(size:14))
                                            Image(systemName: "chevron.forward")
                                        }
                                        .foregroundColor(.gray)
                                    }
                                    .padding(.vertical,12)
                                    .padding(.leading,20)
                                    .padding(.trailing,10)
                                }
                                NavigationLink(destination: PullRequestView(repoFullPath: self.repoItem!.repoNamespace.path + "/" + self.repoItem!.repoPath)) {
                                    HStack{
                                        Text("Pull Requests").font(.system(size:16))
                                        Spacer()
                                        HStack{
                                            Image(systemName: "chevron.forward")
                                        }
                                        .foregroundColor(.gray)
                                    }
                                    .padding(.vertical,12)
                                    .padding(.leading,20)
                                    .padding(.trailing,10)
                                }
                                Divider().background(Color(hex: 0x111111))
                                NavigationLink(destination: RepoMembersView(repoPath:self.repoFullPath)) {
                                    HStack{
                                        Text("仓库成员").font(.system(size:16))
                                        Spacer()
                                        HStack{
                                            Image(systemName: "chevron.forward")
                                        }
                                        .foregroundColor(.gray)
                                    }
                                    .padding(.vertical,12)
                                    .padding(.leading,20)
                                    .padding(.trailing,10)
                                }
                            }
                            .padding(.vertical,10)
                        }
                        .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
                        .cornerRadius(10)
                        .padding(.horizontal,5)
                        .padding(.vertical,-10)
                        
                        if repoReadme != "" {
                            VStack(alignment: .leading){
                                VStack{
                                    MDText(markdown: repoReadme).padding()
                                }
                                .padding(.top,5)
                                .padding(.horizontal,5)
                                .padding(.bottom,10)
                            }
                            .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
                            .cornerRadius(10)
                            .padding(5)
                        }
                    }
                }
                Spacer()
                VStack{
                    HStack(alignment: .center){
                        Button {
                            let url = "user/starred/" + self.repoFullPath
                            self.isLoading = true
                            self.message = "Loading"
                            if repoIsStarred {
                                HttpRequest(url: url,withAccessToken: true).doDelete(postData: ["a":"b"]) { (result) in
                                    self.isLoading = false
                                    self.getRepoInfo()
                                    getIsStarred()
                                } errorCallback: {
                                    self.isLoading = false
                                    getIsStarred()
                                }
                            }else{
                                HttpRequest(url: url,withAccessToken: true).doPut(postData: ["a":"b"]) { (result) in
                                    self.isLoading = false
                                    self.getRepoInfo()
                                    getIsStarred()
                                } errorCallback: {
                                    self.isLoading = false
                                    getIsStarred()
                                }
                            }
                        } label: {
                            VStack(alignment: .center){
                                Image(systemName: "star")
                                    .scaleEffect(1.2, anchor: .center)
                                    .padding(.bottom,5).foregroundColor(repoIsStarred ? .yellow : .gray)
                                Text(repoIsStarred ? "Starred" : "Star").font(.system(size:12)).foregroundColor(repoIsStarred ? .yellow : .gray)
                            }
                            .frame(width: 60)
                        }
                        Spacer()
                        Button {
                            let url = "user/subscriptions/" + self.repoFullPath
                            self.isLoading = true
                            self.message = "Loading"
                            if repoIsWatched {
                                HttpRequest(url: url,withAccessToken: true).doDelete(postData: ["a":"b"]) { (result) in
                                    self.isLoading = false
                                    self.getRepoInfo()
                                    getIsWatched()
                                } errorCallback: {
                                    self.isLoading = false
                                    getIsWatched()
                                }
                            }else{
                                HttpRequest(url: url,withAccessToken: true).doPut(postData: ["watch_type":"watching"]) { (result) in
                                    self.isLoading = false
                                    self.getRepoInfo()
                                    getIsWatched()
                                } errorCallback: {
                                    self.isLoading = false
                                    getIsWatched()
                                }
                            }
                        } label: {
                            VStack(alignment: .center){
                                Image(systemName: "eye")
                                    .scaleEffect(1.2, anchor: .center)
                                    .padding(.bottom,5).foregroundColor(repoIsWatched ? .yellow : .gray)
                                Text(repoIsWatched ? "Watched" : "Watch").font(.system(size:12)).foregroundColor(repoIsWatched ? .yellow : .gray)
                            }
                            .frame(width: 60)
                        }
                        Spacer()
                        Button {
                            UIAlertController.confirm(message: "是否确认Fork这个仓库到你个人仓库？", title:"Fork仓库提醒", confirmText: "确认Fork", cancelText: "取消") { (action) in
                                let url = "repos/" + self.repoFullPath + "/forks"
                                self.isLoading = true
                                self.message = "Loading"
                                HttpRequest(url: url,withAccessToken: true).doPost(postData: ["a":"b"]) { (result) in
                                    let json = JSON(result)
                                    if json["message"].string != nil{
                                        DispatchQueue.main.async{
                                            UIAlertController.alert(message: json["message"].string!, title: "Fork失败", confirmText: "好吧")
                                        }
                                    }else{
                                        DispatchQueue.main.async{
                                            UIAlertController.alert(message: "你已经成功将该仓库Fork到自己仓库", title: "Fork成功", confirmText: "好吧")
                                        }
                                    }
                                    self.isLoading = false
                                } errorCallback: {
                                    self.isLoading = false
                                }
                            }
                        } label: {
                            VStack(alignment: .center){
                                Image(systemName: "arrowshape.turn.up.backward.2.fill")
                                    .scaleEffect(1.2, anchor: .center)
                                    .padding(.bottom,5).foregroundColor(.gray)
                                Text("Fork").font(.system(size:12)).foregroundColor(.gray)
                            }
                            .frame(width: 60)
                        }
                        Spacer()
                        Button {
                            self.isIssueInsertShow.toggle()
                        } label: {
                            VStack(alignment: .center){
                                Image(systemName: "exclamationmark.circle.fill")
                                    .scaleEffect(1.2, anchor: .center)
                                    .padding(.bottom,5).foregroundColor(.gray)
                                Text("Issue").font(.system(size:12)).foregroundColor(.gray)
                            }
                            .frame(width: 60)
                            .sheet(isPresented: $isIssueInsertShow,onDismiss: {
                                self.getRepoInfo()
                            }){
                                IssueInsertView(repoNamespacePath: self.repoItem!.repoNamespace.path, repoPath: self.repoItem!.repoPath)
                            }
                        }
                    }
                    .padding(.vertical,20)
                    .padding(.horizontal,30)
                    .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal,5)
            }}
            .onAppear(){
                self.getRepoInfo()
                self.getRepoReadme()
                self.getIsStarred()
                self.getIsWatched()
            }
            .preferredColorScheme(.dark)
            .navigationBarTitle(Text("仓库主页"), displayMode: .inline)
            .navigationBarItems(
                trailing:
                    HStack {
                        Button(action: {
                            //                                            self.isFilterShow.toggle()
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                
                                .scaleEffect(1, anchor: .center)
                        }
                    })
        
    }
    func getRepoInfo(){
        let url = "repos/" +  self.repoFullPath
        print(url)
        HttpRequest(url: url,withAccessToken: true).doGet { (result) in
            let json = JSON(result)
            print(json)
            if json["message"].string == nil{
                let repoNamespace = RepoNamespace(id: Int(json["namespace"]["id"].stringValue)!, name: String(json["namespace"]["name"].stringValue), path: String(json["namespace"]["path"].stringValue))
                let repoItem = RepoModel(id: Int(json["id"].int!) , repoName:  String(json["name"].stringValue), repoPath:   String(json["path"].stringValue), repoNamespace: repoNamespace, repoDesc: String(json["description"].stringValue), repoForks: String(json["forks_count"].stringValue), repoStars: String(json["stargazers_count"].stringValue), repoWatches: String(json["watchers_count"].stringValue), repoLicense: String(json["license"].stringValue), repoLanguage: String(json["language"].stringValue), repoPushDate: Helper.getDateFromString(str: String(json["pushed_at"].stringValue)), repoIsFork: json["fork"].bool ?? false, repoIsOpenSource: json["public"].bool ?? false,repoIssues: String(json["open_issues_count"].stringValue),repoDefaultBranch:  String(json["default_branch"].stringValue))
                self.repoItem = repoItem
            }
        } errorCallback: {
        }
    }
    func getIsWatched(){
        let url = "user/subscriptions/" +  self.repoFullPath
        HttpRequest(url: url,withAccessToken: true).doGet { (result) in
            let json = JSON(result)
            if json["message"].stringValue != ""{
                self.repoIsWatched = false
            }else{
                self.repoIsWatched = true
            }
        } errorCallback: {
            self.repoIsWatched = false
        }
    }
    func getIsStarred(){
        let url = "user/starred/" + self.repoFullPath
        HttpRequest(url: url,withAccessToken: true).doGet { (result) in
            let json = JSON(result)
            if json["message"].stringValue != ""{
                self.repoIsStarred = false
            }else{
                self.repoIsStarred = true
            }
        } errorCallback: {
            self.repoIsStarred = false
        }
    }
    func getRepoReadme(){
        self.isLoading = true
        self.message = "Load ReadMe"
        let url = "repos/" +  self.repoFullPath + "/readme"
        HttpRequest(url: url,withAccessToken: true).doGet { (result) in
            let json = JSON(result)
            if json["content"].stringValue != "" {
                self.repoReadme = Helper.base64Decoding(encodedString: String(json["content"].stringValue))
                self.isLoading = false
            }else{
                self.isLoading = false
            }
        } errorCallback: {
            self.repoReadme = ""
            self.isLoading = false
        }
    }
}

struct RepoDetailInfoView:View {
    @State var repoItem:RepoModel
    var body: some View {
        VStack(alignment: .leading){
            HStack(alignment: .top) {
                if !self.repoItem.repoIsOpenSource {
                    Image(systemName: "lock.square.fill")
                        .foregroundColor(Color(hex: 0xffc55a))
                        .padding(.trailing,-5)
                        .scaleEffect(1, anchor: .center)
                }
                VStack(alignment: .leading){
                    Text(self.repoItem.repoName)
                        .font(.system(size: 18))
                        .lineLimit(1)
                }
                Spacer()
            }
            .padding(5)
            Text(self.repoItem.repoDesc == "" ? "很尴尬,该项目暂无介绍..." : self.repoItem.repoDesc)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
                .padding(.top,10)
                .padding(.leading,5)
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
            }
            .padding(.top,10)
        }
        .padding(10)
    }
}
