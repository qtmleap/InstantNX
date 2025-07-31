//
//  SettingsView.swift
//  InstantNX
//
//  Created by devonly on 2024/10/13.
//  Copyright © 2024 Magi, Corporation. All rights reserved.
//

import Foundation
import QuantumLeap
import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form(content: {
            QuantumLeap.Support()
            QuantumLeap.Policy()
            QuantumLeap.Version()
        })
        .navigationTitle("設定")
        .navigationBarTitleDisplayMode(.inline)
    }
}
