
//
//  PullRequestDetailView.swift
//  Gitee
//
//  Created by Hamm on 2021/4/28.
//

import SwiftUI
import SwiftyJSON

struct PullRequestDetailView: View {
    @Binding var pullRequestItem: PullRequestModel
    @State var isLoading: Bool = false
    @State var isModal: Bool = false
    @State var message: String = "提交中"
    @State var commentText:String = "";
    @State var pullRequestCommentList:[PullRequestCommentModel] = []
    @State private var isActiveCommentList:Bool = false
    
    @State private var alertShow = false
    @State var alertTitle:String = ""
    @State var alertMessage:String = ""
    func startAlert(title:String,message:String){
        self.alertTitle = title
        self.alertMessage = message
        self.alertShow = true
    }
    
    var body: some View{
        NavigationLink(destination: CommitView(pullRequestItem: self.pullRequestItem), isActive: $isActiveCommentList) { EmptyView() }
        LoadingView(isLoading:self.$isLoading,message: self.$message,isModal:self.$isModal) {
            NavigationView{
                VStack{
                    ScrollView(.vertical, showsIndicators: false) {
                        
                        PullRequestCardView(pullRequestItem:pullRequestItem)
                        
                        HStack(){
                            Spacer()
                            Text("最近的20条Pull Request评论").font(.system(size:12)).foregroundColor(.gray)
                        }
                        .padding(.trailing,5)
                        VStack(alignment: .leading){
                            VStack{
                                ForEach (0 ..< self.pullRequestCommentList.count, id: \.self) {index in
                                    PullRequestCommentItemView(pullRequestCommentList: self.pullRequestCommentList[index])
                                }
                            }
                            .padding(.top,10)
                        }
                        .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
                        .cornerRadius(10)
                        .padding(.horizontal,5)
                        .padding(.top,0)
                        .padding(.bottom,5)
                        .onTapGesture {
                            UIApplication.shared.windows.first { $0.isKeyWindow }?.endEditing(true)
                        }
                        
                    }
                    .onTapGesture {
                        UIApplication.shared.windows.first { $0.isKeyWindow }?.endEditing(true)
                    }
                    Spacer()
                    VStack{
                        HStack(alignment: .center){
                            TextField("对这个Pull Request发表下看法...", text: $commentText , onCommit: {
                                var submitUrl = ""
                                submitUrl = submitUrl + "repos/" + self.pullRequestItem.prTo.repoNamespace.path + "/"
                                submitUrl = submitUrl + self.pullRequestItem.prTo.repoPath + "/pulls/"
                                submitUrl = submitUrl + String(self.pullRequestItem.prId) + "/comments"
                                self.isLoading = true
                                self.isModal = true
                                self.message = "提交中"
                                HttpRequest(url: submitUrl,withAccessToken: true).doPost(postData: ["body" : commentText]) { (result) in
                                    self.isLoading = false
                                    self.isModal = false
                                    let json = JSON(result)
                                    if json["error"].string != nil {
                                        self.startAlert(title: "提交失败", message: json["error"].stringValue)
                                    }else{
                                        //提交成功
                                        self.startAlert(title: "提交失败", message: "你提交的Pull Request评论成功")
                                        self.commentText = ""
                                        self.getPullRequestComments()
                                    }
                                } errorCallback: {
                                    self.isLoading = false
                                    self.isModal = false
                                    self.startAlert(title: "提交失败", message: "你的评论提交失败,发生了点错误")
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
                .navigationBarTitle(Text("Pull Request"), displayMode: .inline)
                .navigationBarItems( trailing:
                                        HStack {
                                            Button {
                                            } label: {
                                                Menu {
                                                    Button("提交记录", action: {
                                                        self.isActiveCommentList = true
                                                    })
                                                    Divider()
                                                    Button("审查通过", action: {
                                                        self.checkPullRequest()
                                                    })
                                                    Button("测试通过", action: {
                                                        self.testPullRequest()
                                                    })
                                                    Divider()
                                                    Button("确认合并", action: {
                                                        self.mergePullRequest()
                                                    })
                                                } label: {
                                                    VStack{
                                                        Image(systemName: "shuffle")
                                                            .scaleEffect(1, anchor: .center)
                                                    }
                                                }
                                            }
                                        })
            }
            .onAppear(){
                self.getPullRequestComments()
            }
        }
        .preferredColorScheme(.dark)
        .alert(isPresented: $alertShow) {
            Alert(title: Text(alertTitle),message: Text(alertMessage),dismissButton: .default(Text("好的")))
        }
    }
    func getPullRequestComments(){
        var url = ""
        url = url + "repos/" + self.pullRequestItem.prTo.repoNamespace.path + "/"
        url = url + self.pullRequestItem.prTo.repoPath + "/pulls/"
        url = url + String(self.pullRequestItem.prId) + "/comments?order=desc"
        HttpRequest(url: url,withAccessToken: true).doGet { (result) in
            let json = JSON(result)
            if json["message"].string == nil{
                self.pullRequestCommentList = []
                for (_,subJson):(String, JSON) in json {
                    let userInfo = UserItemModel(id: Int(subJson["user"]["id"].stringValue)!, userHead: String(subJson["user"]["avatar_url"].stringValue), userName:  String(subJson["user"]["name"].stringValue), userAccount:  String(subJson["user"]["login"].stringValue))
                    let commentItem = PullRequestCommentModel(id: Int(subJson["id"].stringValue)!, commentBody: String(subJson["body"].stringValue), createTime: Helper.getDateFromString(str: String(subJson["created_at"].stringValue)), commentUser: userInfo)
                    
                    self.pullRequestCommentList.append(commentItem)
                }
            }
        } errorCallback: {
        }
    }
    func mergePullRequest(){
        let url = "repos/" + self.pullRequestItem.prTo.repoNamespace.path + "/" + self.pullRequestItem.prTo.repoPath + "/pulls/" + String(self.pullRequestItem.prId) + "/merge"
        
        self.isLoading = true
        self.isModal = true
        self.message = "合并中"
        HttpRequest(url: url,withAccessToken: true).doPut(postData: ["a":"b"]) { (result) in
            let json = JSON(result)
            print(json)
            if json["message"].string != nil{
                self.startAlert(title: "合并失败", message: json["message"].stringValue)
            }else{
                self.startAlert(title: "合并成功", message: "该Pull Request已被自动合并成功")
            }
            
            let getUrl = "repos/" + self.pullRequestItem.prTo.repoNamespace.path + "/" + self.pullRequestItem.prTo.repoPath + "/pulls/" + String(self.pullRequestItem.prId)
            HttpRequest(url: getUrl,withAccessToken: true).doGet { (result) in
                let subJson = JSON(result)
                if subJson["message"].string == nil{
                    let userInfo = UserItemModel(id: Int(subJson["user"]["id"].intValue), userHead: String(subJson["user"]["avatar_url"].stringValue), userName: String(subJson["user"]["name"].stringValue), userAccount: String(subJson["user"]["login"].stringValue))
                    
                    let fromRepo = RepoModel(id: Int(subJson["head"]["repo"]["id"].intValue), repoName: String(subJson["head"]["repo"]["name"].stringValue), repoPath: String(subJson["head"]["repo"]["path"].stringValue), repoNamespace: RepoNamespace(id: Int(subJson["head"]["repo"]["namespace"]["id"].intValue), name: String(subJson["head"]["repo"]["namespace"]["name"].stringValue), path: String(subJson["head"]["repo"]["namespace"]["path"].stringValue)), repoDesc: String(subJson["head"]["repo"]["description"].stringValue), repoForks: "", repoStars: "",repoWatches:"", repoLicense:"", repoLanguage: "", repoPushDate:"", repoIsFork: false, repoIsOpenSource: Bool(subJson["head"]["repo"]["public"].boolValue), repoIssues:"", repoDefaultBranch:"")
                    
                    let toRepo = RepoModel(id: Int(subJson["base"]["repo"]["id"].intValue), repoName: String(subJson["base"]["repo"]["name"].stringValue), repoPath: String(subJson["base"]["repo"]["path"].stringValue), repoNamespace: RepoNamespace(id: Int(subJson["base"]["repo"]["namespace"]["id"].intValue), name: String(subJson["base"]["repo"]["namespace"]["name"].stringValue), path: String(subJson["base"]["repo"]["namespace"]["path"].stringValue)), repoDesc: String(subJson["base"]["repo"]["description"].stringValue), repoForks: "", repoStars: "",repoWatches:"", repoLicense:"", repoLanguage: "", repoPushDate:"", repoIsFork: false, repoIsOpenSource: Bool(subJson["base"]["repo"]["public"].boolValue), repoIssues:"", repoDefaultBranch:"")
                    self.pullRequestItem = PullRequestModel(id: Int(subJson["id"].intValue), prId: Int(subJson["number"].intValue), prStatus: getPullRequestStatus(status: String(subJson["state"].stringValue)), prTitle: String(subJson["title"].stringValue), prBody: String(subJson["body"].stringValue), prUser: userInfo, prFrom: fromRepo, prTo: toRepo, prTime: Helper.getDateFromString(str: String(subJson["updated_at"].stringValue)), prAuthMerge: Bool(subJson["mergeable"].boolValue),prFromBranch: String(subJson["head"]["ref"].stringValue),prToBranch: String(subJson["base"]["ref"].stringValue))
                }
            } errorCallback: {
                
            }
            
            
            self.isLoading = false
            self.isModal = false
        } errorCallback: {
            self.isLoading = false
            self.isModal = false
            print("error")
        }
    }
    func checkPullRequest(){
        let url = "repos/" + self.pullRequestItem.prTo.repoNamespace.path + "/" + self.pullRequestItem.prTo.repoPath + "/pulls/" + String(self.pullRequestItem.prId) + "/review"
        
        self.isLoading = true
        self.isModal = true
        self.message = "审查中"
        HttpRequest(url: url,withAccessToken: true).doPost(postData: ["a":"b"]) { (result) in
            let json = JSON(result)
            if json["message"].string != nil{
                self.startAlert(title: "审查未通过", message: json["message"].stringValue)
            }else{
                self.startAlert(title: "审查通过", message: "该Pull Request已被标记为审查通过")
            }
            self.isLoading = false
            self.isModal = false
        } errorCallback: {
            self.isLoading = false
            self.isModal = false
            print("error")
        }
    }
    func testPullRequest(){
        let url = "repos/" + self.pullRequestItem.prTo.repoNamespace.path + "/" + self.pullRequestItem.prTo.repoPath + "/pulls/" + String(self.pullRequestItem.prId) + "/test"
        
        self.isLoading = true
        self.isModal = true
        self.message = "测试中"
        HttpRequest(url: url,withAccessToken: true).doPost(postData: ["a":"b"]) { (result) in
            let json = JSON(result)
            if json["message"].string != nil{
                self.startAlert(title: "测试未通过", message: json["message"].stringValue)
            }else{
                self.startAlert(title: "测试通过", message: "该Pull Request已被标记为测试通过")
            }
            self.isLoading = false
            self.isModal = false
        } errorCallback: {
            self.isLoading = false
            self.isModal = false
            print("error")
        }
    }
    
}
struct PullRequestCardView: View {
    @State var pullRequestItem:PullRequestModel
    @State var prFromToString:String = ""
    @State var prFromToString2:String = ""
    var body: some View{
        VStack{
            VStack{
                VStack(alignment: .leading){
                    HStack(alignment: .top){
                        Text(self.pullRequestItem.prTitle)
                            .font(.system(size: 18))
                        Spacer()
                    }
                }
                .padding(5)
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
                    Text(self.pullRequestItem.prTime)
                        .padding(.vertical,1)
                        .padding(.horizontal,3)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Spacer()
                }
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
                .padding(.top,10)
            }
            .padding(.horizontal,10)
            .padding(.top,5)
            .padding(.bottom,10)
        }
        .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
        .cornerRadius(10)
        .padding(.horizontal, 5)
        .padding(.top,10)
        .padding(.bottom,5)
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
struct PullRequestCommentItemView: View {
    @State var userHead:UIImage? = nil
    let placeholderImage = UIImage(named: "nohead")!
    @State var pullRequestCommentList:PullRequestCommentModel
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
                        guard let url = URL(string: pullRequestCommentList.commentUser.userHead) else {
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
                        Text(self.pullRequestCommentList.commentUser.userName).foregroundColor(Color(hex: 0xFFFFFF))
                            .padding(.bottom, 2).font(.system(size:18)).lineLimit(1)
                        Spacer()
                        Text(self.pullRequestCommentList.createTime).font(.system(size: 12)).foregroundColor(.gray)
                    }
                    Text(self.pullRequestCommentList.commentBody).font(.system(size:14)).foregroundColor(Color(hex: 0x999999))
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
