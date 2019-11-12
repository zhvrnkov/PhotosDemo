//
// Created by Vlad Zhavoronkov on 11/8/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation

protocol PhotoResponse: Decodable {
    var urls: [PhotoURLs] { get }
}

struct PhotosQueryResponse: PhotoResponse {
    var urls: [PhotoURLs] {
        return results.map { $0.photoUrls }
    }
    private let results: [PhotoResult]
}

struct PhotosRandomResponse: PhotoResponse {
    var urls: [PhotoURLs] {
        return results.map { $0.photoUrls }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let result = try? container.decode(PhotoResult.self) {
            self.results = [result]
        } else {
            results = try container.decode([PhotoResult].self)
        }
    }
    private let results: [PhotoResult]
}

fileprivate struct PhotoResult: Decodable {
    let photoUrls: PhotoURLs

    fileprivate enum CodingKeys: String, CodingKey {
        case photoUrls = "urls"
    }
}
