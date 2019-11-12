//
// Created by Vlad Zhavoronkov on 11/9/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import UIKit
import Foundation

protocol ImagedCell: class {
    var image: UIImage? { get set }
    var imageID: PhotoID? { get set }
}

class ImageCollectionViewCell: UICollectionViewCell, ImagedCell {
    var imageID: PhotoID?
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }

    var imageView = UIImageView()
    private var upperView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(upperView)
        upperView.isHidden = !isSelected
        upperView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        upperView.frame = bounds
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setSelected() {
        upperView.isHidden = false
    }

    func setDeselected() {
        upperView.isHidden = true
    }
}