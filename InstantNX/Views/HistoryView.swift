//
//  HistoryView.swift
//  InstantNX
//
//  Created by devonly on 2025/07/29.
//  Copyright © 2025 Magi, Corporation. All rights reserved.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var client: NXClient

    var body: some View {
        ScrollView(content: {})
            .navigationTitle("TITLE_HISTORY")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    HistoryView()
}
