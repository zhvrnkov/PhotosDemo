//
// Created by Vlad Zhavoronkov on 11/10/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation
import UIKit

class ImageCollectionViewCellWithSpinner: ImageCollectionViewCell {
    let spinner = UIActivityIndicatorView(style: .whiteLarge)

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(spinner)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        spinner.sizeToFit()
        spinner.frame.origin = CGPoint(
            x: (frame.width - spinner.frame.width) / 2,
            y: (frame.height - spinner.frame.height) / 2
        )
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
