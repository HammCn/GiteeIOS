//
//  RefreshView.swift
//  Gitee
//
//  Created by Hamm on 2021/5/1.
//

import SwiftUI

struct RefreshView<Content: View>: View {
    @State private var previousScrollOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var rotation: Angle = .degrees(0)
    @State private var pleaseCallback:Bool = false
    
    var threshold: CGFloat = 50
    @Binding var refreshing: Bool
    let content: Content
    public typealias Action = ()->Void
    let action: Action?
    @State var fixedMinY: CGFloat = 0
    
    public init(refreshing: Binding<Bool>, action: Action? = nil, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.action = action
        self._refreshing = refreshing
    }
    
    public var body: some View {
        VStack {
            ScrollView {
                ZStack(alignment: .top) {
                    MovingView()
                    VStack {
                        self.content
                    }
                    .alignmentGuide(.top, computeValue: { d in 0})
                    .animation(.default, value: false)
                    SymbolView(height: self.threshold,
                               refreshing: self.refreshing,
                               rotation: self.rotation,
                               offset: self.scrollOffset, pleaseCallback: self.pleaseCallback)
                    
                }
            }
            .background(FixedView())
            .onPreferenceChange(RefreshableKeyTypes.PrefKey.self) { values in
                self.refreshLogic(values: values)
            }
        }
    }
    
    func refreshLogic(values: [RefreshableKeyTypes.PrefData]) {
        DispatchQueue.main.async {
            let movingBounds = values.first { $0.vType == .movingView }?.bounds ?? .zero
            let fixedBounds = values.first { $0.vType == .fixedView }?.bounds ?? .zero
            self.fixedMinY = fixedBounds.minY
            self.scrollOffset  = movingBounds.minY - fixedBounds.minY
            self.rotation = self.symbolRotation(self.scrollOffset)
            if self.scrollOffset > self.threshold {
                self.pleaseCallback = true
            }
            if self.scrollOffset == 0 && self.pleaseCallback{
                self.action?()
                self.pleaseCallback = false
            }
        }
    }
    
    func symbolRotation(_ scrollOffset: CGFloat) -> Angle {
        if scrollOffset < self.threshold * 0.60 {
            return .degrees(0)
        } else {
            let h = Double(self.threshold)
            let d = Double(scrollOffset)
            let v = max(min(d - (h * 0.6), h * 0.4), 0)
            return .degrees(180 * v / (h * 0.4))
        }
    }
    
    struct SymbolView: View {
        var height: CGFloat
        var refreshing: Bool
        var rotation: Angle
        var offset: CGFloat
        var pleaseCallback: Bool
        
        private func pullView() -> some View {
            return VStack {
                Spacer()
                HStack {
                    Image(systemName: "circle.grid.cross.left.fill")
                        .resizable()
                        .foregroundColor(.secondary)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20).fixedSize()
                        .padding(20)
                        .rotationEffect(rotation)
                }
                Spacer()
            }
            .frame(height: height)
            .fixedSize()
            .animation(.easeInOut(duration: 0.5))
            .offset(y: -height)
        }
        
        var body: some View {
            Group {
                if self.pleaseCallback {
                    VStack {
                        Spacer()
                        ActivityRep()
                        Spacer()
                    }
                    .frame(height: height).fixedSize()
                    .offset(y: -height)
                }else{
                    pullView()
                }
            }
        }
    }
    
    struct MovingView: View {
        var body: some View {
            GeometryReader { proxy in
                Color.clear.preference(key: RefreshableKeyTypes.PrefKey.self, value: [RefreshableKeyTypes.PrefData(vType: .movingView, bounds: proxy.frame(in: .global))])
            }.frame(height: 0)
        }
    }
    
    struct FixedView: View {
        var body: some View {
            GeometryReader { proxy in
                Color
                    .clear
                    .preference(key: RefreshableKeyTypes.PrefKey.self, value: [RefreshableKeyTypes.PrefData(vType: .fixedView, bounds: proxy.frame(in: .global))])
            }
        }
    }
    
    public struct ActivityRep: UIViewRepresentable {
        public init() {}
        public func makeUIView(context: UIViewRepresentableContext<ActivityRep>) -> UIActivityIndicatorView {
            return UIActivityIndicatorView()
        }
        
        public func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityRep>) {
            uiView.startAnimating()
        }
    }
    
    public enum ScrollType {
        case scrollView
        case list
    }
    
}

struct RefreshableKeyTypes {
    enum ViewType: Int {
        case movingView
        case fixedView
    }
    
    struct PrefData: Equatable {
        let vType: ViewType
        let bounds: CGRect
    }
    
    struct PrefKey: PreferenceKey {
        static var defaultValue: [PrefData] = []
        
        static func reduce(value: inout [PrefData], nextValue: () -> [PrefData]) {
            value.append(contentsOf: nextValue())
        }
        
        typealias Value = [PrefData]
    }
}
