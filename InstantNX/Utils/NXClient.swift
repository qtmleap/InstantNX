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

    // 自動保存を有効化するかどうか
    @Published var isAutoSaveEnabled: Bool = false
//    @Published var action: NXAction = .NONE
    @Published var contents: [URL] = []

    //    @MainActor
    //    func completionHandler(_ result: Result<ScanResult, ScanError>) {
    //        switch result {
    //        case .success(let code):
    //            let capture: [String] = code.string.capture(pattern: #"WIFI:S:(switch_[\d]{10}I);T:WPA;P:([\w\d]{8});;"#, group: [1, 2])
    //            if capture.count != 2 {
    //                return
    //            }
    //            let configuration: NEHotspotConfiguration = .init(ssid: capture[0], passphrase: capture[1], isWEP: false)
    //            Task(priority: .background, operation: {
    //                self.contents = try await connect(configuration: configuration)
    //            })
    //
    //        case .failure(let failure):
    //            print(failure)
    //        }
    //    }

    //    func download() async throws ->[UIImage] {
    //        let dataList: [Data] = try await withThrowingTaskGroup(of: Data.self, body: { task in
    //            for content in contents {
    //                task.addTask(priority: .background, operation: { [self] in
    //                    try await session.download(content.url).serializingData().value
    //                })
    //            }
    //            return try await task.reduce(into: [Data](), { results, result in
    //                results.append(result)
    //            })
    //        })
    //        return dataList.compactMap({ UIImage(data: $0) })
    //    }

    func retry(_ request: Alamofire.Request, for _: Alamofire.Session, dueTo _: any Error, completion: @escaping (Alamofire.RetryResult) -> Void) {
        completion(request.retryCount > 10 ? .doNotRetry : .retryWithDelay(1))
    }

    // MARK: Private

    private let decoder: JSONDecoder = .init()
    private let session: Session = .default
    private let url: URL = .init(string: "http://192.168.0.1/data.json")!
    private var configuration: NEHotspotConfiguration = .init()

    init() {}

    // http://192.168.0.1/img/2024100609504500-4CE9651EE88A979D41F24CE8D6EA1C23.jpg
    // http://192.168.0.1/img/2024040620202600-4CE9651EE88A979D41F24CE8D6EA1C23.mp4

    @MainActor
    func connect(_ result: ScanResult) async throws {
        let capture: [String] = result.string.capture(pattern: #"WIFI:S:(switch_[\d]{10}I);T:WPA;P:([\w\d]{8});;"#, group: [1, 2])
        if capture.count != 2 {
            return
        }
        configuration = .init(ssid: capture[0], passphrase: capture[1], isWEP: false)
        configuration.joinOnce = true
        try await NEHotspotConfigurationManager.shared.apply(configuration)
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let response = try await session.request(url, method: .get)
            .validate()
            .serializingDecodable(NXScanResult.self, decoder: decoder)
            .value

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
        // 自動保存が有効ならフォトライブラリに保存する
        if isAutoSaveEnabled {
            for image in images {
                print("Saving image: \(image)")
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
        contents = try await withThrowingTaskGroup(of: URL.self, body: { task in
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
    }

    @MainActor
    func disconnect() async throws {
        NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: configuration.ssid)
    }
}

struct NXScanResult: Codable {
    let photoHelpMes: String
    let downloadMes: String
    let fileType: String
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
