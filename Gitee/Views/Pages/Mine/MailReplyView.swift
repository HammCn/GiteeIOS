//
//  MailReplyView.swift
//  Gitee
//
//  Created by Hamm on 2021/5/4.
//

import SwiftUI
import SwiftyJSON
import SwipeCell

struct MailReplyView: View {
    @Environment(\.presentationMode) var mode
    @State var user: UserItemModel
    @State var content: String = ""
    @State var isLoading: Bool = false
    @State var isModal: Bool = false
    @State var message: String = "回复中"
    
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
                        Section(header: Text("你正在回复 @" + user.userName)) {
                            TextEditor(text: $content)
                                .foregroundColor(.white)
                                .font(.system(size:16))
                                .lineLimit(5)
                        }
                    }
                    Spacer()
                }
                .navigationBarTitle(Text("回复私信"), displayMode: .inline)
                .navigationBarItems(
                    trailing:
                        Button(action: {
                            if self.content.count < 1 {
                                self.startAlert(title: "回复失败", message: "你确定不说点什么吗???")
                                return
                            }
                            self.isLoading = true
                            self.isModal = true
                            HttpRequest(url: "notifications/messages",withAccessToken: true).doPost(postData: ["username":user.userAccount,"content":content]) { (result) in
                                let json = JSON(result)
                                self.isLoading = false
                                self.isModal = false
                                if json["message"].string != nil{
                                    self.startAlert(title: "回复失败", message: json["message"].stringValue)
                                }else{
                                    self.content = ""
                                    self.startAlert(title: "回复成功", message: "你的消息回复成功")
//                                    self.mode.wrappedValue.dismiss()
                                }
                            } errorCallback: {
                                self.isLoading = false
                                self.isModal = false
                                self.startAlert(title: "回复失败", message:"发生了一点小错误,请稍候再试")
                            }
                        }) {
                            Text("回复").foregroundColor(.yellow)
                        })
                
            }
            .preferredColorScheme(.dark)
            .alert(isPresented: $alertShow) {
                Alert(title: Text(alertTitle),message: Text(alertMessage),dismissButton: .default(Text("好的")))
            }
        }
    }
}
