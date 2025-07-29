//
//  NXClient.swift
//  InstantNX
//
//  Created by devonly on 2024/10/13.
//  Copyright © 2024 Magi, Corporation. All rights reserved.
//

import Alamofire
import CodeScanner
import Foundation
import NetworkExtension
import UIKit

final class NXClient: ObservableObject, RequestRetrier, RequestInterceptor {
    // MARK: Internal

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

    // http://192.168.0.1/img/2024100609504500-4CE9651EE88A979D41F24CE8D6EA1C23.jpg
    // http://192.168.0.1/img/2024040620202600-4CE9651EE88A979D41F24CE8D6EA1C23.mp4

    @MainActor
    func connect(_ result: ScanResult) async throws {
        let capture: [String] = result.string.capture(pattern: #"WIFI:S:(switch_[\d]{10}I);T:WPA;P:([\w\d]{8});;"#, group: [1, 2])
        if capture.count != 2 {
            return
//            throw URLError(.notConnectedToInternet)
        }
        let configuration: NEHotspotConfiguration = .init(ssid: capture[0], passphrase: capture[1], isWEP: false)
        try await NEHotspotConfigurationManager.shared.apply(configuration)
        let response = try await session.request(url, method: .get)
            .validate()
            .serializingDecodable(NXScanResult.self, decoder: decoder)
            .value
        contents = response.contents
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
