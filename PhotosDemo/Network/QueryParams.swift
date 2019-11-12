//
// Created by Vlad Zhavoronkov on 11/9/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation

struct QueryParams {
    struct Random {
        /// max 30
        let count: UInt8
        let orientation: PhotoOrientation
        let clientId: String = ApiTaskProvider.clientId

        var parameters: Parameters {
            return [
                "count": count,
                "orientation": orientation.rawValue,
                "client_id": clientId
            ]
        }
    }

    struct Query {
        let query: String
        let orientation: PhotoOrientation
        let page: UInt16
        let perPage: UInt8
        let clientId: String = ApiTaskProvider.clientId

        var parameters: Parameters {
            return [
                "query": query,
                "orientation": orientation.rawValue,
                "page": page,
                "per_page": perPage,
                "client_id": clientId
            ]
        }
    }

    enum PhotoOrientation: String {
        case landscape
        case portrait
        case squarish
    }
}