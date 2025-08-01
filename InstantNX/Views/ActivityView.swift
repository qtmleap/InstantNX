//
//  ActivityView.swift
//  InstantNX
//
//  Created by devonly on 2025/07/29.
//  Copyright © 2025 Magi, Corporation. All rights reserved.
//

import Foundation
import LinkPresentation
import SwiftUI
import UniformTypeIdentifiers

class ActivityItem: NSObject, UIActivityItemSource {
    private let metadata: LPLinkMetadata = .init()
    private let content: ContentItem

    init(content: ContentItem) {
        self.content = content
        metadata.title = "Instant NX"
        metadata.originalURL = content.url
        if content.type == .movie {
            let provider = NSItemProvider()
            provider.registerFileRepresentation(forTypeIdentifier: UTType.movie.identifier, fileOptions: [], visibility: .all) { completion in
                completion(content.url, false, nil)
                return nil
            }
            metadata.iconProvider = provider
            metadata.imageProvider = provider
            metadata.videoProvider = provider
            metadata.remoteVideoURL = content.url
        } else {
            let provider = NSItemProvider()
            provider.registerFileRepresentation(forTypeIdentifier: UTType.image.identifier, fileOptions: [], visibility: .all) { completion in
                completion(content.url, false, nil)
                return nil
            }
            metadata.iconProvider = provider
            metadata.imageProvider = provider
        }
        super.init()
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        metadata
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        content.type == .photo ? content.image : content.url
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        content.type == .photo ? content.image : content.url
    }
}

struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    init(contents: [ContentItem]) {
        activityItems = contents.map { ActivityItem(content: $0) }
    }

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller: UIActivityViewController = .init(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
