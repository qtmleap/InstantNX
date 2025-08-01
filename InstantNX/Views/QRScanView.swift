//
//  QRScanView.swift
//  InstantNX
//
//  Created by devonly on 2025/07/29.
//  Copyright © 2025 Magi, Corporation. All rights reserved.
//

import CodeScanner
import QuantumLeap
import SwiftUI

struct QRScanView: View {
    @EnvironmentObject private var client: NXClient
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        CodeScannerView(codeTypes: [.qr], scanMode: .oncePerCode, simulatedData: "WIFI:S:switch_6116480100I;T:WPA;P:wtrd2dhw;;", shouldVibrateOnSuccess: true, isTorchOn: false, videoCaptureDevice: .zoomedCameraForQRCode(), completion: { result in
            switch result {
                case let .success(code):
                    Task(priority: .background, operation: {
                        try await client.connect(code)
                    })
                    dismiss()
                case let .failure(error):
                    Logger.error(error)
            }
        })
    }
}
