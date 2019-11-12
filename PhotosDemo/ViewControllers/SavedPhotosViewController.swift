//
// Created by Vlad Zhavoronkov on 11/11/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation
import UIKit

final class SavedPhotosViewController: UIViewController, PresenterThatCanDeleteAndSaveToIOSPhotoLibrary {
    var viewModel: SavedPhotosViewModel? {
        didSet {
            viewModel?.presenter = self
            collectionViewDelegateAndDataSource.viewModel = viewModel
        }
    }

    let collectionViewDelegateAndDataSource = PhotosCollectionViewDelegateAndDataSource()
    var castedView: PhotosCollectionView {
        return view as! PhotosCollectionView
    }
    var isLoading: Bool = false

    func present(vc: UIViewController) {
        navigationController?.present(vc, animated: false)
    }

    func deselectAll() {
        let cells = (castedView.collectionView.visibleCells as? [ImageCollectionViewCell])
        cells?.forEach {
            $0.setDeselected()
        }
    }

    func show(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.presentAlert(error: error)
        }
    }

    func update(indexPaths: [IndexPath]) {
        DispatchQueue.main.async { [weak self] in
            self?.castedView.collectionView.reloadData()
        }
    }

    func reload() {
        DispatchQueue.main.async { [weak self] in
            self?.castedView.collectionView.reloadData()
        }
    }

    func delete(indexPaths: [IndexPath]) {
        DispatchQueue.main.async { [weak self] in
            self?.castedView.collectionView.deleteItems(at: indexPaths)
        }
    }
    
    func save(images: [UIImage]) {
        images.forEach {
            UIImageWriteToSavedPhotosAlbum($0, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error)
        } else {
            print(#function)
        }
    }

    override func loadView() {
        edgesForExtendedLayout = []
        view = PhotosCollectionView()
        castedView.collectionView.dataSource = collectionViewDelegateAndDataSource
        castedView.collectionView.delegate = collectionViewDelegateAndDataSource
        castedView.collectionView.addGestureRecognizer(singleTap())
        castedView.spinner.removeFromSuperview()
        navigationItem.rightBarButtonItem = selectButton
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setWidthOfCell()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    @objc func onPressSelect() {
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
        viewModel?.onPressSelect()
    }

    @objc func onPressSave() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = selectButton
        viewModel?.onPressSave()
    }

    @objc func onPressCancel() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = selectButton
        viewModel?.onPressCancel()
    }

    private func setWidthOfCell() {
        collectionViewDelegateAndDataSource.widthOfCell = view.frame.width / 4
    }

    private func singleTap() -> UITapGestureRecognizer {
        return UITapGestureRecognizer(target: self, action: #selector(processSingleTap(sender:)))
    }

    @objc private func processSingleTap(sender: UITapGestureRecognizer) {
        if (sender.state == .ended) {
            guard let indexPath = getIndexPath(for: sender),
                  let cell = castedView.collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell
                else { return }
            viewModel?.onSingleTap(at: indexPath, select: cell.setSelected, deselect: cell.setDeselected)
        }
    }

    private func getIndexPath(for tap: UITapGestureRecognizer) -> IndexPath? {
        let point = tap.location(in: castedView.collectionView)
        guard let indexPath = castedView.collectionView.indexPathForItem(at: point)
            else { return nil }
        return indexPath
    }

    private lazy var selectButton = UIBarButtonItem(
        title: "Select", style: .plain, target: self, action: #selector(onPressSelect))
    private lazy var saveButton = UIBarButtonItem(
        title: "Save", style: .plain, target: self, action: #selector(onPressSave))
    private lazy var cancelButton = UIBarButtonItem(
        title: "Cancel", style: .plain, target: self, action: #selector(onPressCancel)
    )
}
