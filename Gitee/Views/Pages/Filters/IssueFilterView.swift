//
//  IssueFilterView.swift
//  Gitee
//
//  Created by Hamm on 2021/4/23.
//

import SwiftUI


struct IssueFilterView: View {
    @Environment(\.presentationMode) var mode
    @State var filter = 0;
    @State var filterList = ["所有来源的Issues","只显示指派给我的","只显示我创建的"];
    @State var filterKey = ["all","assigned","created"];
    @State var state = 1;
    @State var stateList = ["所有状态的Issues","只显示已开启的","只显示进行中的","只显示已完成的","只显示被拒绝的"];
    @State var stateKey = ["all","open","progressing","closed","rejected"];
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
                    Picker(selection: self.$filter, label: Text("Issues来源")) {
                        ForEach(0 ..< self.filterList.count){
                            Text(self.filterList[$0]).tag($0)
                        }
                    }
                    Picker(selection: self.$state, label: Text("当前状态")) {
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
            .navigationBarTitle(Text("筛选Issues"), displayMode: .large)
            .navigationBarItems(trailing:
                                    Button(action: {
                                        // 存储这部分配置
                                        localConfig.setValue(self.filterKey[self.filter], forKey: giteeConfig.issue_filter)
                                        localConfig.setValue(self.stateKey[self.state], forKey: giteeConfig.issue_state)
                                        localConfig.setValue(self.sortKey[self.sort], forKey: giteeConfig.issue_sort)
                                        localConfig.setValue(self.directionKey[self.direction], forKey: giteeConfig.issue_direction)
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
