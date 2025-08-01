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
    @EnvironmentObject private var client: NXClient

    var body: some View {
        Form(content: {
            QuantumLeap.Support()
            Section(content: {
                Toggle(isOn: $client.autosave, label: {
                    Text("TEXT_AUTOSAVE_TOGGLE")
                })
                Toggle(isOn: $client.shouldShowOpenPhotoLibraryDialog, label: {
                    Text("TEXT_SHOWDIALOG_TOGGLE")
                })
            }, header: {
                Text("HEADER_PHOTO_LIBRARY")
            }, footer: {
                Text("FOOTER_PHOTO_LIBRARY")
            })
            QuantumLeap.Policy()
            QuantumLeap.Version()
        })
        .navigationTitle("TITLE_SETTINGS")
        .navigationBarTitleDisplayMode(.inline)
    }
}
