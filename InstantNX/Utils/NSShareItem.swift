//
//  NSShareItem.swift
//  InstantNX
//
//  Created by devonly on 2024/10/13.
//  Copyright © 2024 Magi, Corporation. All rights reserved.
//

import Foundation
import LinkPresentation

class NSShareItem: NSObject, UIActivityItemSource {
    private let metadata: LPLinkMetadata = .init()

    override init() {
        metadata.title = "InstantNX"
    }

    func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
        ""
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType _: UIActivity.ActivityType?) -> Any? {
        activityViewControllerPlaceholderItem(activityViewController)
    }

    func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
        metadata
    }
}
