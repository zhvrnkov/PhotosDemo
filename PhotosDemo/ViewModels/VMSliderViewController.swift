//
// Created by Vlad Zhavoronkov on 11/10/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation

class VMSliderViewController: SliderViewModel {
    private let base: PhotosProvider
    let initialIndexPath: IndexPath
    weak var presenter: SliderPresenter? {
        didSet {
            presenter?.reload()
        }
    }

    init(base: PhotosProvider, initial indexPath: IndexPath) {
        self.base = base
        self.initialIndexPath = indexPath
    }

    func itemsCount() -> Int {
        return base.getPhotosCount()
    }

    func getImageSetter(for indexPath: IndexPath) -> (ImagedCell) -> Void {
        return base.getImageSetter(for: indexPath.row, type: .regular)
    }

    deinit {
        print(type(of: self), #function)
    }
}
