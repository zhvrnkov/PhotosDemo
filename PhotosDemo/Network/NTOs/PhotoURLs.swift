//
// Created by Vlad Zhavoronkov on 11/8/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation

struct PhotoURLs: Decodable, Hashable {
    let raw: URL
    let full: URL
    let regular: URL
    let small: URL
    let thumb: URL

    static func getID(of url: URL, type: Extension) -> PhotoID {
        return "\(url.lastPathComponent).\(type.rawValue)"
    }

    enum Extension: String {
        case thumb
        case regular

        func get(url: PhotoURLs) -> URL {
            switch self {
            case .regular: return url.regular
            case .thumb: return url.thumb
            }
        }
    }
}
