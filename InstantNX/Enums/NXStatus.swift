//
//  NXStatus.swift
//  InstantNX
//
//  Created by devonly on 2025/07/31.
//  Copyright © 2025 Magi, Corporation. All rights reserved.
//

import Foundation
import SwiftUI

public enum NXStatus: LocalizedStringResource, CaseIterable {
    /// 待機状態
    case WAITING = "WAITING"
    /// 接続中
    case CONNECTING = "CONNECTING"
    /// ダウンロード中
    case DOWNLOADING = "DOWNLOADING"
}
