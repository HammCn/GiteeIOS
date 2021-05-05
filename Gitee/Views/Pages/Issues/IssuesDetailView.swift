//
//  IssuesDetailView.swift
//  Gitee
//
//  Created by Hamm on 2021/4/27.
//

import SwiftUI
import SwiftyJSON
import UIKit
import MDText

struct IssuesDetailView: View {
    @Binding var issueItem: IssueModel
    @State var isLoading: Bool = false
    @State var isModal: Bool = false
    @State var message: String = "正在提交中"
    @State var isLoginShow = false
    @State var commentText:String = "";
    @State var userHead:UIImage? = nil
    let placeholderImage = UIImage(named: "nohead")!
    @State var issueCommentList:[IssueCommentModel] = []
    
    @State private var alertShow = false
    @State var alertTitle:String = ""
    @State var alertMessage:String = ""
    func startAlert(title:String,message:String){
        self.alertTitle = title
        self.alertMessage = message
        self.alertShow = true
    }
    
    var body: some View {
        LoadingView(isLoading:self.$isLoading,message: self.$message,isModal:self.$isModal) {
            NavigationView{
                VStack{
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading){
                            HStack(alignment: .top){
                                Image(uiImage: self.userHead ?? placeholderImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(
                                        width:50,height:50,
                                        alignment: .center
                                    )
                                    .cornerRadius(5)
                                VStack(alignment: .leading){
                                    Text(self.issueItem.userInfo.userName).foregroundColor(Color(hex: 0xFFFFFF))
                                        .padding(.bottom, 2).font(.system(size:18)).lineLimit(1)
                                    Text("发布于 " + self.issueItem.issueTime).foregroundColor(Color(hex: 0x999999)).lineLimit(2)
                                        .font(.system(size:14))
                                }
                                .padding(.horizontal, 5.0)
                                Spacer()
                                Image(systemName:getIssueIcon(status: issueItem.issueStatus))
                                    .scaleEffect(1, anchor: .center)
                                    .foregroundColor(getIssueColor(status: issueItem.issueStatus))
                            }
                            .padding(.horizontal,10)
                            .padding(.top,10)
                            Divider().background(Color(hex: 0x111111)).padding(.horizontal,5)
                            Text(self.issueItem.issueTitle).font(.title2).fontWeight(.bold).padding(.horizontal,10).padding(.top,10)
                            MDText(markdown: self.issueItem.issueDesc).padding().foregroundColor(Color(hex: 0xaaaaaa)).font(.system(size: 14))
                        }
                        .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
                        .cornerRadius(10)
                        .padding(.horizontal,5)
                        .padding(.top,10)
                        .padding(.bottom,0)
                        .onTapGesture {
                            UIApplication.shared.windows.first { $0.isKeyWindow }?.endEditing(true)
                        }
                        HStack(){
                            Spacer()
                            Text("最近的20条Issue评论").font(.system(size:12)).foregroundColor(.gray)
                        }
                        .padding(.trailing,5)
                        VStack(alignment: .leading){
                            VStack{
                                ForEach (0 ..< self.issueCommentList.count, id: \.self) {index in
                                    IssueCommentItemView(issueCommentItem: self.issueCommentList[index])
                                }
                            }
                            .padding(.top,10)
                        }
                        .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
                        .cornerRadius(10)
                        .padding(.horizontal,5)
                        .padding(.top,0)
                        .padding(.bottom,5)
                    }
                    .onTapGesture {
                        UIApplication.shared.windows.first { $0.isKeyWindow }?.endEditing(true)
                    }
                    Spacer()
                    VStack{
                        HStack(alignment: .center){
                            TextField("对这个Issue发表下看法...", text: $commentText , onCommit: {
                                var submitUrl = ""
                                submitUrl = submitUrl + "repos/" + self.issueItem.repoInfo.repoNamespace.path + "/"
                                submitUrl = submitUrl + self.issueItem.repoInfo.repoPath + "/issues/"
                                submitUrl = submitUrl + self.issueItem.issueId + "/comments"
                                self.isLoading = true
                                self.isModal = true
                                HttpRequest(url: submitUrl,withAccessToken: true).doPost(postData: ["body" : commentText]) { (result) in
                                    self.isLoading = false
                                    self.isModal = false
                                    let json = JSON(result)
                                    if json["error"].string != nil {
                                        if json["error"].stringValue == "The current issue has turned off the comment function" {
                                            self.startAlert(title: "提交失败", message: "你无法评论已完成的Issue")
                                        }else{
                                            self.startAlert(title: "提交失败", message: json["error"].stringValue)
                                        }
                                    }else{
                                        //提交成功
                                        self.startAlert(title: "提交成功", message: "你提交的Issue评论成功")
                                        self.commentText = ""
                                        self.getIssueComments()
                                    }
                                } errorCallback: {
                                    self.isLoading = false
                                    self.isModal = false
                                    self.startAlert(title: "提交失败", message: "提交Issue评论失败,请稍候再试")
                                }
                                
                            })
                            .foregroundColor(.white)
                            .font(.system(size:16))
                        }
                        .padding(15)
                        .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
                        .cornerRadius(10)
                    }
                    .padding(5)
                }
                .navigationBarTitle(Text("Issue详情"), displayMode: .inline)
                .navigationBarItems( trailing:
                                        HStack {
                                            Button {
                                            } label: {
                                                Menu {
                                                    Button("已开启", action: {
                                                        self.changeIssueStatus(issueStatus:  IssueStatus.open)
                                                    })
                                                    Button("进行中", action: {
                                                        self.changeIssueStatus(issueStatus: IssueStatus.progressing)
                                                    })
                                                    Button("已完成", action: {
                                                        self.changeIssueStatus(issueStatus: IssueStatus.closed)
                                                    })
                                                    Button("已拒绝", action: {
                                                        //                                                    self.changeIssueStatus(issueStatus: IssueStatus.rejected)
                                                    })
                                                } label: {
                                                    VStack{
                                                        Image(systemName: "tray.full")
                                                            .scaleEffect(1, anchor: .center)
                                                    }
                                                }
                                            }
                                        })
            }
            .onAppear(){
                self.downloadWebImage(url: self.issueItem.userInfo.userHead)
                self.getIssueComments()
            }
        }
        .preferredColorScheme(.dark)
        .alert(isPresented: $alertShow) {
            Alert(title: Text(alertTitle),message: Text(alertMessage),dismissButton: .default(Text("好的")))
        }
    }
    func changeIssueStatus(issueStatus: IssueStatus){
        let status = getIssueStatusString(status: issueStatus);
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
    func downloadWebImage(url:String) {
        guard let url = URL(string: url) else {
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                self.userHead = image
            }
        }.resume()
    }
    func getIssueComments(){
        var url = "repos/" +  self.issueItem.repoInfo.repoNamespace.path
        url = url + "/" + self.issueItem.repoInfo.repoPath + "/issues/"
        url = url + self.issueItem.issueId + "/comments?order=desc"
        print(url)
        HttpRequest(url: url,withAccessToken: true).doGet { (result) in
            let json = JSON(result)
            if json["message"].string == nil{
                self.issueCommentList = []
                for (_,subJson):(String, JSON) in json {
                    let userInfo = UserItemModel(id: Int(subJson["user"]["id"].stringValue)!, userHead: String(subJson["user"]["avatar_url"].stringValue), userName:  String(subJson["user"]["name"].stringValue), userAccount:  String(subJson["user"]["login"].stringValue))
                    let commentItem = IssueCommentModel(id: Int(subJson["id"].stringValue)!, commentBody: String(subJson["body"].stringValue), createTime: Helper.getDateFromString(str: String(subJson["created_at"].stringValue)), commentUser: userInfo)
                    
                    self.issueCommentList.append(commentItem)
                }
            }
        } errorCallback: {
        }
    }
}

