//
//  ChessClockApp.swift
//  InstantNX
//
//  Created by devonly on 2025/08/09.
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
            FirstLaunchPage5View()
                .tag(4)
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
            Text("TEXT_HOW_TO_USE_THE_APP")
                .font(.title)
                .fontWeight(.bold)
            Text("TEXT_SCAN_QRCODE_AND_SELECT_IMAGES")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
    }
}

struct FirstLaunchPage2View: View {
    var body: some View {
        VStack(spacing: 24) {
            Image("Album")
                .resizable()
                .scaledToFit()
                .frame(height: 140)
            Text("TEXT_SELECT_FROM_ALBUM")
                .font(.title2)
                .fontWeight(.bold)
            Text("TEXT_SELECT_VIDEO_ONCE_IMAGE_UP_TO_TEN")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
    }
}

struct FirstLaunchPage3View: View {
    var body: some View {
        VStack(spacing: 24) {
            Image("QRcode")
                .resizable()
                .scaledToFit()
                .frame(height: 140)
            Text("TEXT_GENERATE_QRCODE_AND_SCAN")
                .font(.title2)
                .fontWeight(.bold)
            Text("TEXT_SCAN_GENERATED_QRCODE")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
    }
}

struct FirstLaunchPage4View: View {
    var body: some View {
        VStack(spacing: 24) {
            Image("Gallery")
                .resizable()
                .scaledToFit()
                .frame(height: 140)
            Text("TEXT_AUTO_ADD_TO_ALBUM")
                .font(.title2)
                .fontWeight(.bold)
            Text("TEXT_SELECTED_FILES_AUTO_ADDED_TO_ALBUM")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
    }
}

struct FirstLaunchPage5View: View {
    var body: some View {
        VStack(spacing: 24) {
            Image("Share")
                .resizable()
                .scaledToFit()
                .frame(height: 140)
            Text("TEXT_SHARE_WITH_FAMILY_AND_FRIENDS")
                .font(.title2)
                .fontWeight(.bold)
            Text("TEXT_SHARED_FROM_ALBUM_TO_SNS")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
    }
}

#Preview {
    FirstLaunchView()
}
