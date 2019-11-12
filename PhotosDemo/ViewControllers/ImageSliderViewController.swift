//
// Created by Vlad Zhavoronkov on 11/10/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation
import UIKit

class ImageSliderViewController: UIViewController, SliderPresenter {
    var viewModel: SliderViewModel? {
        didSet {
            viewModel?.presenter = self
        }
    }

    var castedView: ImageSliderViewControllerView {
        return view as! ImageSliderViewControllerView
    }

    func scroll(to indexPath: IndexPath) {
        DispatchQueue.main.async { [weak self] in
            self?.castedView.collectionView.scrollToItem(at: indexPath, at: .right, animated: false)
        }
    }

    func show(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.presentAlert(error: error)
        }
    }

    func reload() {
        DispatchQueue.main.async { [weak self] in
            self?.castedView.collectionView.reloadData()
        }
    }

    func update(indexPaths: [IndexPath]) {
        DispatchQueue.main.async { [weak self] in
            self?.castedView.collectionView.insertItems(at: indexPaths)
        }
    }

    override func loadView() {
        view = ImageSliderViewControllerView()
        view.backgroundColor = .black
        castedView.collectionView.delegate = self
        castedView.collectionView.dataSource = self
        castedView.isUserInteractionEnabled = true
        castedView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissSelf)))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        castedView.collectionView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let ip = viewModel?.initialIndexPath {
            scroll(to: ip)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @objc private func dismissSelf() {
        dismiss(animated: true)
    }

    private func isLastCell(indexPath: IndexPath) -> Bool {
        return indexPath.row == (viewModel?.itemsCount() ?? 0) - 1
    }

    deinit {
        print(type(of: self), #function)
    }
}

extension ImageSliderViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.itemsCount() ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let castedCell = cell as? ImageCollectionViewCellWithSpinner,
           let configuration = viewModel?.getRegularImageSetter(for: indexPath) {
            configuration(castedCell)
        }
        if isLastCell(indexPath: indexPath) {
            viewModel?.onLastCell()
        }
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.width)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

class ImageSliderViewControllerView: UIView {
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
        configure(collectionView: collectionView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutCollectionView()
    }

    private func configure(collectionView: UICollectionView) {
        collectionView.isPagingEnabled = true
        collectionView.register(ImageCollectionViewCellWithSpinner.self, forCellWithReuseIdentifier: "cell")
    }

    private func layoutCollectionView() {
        collectionView.frame.size = CGSize(
            width: frame.width,
            height: frame.width
        )
        collectionView.frame.origin = CGPoint(x: 0, y: (frame.height - frame.width) / 2)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
