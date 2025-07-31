//
//  GalleryView.swift
//  InstantNX
//
//  Created by devonly on 2025/07/29.
//  Copyright © 2025 Magi, Corporation. All rights reserved.
//

import AVFoundation
import CodeScanner
import Foundation
import LinkPresentation
import SDWebImageSwiftUI
import SwiftUI

struct GalleryListItem: View {
    @Binding var content: ContentItem

    var body: some View {
        Button(action: {
            content.isSelected.toggle()
        }, label: {
            Image(uiImage: content.image)
                .resizable()
                .scaledToFit()
        })
        .buttonStyle(.plain)
        .overlay(content: {
            Rectangle()
                .strokeBorder(content.isSelected ? Color.red : Color.primary, lineWidth: 2, antialiased: true)
        })
    }
}

struct GalleryView: View {
    @EnvironmentObject private var client: NXClient
    @State private var isPresented: Bool = false
    @State private var isScanPresented: Bool = false

    var GalleryEmpty: some View {
        VStack(content: {
            Image("QRcode")
                .resizable()
                .scaledToFit()
                .frame(height: 140)
                .padding(.bottom)
            Text("QRコードを読み込んでください")
                .font(.title2)
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var GalleryList: some View {
        ScrollView(content: {
            LazyVGrid(columns: .init(repeating: .init(.flexible()), count: 2), content: {
                ForEach($client.contents, id: \.self, content: { content in
                    GalleryListItem(content: content)
                })
            })
        })
    }

    var body: some View {
        Group(content: {
            if client.contents.isEmpty {
                GalleryEmpty
            } else {
                GalleryList
            }
        })
        .overlay(alignment: .bottomTrailing, content: {
            VStack(content: {
                Button(action: {
                    isScanPresented.toggle()
                }, label: {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 6)
                })
                if !client.contents.isEmpty {
                    Button(action: {
                        isPresented.toggle()
                    }, label: {
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 6)
                    })
                }
            })
            .buttonStyle(.plain)
            .padding(.bottom)
        })
        .sheet(isPresented: $isPresented, content: {
            ActivityView(contents: client.contents.filter(\.isSelected))
                .presentationDetents([.medium, .large])
        })
        .sheet(isPresented: $isScanPresented, content: {
            QRScanView()
                .ignoresSafeArea(.all)
        })
        .padding(.horizontal)
        .navigationTitle("アルバム")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    GalleryView()
        .environmentObject(NXClient())
}
