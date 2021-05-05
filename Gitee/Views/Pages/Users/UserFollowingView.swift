//
//  UserFollowingView.swift
//  Gitee
//
//  Created by Hamm on 2021/5/2.
//

import SwiftUI
import SwiftyJSON

struct UserFollowingView: View {
    @State var userList: [UserItemModel] = []
    @State var repoPath :String = ""
    @State var waitPlease = false
    @State var isRefreshing = false
    @State var isLoading: Bool = false
    @State var isModal: Bool = false
    @State var message: String = "数据加载中"
    @State var isLoginShow = false
    @State var page = 1
    
    var body: some View {
        LoadingView(isLoading:self.$isLoading,message: self.$message,isModal:self.$isModal) {
            ZStack{
                if userList.count == 0 && !isLoading {
                    VStack{
                        Image(systemName: "doc.text.magnifyingglass")
                            .scaleEffect(3, anchor: .center)
                        Text("没有关注任何人").padding(.top,30)
                    }
                }
                RefreshView(refreshing: $isRefreshing, action: {
                    self.page = 1
                    self.getUserList(page: self.page)
                }) {
                    LazyVStack{
                        ForEach(self.userList){ item in
                            NavigationLink(destination: UserProfileView(userInfo: item)) {
                                UserItemView(userItem:  item)
                                    .onAppear(){
                                        if !waitPlease && item.id == userList[userList.count - 1].id {
                                            self.page = self.page + 1
                                            self.getUserList(page: self.page)
                                        }
                                    }
                            }
                        }
                    }
                }
            }
        }
        .padding(.top,5)
        .sheet(isPresented: $isLoginShow,onDismiss: {
            UserModel().getMyInfo { (userInfo) in
                self.isLoading = false
                self.page = 1
                self.getUserList(page: self.page)
            } error: {
                self.isLoginShow.toggle()
            }
        }){
            LoginView()
                .modifier(DisableModalDismiss(disabled: true))
        }
        .navigationBarTitle(Text("关注列表"), displayMode: .inline)
        .onAppear(){
            self.page = 1
            self.getUserList( page: self.page)
        }
    }
    func getUserList(page: Int){
        if self.waitPlease { return }
        self.waitPlease = true
        if userList.count == 0 {
            self.isLoading = true
        }
        let url = "user/following?page=" + String(page);
        HttpRequest(url: url, withAccessToken: true)
            .doGet { (value) in
                let json = JSON(value)
                if json["message"].string != nil {
                    print("error")
                    self.isLoginShow.toggle()
                }else{
                    if page == 1{
                        userList = []
                    }
                    for (_,subJson):(String, JSON) in json {
                        userList.append(UserItemModel(id: Int(subJson["id"].stringValue)!, userHead: String(subJson["avatar_url"].stringValue), userName: String(subJson["name"].stringValue), userAccount: String(subJson["login"].stringValue)))
                    }
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
