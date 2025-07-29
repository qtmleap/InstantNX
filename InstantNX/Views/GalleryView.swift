//
//  GalleryView.swift
//  InstantNX
//
//  Created by devonly on 2025/07/29.
//  Copyright © 2025 Magi, Corporation. All rights reserved.
//

import CodeScanner
import Foundation
import SDWebImageSwiftUI
import SwiftUI

struct GalleryEmptyView: View {
    @State private var isPresented: Bool = false

    var body: some View {
        Button("QRコード読取り", systemImage: "qrcode", action: {
            isPresented.toggle()
        })
        .buttonStyle(.borderedProminent)
        .sheet(isPresented: $isPresented, content: {
            QRScanView()
        })
    }
}

struct GalleryListView: View {
    @EnvironmentObject private var client: NXClient
    @State private var isPresented: Bool = false
    @State private var selectedURLs: Set<URL> = .init([])

    var body: some View {
        ScrollView(content: {
            LazyVGrid(columns: .init(repeating: .init(.flexible()), count: 2), content: {
                ForEach(client.contents, id: \.self, content: { content in
                    Button(action: {
                        if selectedURLs.contains(content) {
                            selectedURLs.remove(content)
                        } else {
                            selectedURLs.insert(content)
                        }
                    }, label: {
                        WebImage(url: content, content: { image in
                            image
                                .resizable()
                                .scaledToFit()
                        }, placeholder: {
                            EmptyView()
                        })
                    })
                    .buttonStyle(.plain)
                    .overlay(content: {
                        Rectangle()
                            .strokeBorder(selectedURLs.contains(content) ? Color.red : Color.clear, lineWidth: 2, antialiased: true)
                    })
                })
            })
        })
        .onAppear(perform: {
            selectedURLs = Set(client.contents)
        })
        .overlay(alignment: .bottomTrailing, content: {
            Button(action: {
                isPresented.toggle()
            }, label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 6)
            })
            .buttonStyle(.plain)
            .padding(.bottom)
        })
        .sheet(isPresented: $isPresented, content: {
            ActivityView(activityItems: .init(arrayLiteral: selectedURLs))
                .presentationDetents([.medium, .large])
        })
    }
}

struct GalleryView: View {
    @EnvironmentObject private var client: NXClient

    var body: some View {
        Group(content: {
            switch client.contents.isEmpty {
                case true:
                    GalleryEmptyView()
                case false:
                    GalleryListView()
            }
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
