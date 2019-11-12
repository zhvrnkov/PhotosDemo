//
// Created by Vlad Zhavoronkov on 11/10/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation

class VMSliderViewController: SliderViewModel {
    private let base: BaseViewModel
    let initialIndexPath: IndexPath
    weak var presenter: SliderPresenter? {
        didSet {
            guard presenter != nil else { return }
            base.presenters.append({ [weak self] in return self?.presenter })
            presenter?.reload()
        }
    }

    init(base: BaseViewModel, initial indexPath: IndexPath) {
        self.base = base
        self.initialIndexPath = indexPath
    }

    func onLastCell() {
        print(#function)
        base.onLastCell()
    }

    func itemsCount() -> Int {
        return base.itemsCount()
    }

    func getRegularImageSetter(for indexPath: IndexPath) -> (ImagedCell) -> Void {
        let url = base.photoUrls[indexPath.row].regular
        if let cached = base.photos[PhotoURLs.getID(of: url)] {
            return base.setCached(url: url, cached: cached)
        } else {
            return base.setTask(url: url)
        }
    }

    deinit {
        print(type(of: self), #function)
    }
}
