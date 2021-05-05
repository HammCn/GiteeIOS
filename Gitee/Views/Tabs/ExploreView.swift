//
//  ExploreView.swift
//  Gitee
//
//  Created by Hamm on 2021/4/19.
//

import SwiftUI

struct ExploreView: View {    var body: some View {
        Text("说实话\n\n\n这里是预留的产品位置\n\n我还不知道要做什么")
        .preferredColorScheme(.dark)
        .onAppear(){
//            self.tabBar.hidden = false
            let access_token = localConfig.string(forKey: giteeConfig.access_token)
            if(access_token==nil){
                print("need login")
            }else{
                print("success")
            }
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}