struct IssueCommentItemView: View {
    @State var userHead:UIImage? = nil
    let placeholderImage = UIImage(named: "nohead")!
    @State var issueCommentItem:IssueCommentModel
    var body: some View{
        VStack{
            HStack(alignment: .top){
                Image(uiImage: self.userHead ?? placeholderImage)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width:50,height:50,
                        alignment: .center
                    )
                    .cornerRadius(5)
                    .onAppear(){
                        guard let url = URL(string: issueCommentItem.commentUser.userHead) else {
                            return
                        }
                        URLSession.shared.dataTask(with: url) { (data, response, error) in
                            if let data = data, let image = UIImage(data: data) {
                                self.userHead = image
                            }
                        }.resume()
                    }
                VStack(alignment: .leading){
                    HStack(alignment: .top){
                        Text(self.issueCommentItem.commentUser.userName).foregroundColor(Color(hex: 0xFFFFFF))
                            .padding(.bottom, 2).font(.system(size:18)).lineLimit(1)
                        Spacer()
                        Text(self.issueCommentItem.createTime).font(.system(size: 12)).foregroundColor(.gray)
                    }
                    Text(self.issueCommentItem.commentBody).font(.system(size:14)).foregroundColor(Color(hex: 0x999999))
                        .padding(.top,5)
                }
                Spacer()
            }
        }
        .padding(.vertical,2)
        .padding(.horizontal,10)
        Divider().background(Color(hex: 0x111111))
    }
}
