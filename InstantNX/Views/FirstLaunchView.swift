//
//  FirstLaunchView.swift
//  Instant NX
//
//  Created by devonly on 2025/07/25.
//  Copyright © 2025 QuantumLeap. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftUIIntrospect

struct FirstLaunchView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        TabView(content: {
            FirstLaunchPage1View()
                .tag(0)
            FirstLaunchPage2View()
                .tag(1)
            FirstLaunchPage3View()
                .tag(2)
            FirstLaunchPage4View()
                .tag(3)
        })
        .tabViewStyle(.page)
        .introspect(.pageControl, on: .iOS(.v14, .v15, .v16, .v17, .v18)) { pageControl in
            pageControl.currentPageIndicatorTintColor = .red
            pageControl.pageIndicatorTintColor = .gray
        }
        .overlay(alignment: .topTrailing, content: {
            Button(action: {
                dismiss()
            }, label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
            })
            .padding()
        })
    }
}

struct FirstLaunchPage1View: View {
    var body: some View {
        VStack(spacing: 24) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(height: 140)
            Text("アプリの使い方")
                .font(.title)
                .fontWeight(.bold)
            Text("スマートフォンでQRコードを読み込んで画像や動画を転送したり、SNSに投稿することができます")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct FirstLaunchPage2View: View {
    var body: some View {
        VStack(spacing: 24) {
            Image("Scan")
                .resizable()
                .scaledToFit()
                .frame(height: 140)
            Text("アルバムから画像や動画を選択")
                .font(.title2)
                .fontWeight(.bold)
            Text("動画は一件、画像は最大十件まで選択できます")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct FirstLaunchPage3View: View {
    var body: some View {
        VStack(spacing: 24) {
            Image("Result")
                .resizable()
                .scaledToFit()
                .frame(height: 140)
            Text("QRコードを発行して読取り")
                .font(.title2)
                .fontWeight(.bold)
            Text("発行されたQRコードを読取ります")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct FirstLaunchPage4View: View {
    var body: some View {
        VStack(spacing: 24) {
            Image("Share")
                .resizable()
                .scaledToFit()
                .frame(height: 180)
            Text("家族や友人と情報を共有できます")
                .font(.title2)
                .fontWeight(.bold)
            Text("読み取った内容は簡単にシェアできます")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    FirstLaunchView()
}
