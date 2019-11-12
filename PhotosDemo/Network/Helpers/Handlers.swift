//
// Created by Vlad Zhavoronkov on 11/9/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation

func defaultRequestHandler<T: Decodable>(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Result<T, Error> {
    var output: Result<T, Error> = .failure(NetworkErrors.unknown)
    if let error = error {
        output = .failure(error)
    } else if let response = response as? HTTPURLResponse {
        let result = handleNetwork(response: response)
        switch result {
        case .success(_):
            guard let responseData = data else {
                return .failure(NetworkErrors.noData)
            }
            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(T.self, from: responseData)
                output = .success(apiResponse)
            } catch {
                output = .failure(error)
            }
        case .failure(let error):
            output = .failure(error)
        }
    }
    return output
}

func defaultDataRequestHandler(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Result<Data, Error> {
    var output: Result<Data, Error> = .failure(NetworkErrors.failed)
    if let error = error {
        output = .failure(error)
    } else if let response = response as? HTTPURLResponse {
        let result = handleNetwork(response: response)
        switch result {
        case .success(_):
            if let responseData = data {
                output = .success(responseData)
            } else {
                output = .failure(NetworkErrors.noData)
            }
        case .failure(let error):
            output = .failure(error)
        }
    }

    return output
}

fileprivate func handleNetwork(response: HTTPURLResponse) -> Result<Void, Error> {
    switch response.statusCode {
    case 200...299: return .success(())
    case 400...500: return .failure(NetworkErrors.authenticationFailed)
    case 501...599: return .failure(NetworkErrors.badRequest)
    case 600: return .failure(NetworkErrors.outdated)
    default: return .failure(NetworkErrors.failed)
    }
}

public enum NetworkErrors: String, Error {
    case unknown
    case missingURL = "URL is nil"
    case encodingFailed = "Encoding failed"
    case authenticationFailed = "Authentication failed"
    case badRequest = "Bad request"
    case outdated = "Outdated"
    case failed = "Just Failed"
    case noData = "No data"
}