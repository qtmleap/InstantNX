//
//  QRScanView.swift
//  InstantNX
//
//  Created by devonly on 2025/07/29.
//  Copyright © 2025 Magi, Corporation. All rights reserved.
//

import CodeScanner
import SwiftUI

struct QRScanView: View {
    @EnvironmentObject private var client: NXClient
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        CodeScannerView(codeTypes: [.qr], scanMode: .oncePerCode, shouldVibrateOnSuccess: true, isTorchOn: false, videoCaptureDevice: .zoomedCameraForQRCode(), completion: { result in
            switch result {
                case let .success(code):
                    // WIFI:S:switch_6116480100I;T:WPA;P:tweebd6c;;
                    // WIFI:S:switch_6116480100I;T:WPA;P:rrr6adtz;;
                    // 成功したらこんな感じのコードが返ってくる
                    print("Scanned code: \(code.string)")
                    Task(priority: .background, operation: {
                        do {
                            defer {
                                dismiss()
                            }
                            try await client.connect(code)
                            try await client.disconnect()
                        } catch {
                            print("Connection failed: \(error)")
                        }
                    })
                case let .failure(error):
                    print(error)
            }
        })
        .onDisappear(perform: {
            Task(priority: .background, operation: {
                try await client.disconnect()
            })
        })
    }
}
