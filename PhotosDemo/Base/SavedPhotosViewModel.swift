//
// Created by Vlad Zhavoronkov on 11/11/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation

protocol SavedPhotosViewModel: PhotosCollectionViewModel {
    var presenter: PresenterThatCanDeleteAndSaveToIOSPhotoLibrary? { get set }
    func onPressSelect()
    func onPressSave()
    func onPressDelete()
    func onSingleTap(at indexPath: IndexPath, select: () -> Void, deselect: () -> Void)
    func onDoubleTap(at indexPath: IndexPath)
}
