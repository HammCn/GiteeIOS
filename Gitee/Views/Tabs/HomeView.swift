//
//  HomeView.swift
//  Gitee
//
//  Created by Hamm on 2021/4/19.
//

import SwiftUI

struct HomeView: View {
    @State var isLoginShow = false
    @State var isLoaded = false
    var body: some View {
        Form {
            Section(header: Text("工作台")) {
                NavigationLink(destination: RepoView()) {
                    HomeListItem(title: "代码仓库",icon:"archivebox.circle", color: Color(hex: 0x7699ec))
                }
//                NavigationLink(destination:  PullRequestView()) {
//                    HomeListItem(title: "Pull Request",icon:"shuffle.circle", color: Color(hex: 0x00b392))
//                }
                NavigationLink(destination:  IssuesView()) {
                    HomeListItem(title: "Issues",icon:"exclamationmark.circle", color: Color(hex: 0xfe665b))
                }
            }
            Section(header: Text("消息中心")) {
                NavigationLink(destination: MailView()) {
                    HomeListItem(title: "你的私信",icon:"envelope.circle", color: Color(hex: 0x16c3fc))
                }
                NavigationLink(destination: NotificationView()) {
                    HomeListItem(title: "你的通知",icon:"bell.circle", color: Color(hex: 0xf83860))
                }
            }
            Section(header: Text("你的团队")) {
                NavigationLink(destination:  OrganizationView()) {
                    HomeListItem(title: "加入的组织",icon:"person.2.circle", color: Color(hex: 0xb76dda))
                }
//                NavigationLink(destination:  RepoView()) {
//                    HomeListItem(title: "所在的企业",icon:"paperplane.circle", color: Color(hex: 0xffc55a))
//                }
            }
        }
        .sheet(isPresented: $isLoginShow,onDismiss: {
            UserModel().getMyInfo { (userInfo) in
                
            } error: {
                self.isLoginShow.toggle()
            }
        }){
            LoginView()
                .modifier(DisableModalDismiss(disabled: true))
        }
        .padding(-10)
        .toolbar{
            ToolbarItem(placement:.primaryAction){
                HStack(spacing:10){
                    //                    Button(action:{
                    //                        self.isModal=true
                    //                    }){
                    //                        Image(systemName: "magnifyingglass.circle.fill")
                    //                            .scaleEffect(1.2, anchor: .center)
                    //                    }.sheet(isPresented: $isModal, onDismiss: {
                    //                        print("HomeDetail View Dismissed")
                    //                    }) {
                    //                        HomeDetail()
                    //                    }
                    //                    Text("")
                }
            }
        }
        .preferredColorScheme(.dark)
        .onDisappear(){
            self.isLoaded = true
        }
        .onAppear(){
//            localConfig.setValue("all", forKey: giteeConfig.access_token)
            if(self.isLoaded){
                UserModel().getMyInfo { (userInfo) in
                    
                } error: {
                    self.isLoginShow.toggle()
                }
            }
        }
    }
}

struct HomeListItem : View {
    @State var title: String
    @State var icon: String
    @State var color: Color
    
    var body: some View {
        HStack(spacing: 15){
            Image(systemName:icon)
                .scaleEffect(1.5, anchor: .center)
                .foregroundColor(color)
            Text(title).font(.system(size:16))
        }
        .padding(.horizontal, 5)
        .frame( height: 48)
        .cornerRadius(10)
    }
}

struct HomeTeamItem : View {
    @State var title: String
    
    var body: some View {
        Text(title).font(.system(size:16))
        .frame( height: 48)
        .cornerRadius(10)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}




