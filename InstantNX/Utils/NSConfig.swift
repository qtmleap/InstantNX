//
//  NSConfig.swift
//  InstantNX
//
//  Created by devonly on 2024/10/13.
//  Copyright © 2024 Magi, Corporation. All rights reserved.
//

import Foundation
import SwiftUI

final class NSConfig: ObservableObject {
    // MARK: Lifecycle

    /// Singleton instance for configuration
    private init() {}

    // MARK: Internal

    static let `default`: NSConfig = .init()

    /// ダークモードを利用するかどうか
    @AppStorage("APP_PREFERRED_COLOR_SCHEME") var usePreferredColorScheme: Bool = true
    /// システム設定のカラーテーマを利用するかどうか
    @AppStorage("APP_SYSTEM_COLOR_SCHEME") var useSystemColorScheme: Bool = true

    var preferredColorScheme: UIUserInterfaceStyle {
        useSystemColorScheme
            ? UITraitCollection.current.userInterfaceStyle
            : (usePreferredColorScheme ? .dark : .light)
    }
}
