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

    static func getID(of url: URL) -> PhotoID {
        return url.lastPathComponent
    }

    static func fileNameToID(_ name: String) -> String {
        guard let beforeDot = name.split(separator: Character(".")).first
            else { return name }
        return String(beforeDot)
    }

    enum Extension: String {
        case thumb = "jpeg"
        case regualr
    }
}
