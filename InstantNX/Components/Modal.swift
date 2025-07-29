//
//  Modal.swift
//  InstantNX
//
//  Created by devonly on 2024/10/13.
//  Copyright © 2024 Magi, Corporation. All rights reserved.
//

import Foundation
import SwiftUI

struct ModalBackground<T: View>: View {
    // MARK: Lifecycle

    init(isPresented: Binding<Bool>, content: @escaping () -> T) {
        _isPresented = isPresented
        self.content = content
    }

    // MARK: Internal

    @Binding var isPresented: Bool

    var body: some View {
        content()
            .fullScreenCover(isPresented: $isPresented, content: {
                ZStack(content: {
                    Color.black.opacity(0.6)
                    GroupBox(label: Text("Loading"), content: {
                        ProgressView()
                            .scaleEffect(1.2)
                    })
                    .frame(maxWidth: 240)
                })
                .presentationBackground(.clear)
            })
    }

    // MARK: Private

    private let content: () -> T
}
