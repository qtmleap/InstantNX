//
//  GalleryView.swift
//  InstantNX
//
//  Created by devonly on 2025/07/29.
//  Copyright © 2025 Magi, Corporation. All rights reserved.
//

import CodeScanner
import SDWebImageSwiftUI
import SwiftUI

struct GalleryView: View {
    @EnvironmentObject private var client: NXClient
    @State private var isPresented: Bool = true

    var body: some View {
        ScrollView(content: {
            Grid(content: {
                GridRow(content: {
                    ForEach(client.contents, id: \.self, content: { content in
                        WebImage(url: content, content: { image in
                            image
                                .resizable()
                                .scaledToFit()
                        }, placeholder: {
                            EmptyView()
                        })
                    })
                })
            })
        })
        .sheet(isPresented: $isPresented, content: {
            CodeScannerView(codeTypes: [.qr], scanMode: .oncePerCode, shouldVibrateOnSuccess: true, isTorchOn: false, videoCaptureDevice: .zoomedCameraForQRCode(), completion: { result in
                switch result {
                    case let .success(code):
                        // WIFI:S:switch_6116480100I;T:WPA;P:tweebd6c;;
                        // WIFI:S:switch_6116480100I;T:WPA;P:rrr6adtz;;
                        // 成功したらこんな感じのコードが返ってくる
                        print("Scanned code: \(code.string)")
                        Task(priority: .background, operation: {
                            try await client.connect(code)
                        })
                    case let .failure(error):
                        print(error)
                }
            })
        })
        .navigationTitle("アルバム")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    GalleryView()
}
