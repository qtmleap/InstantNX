//
//  ContentView.swift
//  InstantNX
//
//  Created by devonly on 2024/10/12.
//

import CodeScanner
import NetworkExtension
import SwiftUI

struct ContentView: View {
    @AppStorage("IS_FIRST_LAUNCH") private var isFirstLaunch: Bool = true

    // MARK: Internal

    var body: some View {
        TabView(content: {
            NavigationView(content: {
                GalleryView()
            })
            .tag(0)
            .tabItem {
                Label("アルバム", systemImage: "photo.fill.on.rectangle.fill")
            }
            NavigationView(content: {
                SettingsView()
            })
            .tag(1)
            .tabItem {
                Label("設定", systemImage: "gear")
            }
        })
        .sheet(isPresented: $isFirstLaunch, content: {
            FirstLaunchView()
                .interactiveDismissDisabled(true)
        })
    }

    // MARK: Private

    @State private var isPresented: Bool = false
}

#Preview {
    ContentView()
}
