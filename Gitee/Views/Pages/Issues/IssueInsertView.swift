//
//  IssueInsertView.swift
//  Gitee
//
//  Created by Hamm on 2021/4/27.
//

import SwiftUI
import  SwiftyJSON

struct IssueInsertView: View {
    @Environment(\.presentationMode) var mode
    @State var repoNamespacePath: String
    @State var repoPath: String
    @State var issueTitle: String = ""
    @State var issueBody: String = ""
    @State var error: String = ""
    @State var isLoading: Bool = false
    @State var isModal: Bool = false
    @State var message: String = "提交中"
    var body: some View {
        LoadingView(isLoading:self.$isLoading,message: self.$message,isModal:self.$isModal) {
            NavigationView{
                VStack{
                    Form{
                        Section(header: Text("你的问题")) {
                            TextField("", text: $issueTitle,onEditingChanged:{_ in
                                self.error = ""
                            })
                                .foregroundColor(.white)
                                .font(.system(size:16))
                            if error != "" {
                                Text(error).foregroundColor(.yellow).font(.system(size: 14)).fontWeight(.bold)
                                    .listRowBackground(Color.black)
                                        
                            }
                        }
                        Section(header: Text("详细描述")) {
                            TextEditor(text: $issueBody)
                                .foregroundColor(.white)
                                .font(.system(size:16))
                                .lineLimit(5)
                        }
                    }
                    Spacer()
                }
                .navigationBarTitle(Text("提交Issue"), displayMode: .inline)
                .navigationBarItems(trailing:
                                        Button(action: {
                                            self.error = ""
                                            if self.issueTitle.count < 5 {
                                                self.error  = "咱有问题好歹也至少说五个字吧?"
                                                return
                                            }
                                            self.isLoading = true
                                            self.isModal = true
                                            HttpRequest(url: "repos/" + repoNamespacePath + "/issues",withAccessToken: true).doPost(postData: ["repo":repoPath,"title":issueTitle,"body":issueBody,"labels":"GiteeApp"]) { (result) in
                                                let json = JSON(result)
                                                self.isLoading = false
                                                self.isModal = false
                                                if json["message"].string != nil{
                                                    self.error = "提交Issue失败,请重试"
                                                }else{
                                                    self.mode.wrappedValue.dismiss()
                                                }
                                            } errorCallback: {
                                                self.isLoading = false
                                                self.isModal = false
                                                self.error = "提交Issue失败,请重试"
                                            }
                                        }) {
                                            Text("提交").foregroundColor(.yellow)
                                        })
                
            }
            .preferredColorScheme(.dark)
        }
    }
}
