//
// Created by Vlad Zhavoronkov on 11/10/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation

protocol SliderViewModel: class {
    var presenter: SliderPresenter? { get set }
    var initialIndexPath: IndexPath { get }

    func itemsCount() -> Int
    func getImageSetter(for indexPath: IndexPath) -> (ImagedCell) -> Void
}