//
//  ContentView.swift
//  InstantNX
//
//  Created by devonly on 2024/10/12.
//  Copyright © 2025 QuantumLeap. All rights reserved.
//

import AlertToast
import CodeScanner
import NetworkExtension
import SwiftUI
import SwiftUIIntrospect

struct ContentView: View {
    @EnvironmentObject private var client: NXClient
    @Environment(\.isFirstLaunch) private var isFirstLaunch

    var body: some View {
        TabView(content: {
            NavigationView(content: {
                GalleryView()
            })
            .navigationViewStyle(.stack)
            .tag(0)
            .tabItem {
                Label("LABEL_GALLERY", systemImage: "photo.fill.on.rectangle.fill")
            }
            NavigationView(content: {
                SettingsView()
            })
            .introspect(.navigationSplitView, on: .iOS(.v16, .v17, .v18)) { view in
                view.preferredDisplayMode = .oneBesideSecondary
                view.preferredSplitBehavior = .tile
                view.presentsWithGesture = true
            }
            .tag(2)
            .tabItem {
                Label("LABEL_SETTING", systemImage: "gear")
            }
        })
        .tabViewStyle(.automatic)
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
