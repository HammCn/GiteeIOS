//
//  RepoFilterView.swift
//  Gitee
//
//  Created by Hamm on 2021/4/23.
//

import SwiftUI

struct RepoFilterView: View {
    @Environment(\.presentationMode) var mode
    @State var type = 0;
    @State var typeList = ["全部有权限的仓库","我创建的仓库","我个人的仓库","我加入的仓库","我私有的仓库","我开源的仓库"];
    @State var typeKey = ["all","owner","personal","member","private","public"];
    @State var sort = 0;
    @State var sortList = ["最后推送时间","创建时间","更新时间","仓库所属与名称"];
    @State var sortKey = ["pushed","created","updated","full_name"];
    @State var direction = 0;
    @State var directionList = ["从最新开始","从最早开始"];
    @State var directionKey = ["desc","asc"];
    var body: some View {
        NavigationView{
            Form{
                Section(header: Text("条件")) {
                    Picker(selection: self.$type, label: Text("仓库归属")) {
                        ForEach(0 ..< self.typeList.count){
                            Text(self.typeList[$0]).tag($0)
                        }
                    }
                }
                Section(header: Text("排序")) {
                    Picker(selection: self.$sort, label: Text("排序依据")) {
                        ForEach(0 ..< self.sortList.count){
                            Text(self.sortList[$0]).tag($0)
                        }
                    }
                    Picker(selection: self.$direction, label: Text("排序方式")) {
                        ForEach(0 ..< self.directionList.count){
                            Text(self.directionList[$0]).tag($0)
                        }
                    }
                }
            }
            .navigationBarTitle(Text("筛选你的仓库"), displayMode: .large)
            .navigationBarItems(trailing:
                                    Button(action: {
                                        // 存储这部分配置
                                        localConfig.setValue(self.typeKey[self.type], forKey: giteeConfig.repo_type)
                                        localConfig.setValue(self.sortKey[self.sort], forKey: giteeConfig.repo_sort)
                                        localConfig.setValue(self.directionKey[self.direction], forKey: giteeConfig.repo_direction)
                                        self.mode.wrappedValue.dismiss()
                                    }) {
                                        Text("筛选").foregroundColor(.yellow)
                                    })
        }
        .onAppear(){
            
        }
        .preferredColorScheme(.dark)
    }
}
