//
// Created by Vlad Zhavoronkov on 11/9/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation

typealias Parameters = [String: Any]

extension URLRequest {
    var parameters: Parameters {
        get {
            return queryItems.reduce(into: [:]) { $0[$1.name] = $1.value }
        }
        set {
            queryItems = newValue.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
        }
    }

    var queryItems: [URLQueryItem] {
        get {
            guard
                let url = self.url,
                let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                else { return [] }
            return components.queryItems ?? []
        }
        set {
            guard
                let url = self.url,
                var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                else { return }
            components.queryItems = newValue
            self.url = components.url
        }
    }

    enum ContentTypes: String {
        case json = "application/json"
        case urlencoded = "application/x-www-form-urlencoded; charset=utf-8"
        case formData = "multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW"
    }

    mutating func setContentType(_ contentType: ContentTypes) {
        setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
    }
}