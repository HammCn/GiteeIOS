//
//  LoginView.swift
//  Gitee
//
//  Created by Hamm on 2021/4/19.
//

import SwiftUI
import SwiftyJSON
struct LoginView: View {
    @Environment(\.presentationMode) var presentation
    @State var username: String = ""
    @State var password: String = ""
    @State var isEdit:Bool = false;
    @State var isLoading: Bool = false
    @State var isModal: Bool = false
    @State var message: String = "正在登录"
    
    @State private var alertShow = false
    @State var alertTitle:String = ""
    @State var alertMessage:String = ""
    func startAlert(title:String,message:String){
        self.alertTitle = title
        self.alertMessage = message
        self.alertShow = true
    }
    let nameText = Text("请填入昵称").foregroundColor(.secondary).font(.system(size: 16))
    let pwdText = Text("请填入密码").foregroundColor(.secondary).font(.system(size: 16))
    var body: some View {
        LoadingView(isLoading:self.$isLoading,message: self.$message,isModal:self.$isModal) {
            ScrollView{
                Text("Gitee~").font(.system(size: 36)).padding(.top,80)
                Text("在手机上管理你的代码仓库")
                    .foregroundColor(.gray)
                    .padding(.top,10)
                    .font(.system(size: 16))
                VStack{
                    VStack(spacing: 15) {
                        HStack {
                            TextField("请输入你的账号", text: $username)
                                .keyboardType(UIKeyboardType.emailAddress)
                                .foregroundColor(.white)
                                .font(.system(size:18))
                        }
                        .padding(.horizontal,20)
                        .padding(.top,20)
                        Divider()
                        HStack {
                            SecureField("请输入你的密码", text: $password) {
                                print("Password: \(self.password)")
                            }
                            .font(.system(size:18))
                        }
                        .padding(.horizontal,20)
                        .padding(.bottom,20)
                    }
                    .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
                    .cornerRadius(10)
                    .padding(.top,20)
                }
                .padding(.horizontal,20)
                .padding(.top,50)
                .padding(.bottom,30)
                
                Button(action: {
                    self.isEdit=false
                    self.isLoading = true
                    self.isModal = true
                    UIApplication.shared.windows.first { $0.isKeyWindow }?.endEditing(true)
                    HttpRequest(url: "https://gitee.com/oauth/token")
                        .doPost(postData: [
                            "grant_type" : "password",
                            "username": self.username,
                            "password": self.password,
                            "client_id" : "87c5bd8b7e336d7617008077baaef1bcafbecb523d1343594a1394b351513725",
                            "client_secret" :"b8a36337305d1857984cd9fa9a4b672007759b5e02d3c23309a88a78f1a69b23",
                            "scope":"user_info projects pull_requests issues notes keys hook groups gists enterprises"
                        ]) { (value) in
                            self.isLoading = false
                            self.isModal = false
                            let json = JSON(value)
                            if let access_token = json["access_token"].string {
                                localConfig.setValue(access_token, forKey: giteeConfig.access_token)
                                
                                UserModel().getMyInfo { (userInfo) in
                                    localConfig.setValue(userInfo["login"].stringValue, forKey: giteeConfig.user_name)
                                    self.presentation.wrappedValue.dismiss()
                                } error: {
                                    self.startAlert(title: "登录失败", message: "请确认账号密码是否正确")
                                }
                                
                            } else {
                                self.startAlert(title: "登录失败", message: "请确认账号密码是否正确")
                            }
                        } errorCallback: {
                            self.isLoading = false
                            self.isModal = false
                            self.startAlert(title: "登录失败", message: "发生了点网络错误")
                        }
                    
                }) {
                    Text("立即登录")
                        .padding(.horizontal,100)
                        .padding(.vertical,15)
                        .font(.system(size:16))
                        .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top,10)
            }
            .onTapGesture(perform: {
                self.isEdit = false
                UIApplication.shared.windows.first { $0.isKeyWindow }?.endEditing(true)
            })
//            .listStyle(GroupedListStyle())
            .preferredColorScheme(.dark)
        }
        .alert(isPresented: $alertShow) {
            Alert(title: Text(alertTitle),message: Text(alertMessage),dismissButton: .default(Text("好的")))
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
