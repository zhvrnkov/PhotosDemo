//
// Created by Vlad Zhavoronkov on 11/11/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import UIKit

class PhotosCollectionViewWithSearchBar: PhotosCollectionView {
    var searchBar = UISearchBar()

    override init() {
        super.init()
        addSubview(searchBar)
    }

    override func layoutSubviews() {
        layoutSearchBar()
        layoutSpinner()
        layoutCollectionView()
    }

    func layoutSearchBar() {
        searchBar.sizeToFit()
        searchBar.frame.size = CGSize(
            width: frame.width,
            height: searchBar.frame.height
        )
        searchBar.frame.origin = .zero
    }

    override func layoutCollectionView() {
        collectionView.frame.origin = CGPoint(x: 0, y: searchBar.frame.maxY)
        collectionView.frame.size = CGSize(
            width: frame.width,
            height: frame.height - searchBar.frame.maxY
        )
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}