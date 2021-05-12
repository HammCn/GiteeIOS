//
//  PublicKeyInsertView.swift
//  Gitee
//
//  Created by Hamm on 2021/4/30.
//
import SwiftUI
import  SwiftyJSON

struct PublicKeyInsertView: View {
    @Environment(\.presentationMode) var mode
    @State var pubTitle: String = ""
    @State var pubKey: String = ""
    
    @State var isLoading: Bool = false
    @State var isModal: Bool = false
    @State var message: String = "提交中"
    
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
                    Form{
                        Section(header: Text("标题")) {
                            TextField("", text: $pubTitle)
                            .foregroundColor(.white)
                            .font(.system(size:16))
                        }
                        Section(header: Text("公钥")) {
                            TextEditor(text: $pubKey)
                                .foregroundColor(.white)
                                .font(.system(size:16))
                                .lineLimit(5)
                        }
                    }
                    Spacer()
                }
                .navigationBarTitle(Text("添加公钥"), displayMode: .inline)
                .navigationBarItems(
                    trailing:
                        Button(action: {
                            if self.pubTitle.count < 5 {
                                self.startAlert(title: "添加失败", message: "公钥标题请至少填写五个字")
                                return
                            }
                            if self.pubKey.count < 50{
                                self.startAlert(title: "添加失败", message: "你输入的公钥格式可能不正确")
                                return
                            }
                            UIApplication.shared.windows.first { $0.isKeyWindow }?.endEditing(true)
                            self.isLoading = true
                            self.isModal = true
                            let access_token = localConfig.string(forKey: giteeConfig.access_token)
                            let json:JSON = [
                                "access_token" : access_token!,
                                "title" : pubTitle,
                                "key" : pubKey
                            ]
                            if let postJson = json.rawString() {
                                HttpRequest(url: "user/keys",withAccessToken: true)
                                    .doPostJson(postJson: postJson) { (result) in
                                    let json = JSON(result)
                                        print(json)
                                    self.isLoading = false
                                    self.isModal = false
                                    if json["message"].string != nil{
                                        self.isLoading = false
                                        self.isModal = false
                                        self.startAlert(title: "添加失败", message: json["message"].stringValue)
                                    }else{
                                        self.mode.wrappedValue.dismiss()
                                    }
                                } errorCallback: {
                                    self.isLoading = false
                                    self.isModal = false
                                    self.startAlert(title: "添加失败", message: "网络发生了点错误,请稍候再试")
                                }
                            }
                        }) {
                            Text("提交").foregroundColor(.yellow)
                        })
                
            }
            .preferredColorScheme(.dark)
        }
        .alert(isPresented: $alertShow) {
            Alert(title: Text(alertTitle),message: Text(alertMessage),dismissButton: .default(Text("好的")))
        }
    }
}
