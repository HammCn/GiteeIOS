//
//  LoadingView.swift
//  Gitee
//
//  Created by Hamm on 2021/4/23.
//

import SwiftUI

struct LoadingView<Content>: View where Content: View {
    
    @Binding var isLoading: Bool
    @Binding var message:String
    @Binding var isModal: Bool
    @State var isAnimating: Bool = true
    var content: () -> Content
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                self.content()
                    .disabled(self.isModal)
                    .blur(radius: self.isModal ? 10 : 0)
                VStack {
                    Text(self.message)
                        .padding(.bottom,20)
                    ActivityIndicatorLoading(isAnimating: self.$isAnimating, style: .large)
                }
                    
                .frame(width: geometry.size.width / 2,
                       height: geometry.size.height / 5)
                    .background(Color.secondary.colorInvert())
                    .foregroundColor(Color.primary)
                    .cornerRadius(20)
                    .opacity(self.isLoading ? 1 : 0)
                
            }
        }
    }
}
