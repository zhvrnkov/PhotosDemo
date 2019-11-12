//
// Created by Vlad Zhavoronkov on 11/9/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation
import UIKit

protocol BasePresenter: class {
    func show(error: Error)
    func update(indexPaths: [IndexPath])
    func reload()
}

protocol MainPresenter: BasePresenter {
    var isLoading: Bool { get set }
    func present(vc: UIViewController)
    func deselectAll()
}

protocol PresenterThatCanDeleteAndSaveToIOSPhotoLibrary: MainPresenter {
    func delete(indexPaths: [IndexPath])
    func save(images: [UIImage])
}

protocol SliderPresenter: BasePresenter {
    func scroll(to indexPath: IndexPath)
}
