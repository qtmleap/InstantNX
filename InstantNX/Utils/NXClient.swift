//
//  NXClient.swift
//  InstantNX
//
//  Created by devonly on 2024/10/13.
//  Copyright © 2024 Magi, Corporation. All rights reserved.
//

import Alamofire
import CodeScanner
import CoreLocation
import Foundation
import Network
import NetworkExtension
import SystemConfiguration.CaptiveNetwork
import UIKit

final class NXClient: ObservableObject, RequestRetrier, RequestInterceptor {
    // MARK: Internal

    @Published var contents: [URL] = []
    @Published var isCompleted: Bool = false
    @Published var isConnecting: Bool = false

    func retry(_ request: Alamofire.Request, for _: Alamofire.Session, dueTo _: any Error, completion: @escaping (Alamofire.RetryResult) -> Void) {
        print("Retrying request: \(request.retryCount)")
        completion(request.retryCount > 100 ? .doNotRetry : .retryWithDelay(1))
    }

    // MARK: Private

    private let decoder: JSONDecoder = .init()
    private let session: Session = .default
    private let url: URL = .init(string: "http://192.168.0.1/data.json")!
    private var configuration: NEHotspotConfiguration = .init()

    init() {
        session.sessionConfiguration.timeoutIntervalForRequest = 10
    }

    // http://192.168.0.1/img/2024100609504500-4CE9651EE88A979D41F24CE8D6EA1C23.jpg
    // http://192.168.0.1/img/2024040620202600-4CE9651EE88A979D41F24CE8D6EA1C23.mp4
    /// 保存する
    @MainActor
    func save() async throws {
        let response = try await session.request(url, method: .get, interceptor: self)
            .validate()
            .serializingDecodable(NXScanResult.self, decoder: decoder)
            .value
        switch response.fileType {
            case .photo:
                let images: [UIImage] = try await withThrowingTaskGroup(of: UIImage.self, body: { task in
                    for content in response.contents {
                        task.addTask(priority: .background, operation: { [self] in
                            let destination: DownloadRequest.Destination = { _, _ in
                                let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(content.lastPathComponent)
                                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                            }
                            print("Downloading content: \(content)")
                            return try await .init(data: session.download(content, to: destination)
                                .serializingData(automaticallyCancelling: true)
                                .value)!
                        })
                    }
                    return try await task.reduce(into: [UIImage]()) { results, result in
                        results.append(result)
                    }
                })
                for image in images {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                }
                isCompleted = true
            case .movie:
                let movies: [URL] = try await withThrowingTaskGroup(of: URL.self, body: { task in
                    for content in response.contents {
                        task.addTask(priority: .background, operation: { [self] in
                            let destination: DownloadRequest.Destination = { _, _ in
                                let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(content.lastPathComponent)
                                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                            }
                            print("Downloading content: \(content)")
                            return try await session.download(content, to: destination)
                                .serializingDownloadedFileURL(automaticallyCancelling: true)
                                .value
                        })
                    }
                    return try await task.reduce(into: [URL]()) { results, fileURL in
                        results.append(fileURL)
                    }
                })
                for movie in movies {
                    UISaveVideoAtPathToSavedPhotosAlbum(movie.path, nil, nil, nil)
                }
                isCompleted = true
        }
    }

    @MainActor
    func connect(_ result: ScanResult) async throws {
        let capture: [String] = result.string.capture(pattern: #"WIFI:S:(switch_[\d]{10}I);T:WPA;P:([\w\d]{8});;"#, group: [1, 2])
        if capture.count != 2 {
            return
        }
        configuration = .init(ssid: capture[0], passphrase: capture[1], isWEP: false)
        configuration.joinOnce = true
        isConnecting = true
        try await NEHotspotConfigurationManager.shared.apply(configuration)
        isConnecting = false
        try await save()
    }

    @MainActor
    func disconnect() async throws {
        NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: configuration.ssid)
    }
}

struct NXScanResult: Codable {
    enum FileType: String, Codable {
        case photo
        case movie
    }

    let photoHelpMes: String
    let downloadMes: String
    let fileType: FileType
    let movieHelpMes: String
    let consoleName: String
    let fileNames: [String]

    var contents: [URL] {
        fileNames.compactMap { .init(string: "http://192.168.0.1/img/\($0)") }
    }

    enum CodingKeys: String, CodingKey {
        case photoHelpMes = "PhotoHelpMes"
        case downloadMes = "DownloadMes"
        case fileType = "FileType"
        case movieHelpMes = "MovieHelpMes"
        case consoleName = "ConsoleName"
        case fileNames = "FileNames"
    }
}
