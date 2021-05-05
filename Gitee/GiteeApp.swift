//
//  GiteeApp.swift
//  Gitee
//
//  Created by Hamm on 2021/4/23.
//

import SwiftUI

@main
struct GiteeApp: App {
    var body: some Scene {
        WindowGroup {
            TabBarView(selectedBarIndex: 0)
                .preferredColorScheme(.dark)
        }
    }
}
