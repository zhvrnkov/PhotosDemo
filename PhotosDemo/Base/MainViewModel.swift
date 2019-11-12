//
// Created by Vlad Zhavoronkov on 11/9/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation
import CoreGraphics.CGBase

protocol MainViewModel: PhotosCollectionViewModel {
    var presenter: MainPresenter? { get set }

    func onDoubleTap(at indexPath: IndexPath)
    func onSingleTap(at indexPath: IndexPath, select: () -> Void, deselect: () -> Void)
    func onPressSearchButton(query: String)
    func onEditSearchBar(query: String)
    func onChangeScreen(size: CGSize)
    func onLastCell()

    func onPressSave()
    func onPressCancel()
    func onPressSelect()
    func isSelected(at indexPath: IndexPath) -> Bool
}