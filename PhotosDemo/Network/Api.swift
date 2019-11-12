//
// Created by Vlad Zhavoronkov on 11/9/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation

class ApiTaskProvider {
    static func getQueryTask(
        params: QueryParams.Query,
        completion: @escaping (Result<PhotosQueryResponse, Error>) -> Void
    ) -> URLSessionDataTask {
        return getTask(for: .query(params), completion: completion)
    }

    static func getRandomTask(
        params: QueryParams.Random,
        completion: @escaping (Result<PhotosRandomResponse, Error>) -> Void
    ) -> URLSessionDataTask {
        return getTask(for: .random(params), completion: completion)
    }

    static func getLoadTask(
        for url: URL,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionDataTask {
        return URLSession.shared.dataTask(
            with: url
        ) { completion(defaultDataRequestHandler($0, $1, $2)) }
    }

    static private func getTask<T: Decodable>(
        for request: Requests,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionDataTask {
        return URLSession.shared.dataTask(
            with: request.urlRequest
        ) { completion(defaultRequestHandler($0, $1, $2)) }
    }

    static let clientId = "e93f2a1cc22f94a63aa40a25f541a2105f098aa21dd69a5577ab0539e9e3a1ea"
    // doo fee:"7c59b4c9660de2d31e75a7b4466df1dc76b6adfa61902827f9e35123e32e4f8d"
}

enum Requests {
    case query(QueryParams.Query)
    case random(QueryParams.Random)

    var urlRequest: URLRequest {
        var req = URLRequest(url: url)
        switch self {
        case .query(let body):
            req.parameters = body.parameters
        case .random(let body):
            req.parameters = body.parameters
        }
        return req
    }

    var url: URL {
        switch self {
        case .query:
            return URL(string: "https://api.unsplash.com/search/photos")!
        case .random:
            return URL(string: "https://api.unsplash.com/photos/random")!
        }
    }
}
