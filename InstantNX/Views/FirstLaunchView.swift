//
//  FirstLaunchView.swift
//  InstantNX
//
//  Created by devonly on 2025/08/09.
//  Copyright © 2025 QuantumLeap. All rights reserved.
//

import Foundation
import QuantumLeap
import SwiftUI
import SwiftUIIntrospect

struct FirstLaunchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selection: Int = 0

    var body: some View {
        TabView(selection: $selection, content: {
            FirstLaunch(content: {
                VStack(spacing: 24, content: {
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
                })
            })
            .tag(0)
            FirstLaunch(content: {
                VStack(spacing: 24, content: {
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
                })
            })
            .tag(1)
            FirstLaunch(content: {
                VStack(spacing: 24, content: {
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
                })
            })
            .tag(2)
            FirstLaunch(content: {
                VStack(spacing: 24, content: {
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
                })
            })
            .tag(3)
            FirstLaunch(content: {
                VStack(spacing: 24, content: {
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
                })
            })
            .tag(4)
        })
        .tabViewStyle(.page(indexDisplayMode: .never))
        .overlay(alignment: .bottom, content: {
            Button(action: {
                withAnimation(.spring) {
                    selection != 4 ? selection += 1 : dismiss()
                }
            }, label: {
                Text(selection != 4 ? "BUTTON_NEXT" : "BUTTON_END")
                    .fontWeight(.bold)
                    .frame(width: 300, height: 40)
                    .buttonStyle(.borderedProminent)
            })
            .buttonStyle(.borderedProminent)
        })
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

#Preview {
    FirstLaunchView()
}
