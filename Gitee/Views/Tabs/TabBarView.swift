//
//  TabBarView.swift
//  Gitee
//
//  Created by Hamm on 2021/4/20.
//

import Foundation
import SwiftUI
import UIKit

var localConfig = UserDefaults.standard

struct TabBarView: View {
    @State var selectedBarIndex:Int
    
    var body: some View {
        NavigationView{
            TabView(selection: $selectedBarIndex) {
                HomeView()
                .tabItem {
                    Image(systemName:"briefcase")
                    Text("首页")
                }
                    .tag(0)
                ActivityView()
                .tabItem {
                    Image(systemName:"stopwatch")
                    Text("动态")
                }
                    .tag(1)
                ExploreView()
                .tabItem {
                    Image(systemName:"opticaldisc")
                    Text("发现")
                }
                    .tag(2)
                SettingView()
                .tabItem {
                    Image(systemName:"gearshape")
                    Text("设置")
                }
                    .tag(3)
            }
            .navigationBarTitle(getNavBarTitle(),displayMode: getNavBarModel())
            .navigationBarHidden(self.selectedBarIndex==3)
            .foregroundColor(.white)
            .accentColor(.white) //这里修改文字颜色
        }
        .onAppear(){
        }
        .accentColor(.white)
        .foregroundColor(.white)
        .preferredColorScheme(.dark)
    }
    func getNavBarModel() -> NavigationBarItem.TitleDisplayMode{
        if self.selectedBarIndex == 0 {
            return .large
        }
        if self.selectedBarIndex == 1 {
            return .inline
        }
        if self.selectedBarIndex == 2 {
            return .large
        }
        if self.selectedBarIndex == 3 {
            return .large
        }
        return .inline
    }
    func getNavBarTitle() -> String{
        if self.selectedBarIndex == 0 {
            return "Gitee"
        }
        if self.selectedBarIndex == 1 {
            return "好友动态"
        }
        if self.selectedBarIndex == 2 {
            return "发现"
        }
        if self.selectedBarIndex == 3{
            return "设置"
        }
        return  ""
    }
}
