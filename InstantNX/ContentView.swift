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
                Label("LABEL_GALLERY", systemImage: "photo.fill.on.rectangle.fill")
            }
//            NavigationView(content: {
//                HistoryView()
//            })
//            .tag(1)
//            .tabItem {
//                Label("履歴", systemImage: "clock")
//            }
            NavigationView(content: {
                SettingsView()
            })
            .tag(2)
            .tabItem {
                Label("LABEL_SETTING", systemImage: "gear")
            }
        })
        .sheet(isPresented: isFirstLaunch, content: {
            FirstLaunchView()
                .interactiveDismissDisabled(true)
        })
        .toast(isPresenting: client.isConnecting, alert: {
            AlertToast(displayMode: .hud, type: .loading, title: String(localized: client.status.rawValue))
        })
        .confirmationDialog("SAVE_SUCCESSFULLY", isPresented: $client.isCompleted, titleVisibility: .visible, actions: {
            Button(role: .cancel, action: {}, label: {
                Text("TEXT_CANCEL")
            })
            Button(action: {
                UIApplication.shared.open(URL(string: "photos-redirect://")!)
            }, label: {
                Text("TEXT_OPEN_PHOTO_LIBRARY")
            })
        })
    }
}

#Preview {
    ContentView()
}
