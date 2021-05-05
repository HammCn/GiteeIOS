//
//  OrganizationView.swift
//  Gitee
//
//  Created by Hamm on 2021/5/4.
//

import SwiftUI
import SwiftyJSON
import SwipeCell

struct OrganizationView: View {
    @State var orgList: [OrgModel] = []
    @State var waitPlease = false
    @State var isRefreshing = false
    @State var isLoading: Bool = false
    @State var isModal: Bool = false
    @State var message: String = "数据加载中"
    @State var page = 1
    var body: some View {
        LoadingView(isLoading:self.$isLoading,message: self.$message,isModal:self.$isModal) {
            ZStack{
                if orgList.count == 0 && !isLoading {
                    VStack{
                        Image(systemName: "doc.text.magnifyingglass")
                            .scaleEffect(3, anchor: .center)
                        Text("暂无查询到的组织").padding(.top,30)
                    }
                }
                RefreshView(refreshing: $isRefreshing, action: {
                    self.page = 1
                    self.getOrgList(page: self.page)
                }) {
                    LazyVStack{
                        ForEach(self.orgList){ item in
                            OrgItemView(orgItem: item)
                                .onAppear(){
                                    if !waitPlease && item.id == orgList[orgList.count - 1].id {
                                        self.page = self.page + 1
                                        self.getOrgList(page: self.page)
                                    }
                                }
                        }
                    }
                }
            }
        }
        .padding(.top,5)
        .navigationBarTitle(Text("你的组织"), displayMode: .inline)
        .onAppear(){
            self.page = 1
            self.getOrgList(page: self.page)
        }
    }
    func getOrgList(page: Int){
        if self.waitPlease { return }
        self.waitPlease = true
        if orgList.count == 0 {
            self.isLoading = true
        }
        let url = "user/orgs?page=" + String(page)
        
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
                    var tempList = self.orgList
                    if page == 1{
                        tempList = []
                    }
                    for (_,subJson):(String, JSON) in json {
                        tempList.append(OrgModel(id: subJson["id"].intValue, account: subJson["login"].stringValue, name: subJson["name"].stringValue, head: subJson["avatar_url"].stringValue, desc: subJson["description"].stringValue, fans: subJson["follow_count"].intValue))
                        print(subJson["name"].stringValue)
                    }
                    self.orgList = tempList
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

struct OrgItemView:View{
    @State var orgItem: OrgModel
    @State var placeholderImage = UIImage(named: "Logo")!
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
                            width:80,height:80,
                            alignment: .center
                        )
                        .cornerRadius(10)
                        .onAppear(){
                            guard let url = URL(string: orgItem.head) else {
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
                            Text(orgItem.name)
                                .padding(0)
                            Spacer()
                            Text("粉丝:" + String(orgItem.fans)).font(.system(size:12)).foregroundColor(.gray)
                        }
                        Text(orgItem.desc).font(.system(size:14)).foregroundColor(.gray)
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
            .contextMenu(ContextMenu {
                Button(action: {
                    UIAlertController.alert(message: "一个人开发实在有点慢，要不要来帮帮忙~", title: "Comming soon...", confirmText: "Sure")
                }) {
                    HStack{
                        Image(systemName: "archivebox.circle").scaleEffect(1, anchor: .center)
                        Spacer()
                        Text("组织开源项目")
                    }
                }
                Button(action: {
                    UIAlertController.alert(message: "一个人开发实在有点慢，要不要来帮帮忙~", title: "Comming soon...", confirmText: "Sure")
                }) {
                    HStack{
                        Image(systemName: "archivebox.circle").scaleEffect(1, anchor: .center)
                        Spacer()
                        Text("组织私有项目")
                    }
                }
                Divider()
                Button(action: {
                    UIAlertController.alert(message: "一个人开发实在有点慢，要不要来帮帮忙~", title: "Comming soon...", confirmText: "Sure")
                }) {
                    HStack{
                        Image(systemName: "exclamationmark.circle").scaleEffect(1, anchor: .center)
                        Spacer()
                        Text("查看Issues")
                    }
                }
//                Button(action: {
//                }) {
//                    HStack{
//                        Image(systemName: "shuffle.circle").scaleEffect(1, anchor: .center)
//                        Spacer()
//                        Text("查看Pull Requests")
//                    }
//                }
                Divider()
                Button(action: {
                    UIAlertController.alert(message: "一个人开发实在有点慢，要不要来帮帮忙~", title: "Comming soon...", confirmText: "Sure")
                }) {
                    HStack{
                        Image(systemName: "person.2.circle").scaleEffect(1, anchor: .center)
                        Spacer()
                        Text("查看仓库成员")
                    }
                }
                Button(action: {
                    UIAlertController.alert(message: "一个人开发实在有点慢，要不要来帮帮忙~", title: "Comming soon...", confirmText: "Sure")
                }) {
                    HStack{
                        Image(systemName: "person.circle").scaleEffect(1, anchor: .center)
                        Spacer()
                        Text("修改组织资料")
                    }
                }
                Divider()
                Button(action: {
                    UIAlertController.alert(message: "一个人开发实在有点慢，要不要来帮帮忙~", title: "Comming soon...", confirmText: "Sure")
                }) {
                    HStack{
                        Image(systemName: "trash").scaleEffect(1, anchor: .center)
                        Spacer()
                        Text("退出或解散组织")
                    }
                }
            })
        }
    }
}
