//
//  AboutView.swift
//  Gitee
//
//  Created by Hamm on 2021/5/2.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack{
            Spacer()
            Image("white_icon")
                .resizable()
                .frame(width: 160,height: 160)
            Text("Gitee")
                .font(.system(size: 40))
                .fontWeight(.bold)
                .padding(.top,-20)
            Text("v1.0 Beta")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .padding(.bottom,100)
            Spacer()
            Text("Written by @Hamm")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            Text("Release under MulanPSL v2 on Gitee")
                .font(.system(size: 12))
                .foregroundColor(.gray)        }
        .navigationBarItems(
            trailing:
                HStack {
                    Link(destination: URL(string: "https://gitee.com/hamm")!) {
                        Text("开源仓库")
                    }
                }
        )
    }
}
