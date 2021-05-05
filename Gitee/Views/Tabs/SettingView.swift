//
//  SettingView.swift
//  Gitee
//
//  Created by Hamm on 2021/4/19.
//
import Foundation
import AVFoundation
import SwiftUI
import SwiftyJSON
struct SettingView: View {
    @State var isQrcodeShow = false
    @State var isLoginShow = false
    @State var isModal = false
    @State var userAccount = "hamm"
    @State var userName = "请先登录"
    @State var userBio = "你需要登录后才能访问"
    @State var userFollowers = "0"
    @State var userFollowing = "0"
    @State var userStars = "0"
    @State var userWatches = "0"
    @State var userHead:UIImage? = nil
    let placeholderImage = UIImage(named: "nohead")!
    
    @State var isActiveFollowing:Bool = false
    @State var isActiveFollowers:Bool = false
    
    var body: some View {
        ScrollView{
            NavigationLink(destination: UserFollowersView(), isActive: $isActiveFollowers) { EmptyView() }
            NavigationLink(destination: UserFollowingView(), isActive: $isActiveFollowing) { EmptyView() }
            NavigationLink(destination:
                            SettingQrcode(userAccount:  self.userAccount), isActive: $isQrcodeShow) { EmptyView() }
            VStack{
                HStack(alignment: .center){
                    Image(uiImage: self.userHead ?? placeholderImage)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width:80,height:80,
                            alignment: .center
                        )
                        .cornerRadius(80)
                    VStack(alignment: .leading){
                        Text(self.userName).foregroundColor(Color(hex: 0xFFFFFF))
                            .padding(.bottom, 2).font(.system(size:24)).lineLimit(1)
                        Text(self.userBio).foregroundColor(Color(hex: 0x999999)).lineLimit(2)
                            .font(.system(size:14))
                    }
                    .padding(.horizontal, 5.0)
                    Spacer()
                    Image(systemName: "qrcode")
                        .scaleEffect(1.2, anchor: .center)
                        .padding(.top,10)
                        .onTapGesture {
                            self.isQrcodeShow.toggle()
                        }
                }
                .padding(.horizontal, 10.0)
                .padding(.vertical, 10)
                HStack{
                    VStack{
                        Text(self.userFollowing).font(.system(size:20))
                            .fontWeight(.bold)
                        Text("关注").foregroundColor(Color(hex: 0x999999)).font(.system(size:12))
                    }
                    .onTapGesture {
                        self.isActiveFollowing = true
                    }
                    Spacer()
                    VStack{
                        Text(self.userFollowers).font(.system(size:20))
                            .fontWeight(.bold)
                        Text("粉丝").foregroundColor(Color(hex: 0x999999)).font(.system(size:12))
                    }
                    .onTapGesture {
                        self.isActiveFollowers = true
                    }
                    Spacer()
                    VStack{
                        Text(self.userStars).font(.system(size:20))
                            .fontWeight(.bold)
                        Text("Star").foregroundColor(Color(hex: 0x999999)).font(.system(size:12))
                    }
                    Spacer()
                    VStack{
                        Text(self.userWatches).font(.system(size:20))
                            .fontWeight(.bold)
                        Text("Watch").foregroundColor(Color(hex: 0x999999)).font(.system(size:12))
                    }
                }
                .padding(.vertical,10)
                .padding(.horizontal,20)
//                VStack{
//                    NavigationLink(destination: SettingQrcode(userAccount: "hamm")) {
//                        SettingItemView(title: "修改资料",icon:"person.circle")
//                    }
//                }
//                .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
//                .cornerRadius(10)
//                .padding(.horizontal,5)
//                .padding(.top,10)
                VStack{
                    NavigationLink(destination:  PubKeysView()) {
                        SettingItemView(title: "公钥管理",icon:"lock.circle")
                    }
                    Divider().background(Color(hex: 0x111111))
                        .padding(.leading,20)
                    NavigationLink(destination:  IssuesView(repoPath: "gitee_ios/feedback", title: "反馈建议")) {
                        SettingItemView(title: "反馈与建议",icon:"envelope.circle")
                    }
                    Divider().background(Color(hex: 0x111111))
                        .padding(.leading,20)
                    NavigationLink(destination:  AboutView()) {
                        SettingItemView(title: "关于项目和源码",icon:"paperplane.circle")
                    }
                }
                .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
                .cornerRadius(10)
                .padding(.horizontal,5)
                .padding(.top,10)
                VStack{
                    SettingItemView(title: "退出登录",icon:"eject.circle")
                        .foregroundColor(.red)
                        .background(Color(hex: 0x1c1c1e))
                        .onTapGesture {
                            UIAlertController.danger(message: "是否确认退出当前登录的账号？", title: "退出提醒", confirmText: "退出", cancelText: "暂不") { (action) in
                                localConfig.setValue("", forKey: giteeConfig.access_token)
                                self.reloadMyInfo()
                            }
                        }
                }
                .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
                .cornerRadius(10)
                .padding(.horizontal,5)
                .padding(.top,10)
            }
            .sheet(isPresented: $isLoginShow,onDismiss: {
                self.reloadMyInfo();
            }){
                LoginView()
                    .modifier(DisableModalDismiss(disabled: true))
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .padding(.horizontal,10)
        .padding(.top,50)
        .preferredColorScheme(.dark)
        .onAppear(){
            self.reloadMyInfo();
        }
    }
    func showMyInfo(userInfo: JSON){
        self.userAccount = userInfo["login"].string!
        self.userName = userInfo["name"].string!
        self.userBio = userInfo["bio"].string!
        self.userFollowers = String(userInfo["followers"].int!)
        self.userFollowing = String(userInfo["following"].int!)
        self.userStars = String(userInfo["stared"].int!)
        self.userWatches = String(userInfo["watched"].int!)
        self.downloadWebImage(url: userInfo["avatar_url"].string!)
    }
    func reloadMyInfo() {
        UserModel().getMyInfo { (userInfo) in
            self.showMyInfo(userInfo: userInfo)
        } error: {
            self.userName = "请先登录"
            self.userBio = "你需要登录后才能访问"
            self.userFollowers = "0"
            self.userFollowing = "0"
            self.userStars = "0"
            self.userWatches = "0"
            self.userHead = nil
            self.isLoginShow.toggle()
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
}

struct SettingItemView : View {
    @State var title: String
    @State var icon: String
    
    var body: some View {
        VStack{
            HStack(alignment: .center){
                Image(systemName:icon)
                    .scaleEffect(1.5, anchor: .center)
                Text(title).font(.system(size:16)).padding(.leading,10)
                Spacer()
                HStack{
                    Image(systemName: "chevron.forward")
                        .scaleEffect(0.8)
                }
                .foregroundColor(.gray)
            }
            .padding(.bottom,15)
            .padding(.top,15)
            .padding(.leading,20)
            .padding(.trailing,15)
        }
    }
}

struct SettingQrcode: View {
    @State var qrcodeImage:UIImage? = nil
    let placeholderImage = UIImage(named: "nohead")!
    @State var userAccount:String
    var body: some View {
        VStack{
            VStack{
                Image(uiImage: self.qrcodeImage ?? placeholderImage)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width:200,height:200,
                        alignment: .center
                    )
            }
            .padding(5)
            .background(Color(.white))
            .cornerRadius(10)
            Text("扫描二维码关注我的开源项目").padding(.top,20)
        }
        .navigationBarTitle(Text("你的Gitee码"), displayMode: .inline)
        .preferredColorScheme(.dark)
        .onAppear(){
            print("Creating qrcode for " + userAccount)
            qrcodeImage = Qrcode.setQRCodeToImageView(url: "https://gitee.com/" + userAccount)
        }
    }
}

