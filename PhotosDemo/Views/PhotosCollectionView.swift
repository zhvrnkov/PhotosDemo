//
// Created by Vlad Zhavoronkov on 11/11/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation
import UIKit

class PhotosCollectionView: UIView {
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var spinner = UIActivityIndicatorView(style: .whiteLarge)

    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        configureCollectionView()
        configureSpinner()
        addSubview(collectionView)
        addSubview(spinner)
    }

    func configureCollectionView() {
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .white
        collectionView.allowsMultipleSelection = true
    }

    func configureSpinner() {
        spinner.color = .black
        spinner.hidesWhenStopped = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutSpinner()
        layoutCollectionView()
    }

    func layoutCollectionView() {
        collectionView.frame = bounds
    }

    func layoutSpinner() {
        spinner.sizeToFit()
        spinner.frame.origin = CGPoint(
            x: frame.width / 2 - spinner.frame.width / 2,
            y: frame.height / 2 - spinner.frame.height / 2
        )
        spinner.startAnimating()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
