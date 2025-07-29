//
//  SettingsView.swift
//  InstantNX
//
//  Created by devonly on 2024/10/13.
//  Copyright © 2024 Magi, Corporation. All rights reserved.
//

import BetterSafariView
import Foundation
import LicenseList
import StoreKit
import SwiftUI

struct InAppBrowserLink<Label: View>: View {
    @State private var isPresented: Bool = false
    let url: URL
    let label: () -> Label

    init(url: URL, @ViewBuilder label: @escaping () -> Label) {
        self.url = url
        self.label = label
    }

    var body: some View {
        Button(action: {
            isPresented.toggle()
        }, label: {
            label()
        })
        .safariView(isPresented: $isPresented, content: {
            SafariView(url: url)
                .preferredBarAccentColor(.clear)
                .preferredControlAccentColor(.accentColor)
                .dismissButtonStyle(.done)
        })
    }
}

struct SettingsView: View {
    @EnvironmentObject private var client: NXClient
    @AppStorage("IS_FIRST_LAUNCH") private var isFirstLaunch: Bool = true

    var body: some View {
        Form(content: {
            Section(content: {
                Toggle(isOn: $client.isAutoSaveEnabled, label: {
                    Text("自動保存")
                })
                .toggleStyle(.switch)
            }, header: {
                Text("動作")
            }, footer: {
                Text("アプリの動作を変更することができます")
            })
            Section(content: {
                InAppBrowserLink(url: URL(string: "https://qleap.jp/term/eula")!, label: {
                    Text("利用規約")
                })
                InAppBrowserLink(url: URL(string: "https://qleap.jp/term/privacy_policy")!, label: {
                    Text("プライバシーポリシー")
                })
                NavigationLink(destination: {
                    LicenseListView()
                        .navigationTitle("ライセンス")
                        .navigationBarTitleDisplayMode(.inline)
                }, label: {
                    Text("ライセンス")
                })
            }, header: {
                Text("ライセンス")
            })
            Section(content: {
                Button(action: {
                    isFirstLaunch.toggle()
                }, label: {
                    Text("アプリの使い方")
                })
                Button(action: {
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                }, label: {
                    Text("アプリを評価する")
                })
                HStack(content: {
                    Text("バージョン")
                    Spacer()
                    Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                })
                HStack(content: {
                    Text("ビルド番号")
                    Spacer()
                    Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                })
            }, header: {
                Text("アプリ情報")
            })
        })
        .navigationTitle("設定")
        .navigationBarTitleDisplayMode(.inline)
    }
}
