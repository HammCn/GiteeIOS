//
//  PubKeysView.swift
//  Gitee
//
//  Created by Hamm on 2021/4/20.
//

import SwiftUI
import SwiftyJSON
import SwipeCell

struct PubKeysView: View {
    @State var publicKeyList:[PublicKeyModel] = []
    @State var waitPlease = false
    @State var isRefreshing = false
    @State var isLoading: Bool = false
    @State var isModal: Bool = false
    @State var message: String = "数据加载中"
    @State var isLoginShow = false
    @State var isFormShow = false
    var body: some View {
        LoadingView(isLoading:self.$isLoading,message: self.$message,isModal:self.$isModal) {
            ZStack{
                if publicKeyList.count == 0 && !isLoading {
                    VStack{
                        Image(systemName: "doc.text.magnifyingglass")
                            .scaleEffect(3, anchor: .center)
                        Text("暂无查询到的公钥").padding(.top,30)
                    }
                }
                RefreshView(refreshing: $isRefreshing, action: {
                    self.getPublicKeyList()
                }) {
                    LazyVStack{
                        ForEach(self.publicKeyList){ item in
                            PubKeysItemView(publicKeyItem: item)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isLoginShow,onDismiss: {
            UserModel().getMyInfo { (userInfo) in
                self.isLoading = true
                self.getPublicKeyList()
            } error: {
                self.isLoginShow.toggle()
            }
        }){
            LoginView()
                .modifier(DisableModalDismiss(disabled: true))
        }
        .padding(.top,5)
        .navigationBarTitle(Text("你的公钥"), displayMode: .inline)
        .navigationBarItems(
            trailing:
                HStack {
                    Button(action: {
                        self.isFormShow.toggle()
                    }) {
                        Image(systemName: "plus.circle")
                            .scaleEffect(1, anchor: .center)
                    }
                }
                .sheet(isPresented: $isFormShow,onDismiss: {
                    self.isLoading = true
                    self.getPublicKeyList()
                }){
                    PublicKeyInsertView()
                        .modifier(DisableModalDismiss(disabled: false))
                }
        )
        .onAppear(){
            self.getPublicKeyList()
        }
    }
    func getPublicKeyList(){
        if self.waitPlease { return }
        self.waitPlease = true
        if publicKeyList.count == 0 {
            self.isLoading = true
        }
        HttpRequest(url: "user/keys", withAccessToken: true)
            .doGet { (value) in
                let json = JSON(value)
                if json["message"].string != nil {
                    print("error")
                    self.isLoginShow.toggle()
                }else{
                    var tempList:[PublicKeyModel] = []
                    for (_,subJson):(String, JSON) in json {
                        tempList.append(PublicKeyModel(id: subJson["id"].intValue,title: subJson["title"].stringValue,key:subJson["key"].stringValue,createTime: subJson["created_at"].stringValue))
                    }
                    publicKeyList = tempList
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
struct PubKeysItemView:View{
    @State var publicKeyItem:PublicKeyModel
    var body: some View{
        VStack{
            VStack{
                HStack(alignment: .top) {
                    VStack(alignment: .leading){
                        Text(publicKeyItem.title)
                            .font(.system(size: 16))
                            .lineLimit(1)
                    }
                    Spacer()
                    Text(Helper.getDateFromString(str: publicKeyItem.createTime))
                        .padding(.vertical,1)
                        .padding(.horizontal,3)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .cornerRadius(3)
                    
                }
                .padding(5)
                Text(publicKeyItem.key)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(5)
                    .padding(.top,10)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(10)
        }
        .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
        .cornerRadius(10)
        .padding(.horizontal,5)
        .padding(.bottom,-5)
        .contextMenu(ContextMenu {
            Button(action: {
            }) {
                HStack{
                    Image(systemName: "doc.on.doc").scaleEffect(1, anchor: .center)
                    Spacer()
                    Text("复制公钥")
                }
            }
            Divider()
            Button(action: {
            }) {
                HStack{
                    Image(systemName: "trash").scaleEffect(1, anchor: .center)
                    Spacer()
                    Text("删除公钥")
                }
            }
        })
    }
}
