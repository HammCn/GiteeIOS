//
//  UserItemView.swift
//  Gitee
//
//  Created by Hamm on 2021/5/2.
//

import SwiftUI

struct UserItemView:View{
    @State var userItem: UserItemModel
    @State var placeholderImage = UIImage(named: "nohead")!
    var body: some View{
        VStack(alignment: .leading){
            HStack(){
                Image(uiImage: placeholderImage)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width:50,height:50,
                        alignment: .center
                    )
                    .cornerRadius(5)
                    .onAppear(){
                        guard let url = URL(string: userItem.userHead) else {
                            return
                        }
                        URLSession.shared.dataTask(with: url) { (data, response, error) in
                            if let data = data, let image = UIImage(data: data) {
                                placeholderImage = image
                            }
                        }.resume()
                    }
                VStack(alignment: .leading){
                    Text(userItem.userName).font(.system(size: 16))
                    Text("@" + userItem.userAccount).font(.system(size: 14))
                        .foregroundColor(Color(hex: 0xaaaaaa))
                        .lineLimit(1)
                        .padding(.top,1)
                }
                Spacer()
            }
            .padding(10)
        }
        .background(Color(red: 1, green: 1, blue: 1, opacity: 0.1))
        .cornerRadius(10)
        .padding(.horizontal,5)
        .padding(.bottom,-3)
    }
}
