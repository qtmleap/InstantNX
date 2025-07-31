//
//  ActivityView.swift
//  InstantNX
//
//  Created by devonly on 2025/07/29.
//  Copyright © 2025 Magi, Corporation. All rights reserved.
//

import Foundation
import SwiftUI
import LinkPresentation

class ActivityItem: NSObject, UIActivityItemSource {
    
    private let metadata: LPLinkMetadata = .init()
    private let image: UIImage
    
    init(content: ContentItem) {
        image = content.image
        metadata.title = "Instant NX"
        metadata.originalURL = content.url
//        metadata.iconProvider = NSItemProvider(contentsOf: content.url)
        metadata.imageProvider = NSItemProvider(contentsOf: content.url)
        if content.type == .movie {
            metadata.videoProvider = NSItemProvider(contentsOf: content.url)
            metadata.remoteVideoURL = content.url
        }
        super.init()
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        return metadata
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return image
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return image
    }
}

struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    init(contents: [ContentItem]) {
        self.activityItems = contents.map({ ActivityItem(content: $0) })
    }
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller: UIActivityViewController = .init(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
