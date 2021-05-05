//
//  MailView.swift
//  Gitee
//
//  Created by Hamm on 2021/5/4.
//

import SwiftUI
import SwiftyJSON
import SwipeCell

struct MailView: View {
    @State var mailList: [MailModel] = []
    @State var waitPlease = false
    @State var isRefreshing = false
    @State var isLoading: Bool = false
    @State var isModal: Bool = false
    @State var message: String = "数据加载中"
    @State var page = 1
    var body: some View {
        LoadingView(isLoading:self.$isLoading,message: self.$message,isModal:self.$isModal) {
            ZStack{
                if mailList.count == 0 && !isLoading {
                    VStack{
                        Image(systemName: "doc.text.magnifyingglass")
                            .scaleEffect(3, anchor: .center)
                        Text("暂无查询到的私信").padding(.top,30)
                    }
                }
                RefreshView(refreshing: $isRefreshing, action: {
                    self.page = 1
                    self.getMailList(page: self.page)
                }) {
                    LazyVStack{
                        ForEach(self.mailList){ item in
                            MailItemView(mailItem: item)
                                .onAppear(){
                                    if !waitPlease && item.id == mailList[mailList.count - 1].id {
                                        self.page = self.page + 1
                                        self.getMailList(page: self.page)
                                    }
                                }
                        }
                    }
                }
            }
        }
        .padding(.top,5)
        .navigationBarTitle(Text("你的私信"), displayMode: .inline)
        .onAppear(){
            self.page = 1
            self.getMailList(page: self.page)
        }
    }
    func getMailList(page: Int){
        if self.waitPlease { return }
        self.waitPlease = true
        if mailList.count == 0 {
            self.isLoading = true
        }
        let url = "notifications/messages?page=" + String(page)
        
        HttpRequest(url: url, withAccessToken: true)
            .doGet { (value) in
                let json = JSON(value)
                if json["message"].string != nil {
                    print("error")
                    DispatchQueue.main.async {
                        UIAlertController.confirm(message: json["message"].stringValue, title: "发生错误", confirmText: "重新登录", cancelText: "返回") { (action) in
                            Helper.relogin()
                        }
                    }
                }else{
                    var tempList = self.mailList
                    if page == 1{
                        tempList = []
                    }
                    for (_,subJson):(String, JSON) in json["list"] {
                        let userInfo:UserItemModel = UserItemModel(id: subJson["sender"]["id"].intValue, userHead: subJson["sender"]["avatar_url"].stringValue, userName: subJson["sender"]["name"].stringValue, userAccount: subJson["sender"]["login"].stringValue)
                        tempList.append(MailModel(id: subJson["id"].intValue, user: userInfo, message: subJson["content"].stringValue, time: Helper.getDateFromString(str: subJson["updated_at"].stringValue), isUnRead: subJson["unread"].boolValue))
                    }
                    self.mailList = tempList
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

struct MailItemView:View{
    @State var mailItem: MailModel
    @State var placeholderImage = UIImage(named: "Logo")!
    @State var isMessageReplyShow:Bool = false
    var body: some View{
        ZStack{
            VStack{

            }
            .frame(width: 0, height: 0)
            .opacity(0)
            VStack{
                HStack(alignment: .top) {
                    Image(uiImage: placeholderImage)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width:40,height:40,
                            alignment: .center
                        )
                        .cornerRadius(5)
                        .onAppear(){
                            guard let url = URL(string: mailItem.user.userHead) else {
                                return
                            }
                            URLSession.shared.dataTask(with: url) { (data, response, error) in
                                if let data = data, let image = UIImage(data: data) {
                                    placeholderImage = image
                                }
                            }.resume()
                        }
                    VStack(alignment: .leading){
                        HStack(alignment:.top){
                            Text(mailItem.user.userName)
                                .padding(0)
                            Spacer()
                            Text(mailItem.time).font(.system(size:12)).foregroundColor(.gray)
                        }
                        Text(mailItem.message).font(.system(size:14)).foregroundColor(.gray)
                            .padding(.top,1)
                            .lineLimit(10)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(10)
            }
            .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
            .cornerRadius(10)
            .padding(.horizontal,5)
            .padding(.bottom,-3)
            .onTapGesture {
                self.isMessageReplyShow = true
            }
            .sheet(isPresented: $isMessageReplyShow,onDismiss: {
                //TODO
            }){
                MailReplyView(user: mailItem.user)
            }
        }
    }
}
