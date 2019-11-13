//
//  ViewController.swift
//  PhotosDemo
//
//  Created by Vlad Zhavoronkov on 11/8/19.
//  Copyright © 2019 Zhvrnkov. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, MainPresenter {
    var viewModel: (MainViewModel & PhotosCollectionViewModel)? {
        didSet {
            viewModel?.presenter = self
            collectionViewDelegateAndDataSource.viewModel = viewModel
        }
    }
    let collectionViewDelegateAndDataSource = PhotosCollectionViewDelegateAndDataSource()

    var isLoading: Bool {
        get {
            return castedView.spinner.isAnimating ||
                !castedView.collectionView.isUserInteractionEnabled
        }
        set {
            DispatchQueue.main.async { [weak self] in
                self?.castedView.collectionView.isUserInteractionEnabled = !newValue
                newValue ?
                    self?.castedView.spinner.startAnimating() :
                    self?.castedView.spinner.stopAnimating()
            }
        }
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
            self?.castedView.collectionView.insertItems(at: indexPaths)
        }
    }

    func reload() {
        DispatchQueue.main.async { [weak self] in
            self?.castedView.collectionView.reloadData()
            self?.isLoading = false
        }
    }

    var castedView: PhotosCollectionViewWithSearchBar {
        return view as! PhotosCollectionViewWithSearchBar
    }

    override func loadView() {
        title = "Main"
        edgesForExtendedLayout = []
        collectionViewDelegateAndDataSource.owner = self
        view = PhotosCollectionViewWithSearchBar()
        castedView.collectionView.dataSource = collectionViewDelegateAndDataSource
        castedView.collectionView.delegate = collectionViewDelegateAndDataSource
        castedView.collectionView.isUserInteractionEnabled = false
        castedView.collectionView.addGestureRecognizer(doubleTap())
        castedView.collectionView.addGestureRecognizer(singleTap())
        navigationItem.rightBarButtonItem = selectButton
        castedView.searchBar.delegate = self
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewModel?.onChangeScreen(size: view.frame.size)
        setWidthOfCell()
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

    private func doubleTap() -> UITapGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self, action: #selector(processDoubleTap(sender:)))
        tap.numberOfTapsRequired = 2
        tap.numberOfTouchesRequired = 1
        return tap
    }

    private func singleTap() -> UITapGestureRecognizer {
        return UITapGestureRecognizer(target: self, action: #selector(processSingleTap(sender:)))
    }

    @objc private func processDoubleTap(sender: UITapGestureRecognizer) {
        if (sender.state == .ended) {
            guard let indexPath = getIndexPath(for: sender)
                else { return }
            viewModel?.onDoubleTap(at: indexPath)
        }
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

    deinit {
        print(type(of: self), #function)
    }

    func present(vc: UIViewController) {
        navigationController?.present(vc, animated: true)
    }
}

extension MainViewController: PhotosCollectionViewOwner {
    func onScrollViewDragging() {
        castedView.searchBar.resignFirstResponder()
    }
}

extension MainViewController: UISearchBarDelegate {
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        viewModel?.onPressSearchButton(query: searchBar.text ?? "")
    }
}

