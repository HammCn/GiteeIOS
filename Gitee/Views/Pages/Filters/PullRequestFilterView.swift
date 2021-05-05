//
//  PullRequestFilterView.swift
//  Gitee
//
//  Created by Hamm on 2021/4/28.
//

import SwiftUI

struct PullRequestFilterView: View {
    @Environment(\.presentationMode) var mode
    @State var state = 1;
    @State var stateList = ["全部的Pull Requests","只显示等待合并的请求","只显示已合并的请求","只显示已拒绝合并的请求"];
    @State var stateKey = ["all","open","merged","closed"];
    @State var sort = 0;
    @State var sortList = ["创建时间","更新时间"];
    @State var sortKey = ["created","updated"];
    @State var direction = 0;
    @State var directionList = ["从最新开始","从最早开始"];
    @State var directionKey = ["desc","asc"];
    var body: some View {
        NavigationView{
            Form{
                Section(header: Text("条件")) {
                    Picker(selection: self.$state, label: Text("请求状态")) {
                        ForEach(0 ..< self.stateList.count){
                            Text(self.stateList[$0]).tag($0)
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
            .navigationBarTitle(Text("筛选Pull Requests"), displayMode: .large)
            .navigationBarItems(trailing:
                                    Button(action: {
                                        // 存储这部分配置
                                        localConfig.setValue(self.stateKey[self.state], forKey: giteeConfig.pull_request_state)
                                        localConfig.setValue(self.sortKey[self.sort], forKey: giteeConfig.pull_request_sort)
                                        localConfig.setValue(self.directionKey[self.direction], forKey: giteeConfig.pull_request_direction)
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
