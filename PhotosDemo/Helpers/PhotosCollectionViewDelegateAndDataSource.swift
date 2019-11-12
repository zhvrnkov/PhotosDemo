//
// Created by Vlad Zhavoronkov on 11/11/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import UIKit

protocol PhotosCollectionViewModel: class {
    func itemsCount() -> Int
    func getImageSetter(for indexPath: IndexPath) -> (ImagedCell) -> Void
    func onLastCell()
    func isSelected(at indexPath: IndexPath) -> Bool
}

protocol PhotosCollectionViewOwner: class {
    func onScrollViewDragging()
}

class PhotosCollectionViewDelegateAndDataSource: NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    weak var viewModel: PhotosCollectionViewModel?
    weak var owner: PhotosCollectionViewOwner?
    var widthOfCell: CGFloat = 0

    private func isLastCell(indexPath: IndexPath) -> Bool {
        return indexPath.row == (viewModel?.itemsCount() ?? 0) - 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.itemsCount() ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let castedCell = cell as? ImageCollectionViewCell,
           let configuration = viewModel?.getImageSetter(for: indexPath) {
            castedCell.imageView.isUserInteractionEnabled = true
            configuration(castedCell)
            if castedCell.isSelected {
                castedCell.setSelected()
            } else {
                castedCell.setDeselected()
            }
        }
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isLastCell(indexPath: indexPath) {
            viewModel?.onLastCell()
        }
        if let castedCell = cell as? ImageCollectionViewCell {
            let selectedState = viewModel?.isSelected(at: indexPath) ?? false
            if selectedState {
                castedCell.setSelected()
            } else {
                castedCell.setDeselected()
            }
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: widthOfCell, height: widthOfCell)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        owner?.onScrollViewDragging()
    }
}
