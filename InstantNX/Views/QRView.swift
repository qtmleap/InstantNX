//
//  QRView.swift
//  InstantNX
//
//  Created by devonly on 2024/10/13.
//  Copyright © 2024 Magi, Corporation. All rights reserved.
//

import CodeScanner
import Foundation
import NetworkExtension
import SwiftUI

struct QRView: View {
    @EnvironmentObject private var client: NXClient
    @Environment(\.dismiss) var dismiss

    var body: some View {
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
    }
}
