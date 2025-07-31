//
//  ContentView.swift
//  InstantNX
//
//  Created by devonly on 2024/10/12.
//

import AlertToast
import CodeScanner
import NetworkExtension
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var client: NXClient
    @Environment(\.isFirstLaunch) private var isFirstLaunch

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
                HistoryView()
            })
            .tag(1)
            .tabItem {
                Label("履歴", systemImage: "clock")
            }
            NavigationView(content: {
                SettingsView()
            })
            .tag(2)
            .tabItem {
                Label("設定", systemImage: "gear")
            }
        })
        .sheet(isPresented: isFirstLaunch, content: {
            FirstLaunchView()
                .interactiveDismissDisabled(true)
        })
        .toast(isPresenting: $client.isConnecting, alert: {
            AlertToast(displayMode: .alert, type: .loading, title: "Nintendo Switchに接続中")
        })
        .confirmationDialog("保存成功しました", isPresented: $client.isCompleted, titleVisibility: .visible, actions: {
            Button(role: .cancel, action: {}, label: {
                Text("キャンセル")
            })
            Button(action: {
                UIApplication.shared.open(URL(string: "photos-redirect://")!)
            }, label: {
                Text("アルバムを開く")
            })
        })
    }
}

#Preview {
    ContentView()
}
