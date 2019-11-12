//
// Created by Vlad Zhavoronkov on 11/10/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation

extension Array {
    subscript(safe index: Array.Index) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}