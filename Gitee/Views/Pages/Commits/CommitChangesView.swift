//
//  CommitChangesView.swift
//  Gitee
//
//  Created by Hamm on 2021/4/28.
//

import SwiftUI

import Foundation
import SwiftUI
import SwiftyJSON

struct CommitChangesView: View {
    @State var sha: String
    @State var repoFullPath: String
    @State var commitChangeList: [CommitChangeModel] = []
    @State var isLoading: Bool = false
    @State var isModal: Bool = false
    @State var message: String = "数据加载中"
    @State var isLoginShow = false
    
    
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
                ScrollView(/*@START_MENU_TOKEN@*/.vertical/*@END_MENU_TOKEN@*/, showsIndicators: false) {
                    if self.commitChangeList.count > 0 {
                        ForEach (0 ..< self.commitChangeList.count, id: \.self) {index in
                            CommitChangeItemView(commitChangeItem: self.commitChangeList[index])
                        }
                    }else{
                        HStack(alignment: .center){
                            Spacer()
                            VStack{
                                Image(systemName: "doc.text.magnifyingglass")
                                    .scaleEffect(3, anchor: .center)
                                Text("暂无文件变更记录").padding(.top,30)
                            }
                            .opacity(isLoading ? 0 : 1)
                            Spacer()
                        }
                        .padding(.top,250)
                    }
                }
                .padding(.top,5)
                .navigationBarTitle("文件变更", displayMode: .inline)
            }
        }
        .onAppear(){
            self.getCommitChangeList()
        }
        .preferredColorScheme(.dark)
        .alert(isPresented: $alertShow) {
            Alert(title: Text(alertTitle),message: Text(alertMessage),dismissButton: .default(Text("好的")))
        }
    }
    func getCommitChangeList(){
        if isLoading { return }
        isLoading = true
        var url = "repos/"
        url = url + repoFullPath
        url = url + "/commits/" + self.sha
        HttpRequest(url: url, withAccessToken: true)
            .doGet { (value) in
                let json = JSON(value)
                if json["message"].string != nil {
                    print("error")
                    
                }else{
                    commitChangeList = []
                    for (index,subJson):(String, JSON) in json["files"] {
                        print(subJson)
                        commitChangeList.append(CommitChangeModel(id: Int(index)!, sha: String(subJson["sha"].stringValue), status: String(subJson["status"].stringValue), filename: String(subJson["filename"].stringValue), addCount: String(subJson["additions"].stringValue), deleteCount: String(subJson["deletions"].stringValue), totalCount: String(subJson["changes"].stringValue), content: String(subJson["patch"].stringValue)))
                    }
                    isLoading = false
                }
            } errorCallback: {
                
            }
    }
}

struct CommitChangeItemView:View{
    @State var commitChangeItem: CommitChangeModel
    var body: some View{
        VStack{
            VStack(alignment: .leading){
                HStack{
                    Text(commitChangeItem.filename)
                    Spacer()
                    Text("+" + commitChangeItem.addCount).font(.system(size:14)).fontWeight(.bold).foregroundColor(.green)
                    Text("-" + commitChangeItem.deleteCount).font(.system(size:14)).fontWeight(.bold).foregroundColor(.red)
                }
                VStack(alignment: .leading){
                    Text(commitChangeItem.content).font(.system(size:14)).foregroundColor(.gray).multilineTextAlignment(.leading)
                }
                .padding(.top,10)
            }
            .padding(10)
        }
        .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
        .cornerRadius(10)
        .padding(.horizontal,5)
    }
}
