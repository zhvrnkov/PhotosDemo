//
// Created by Vlad Zhavoronkov on 11/10/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation
import UIKit

class VMMainViewController: MainViewModel {
    private let base: BaseViewModel
    private let savedStorage: SavedPhotosStorage
    weak var presenter: MainPresenter? {
        didSet {
            guard presenter != nil else { return }
            base.presenters.append({ [weak self] in self?.presenter })
            presenter?.reload()
        }
    }
    private var isSelecting = false
    private var selectedCells: [IndexPath] = []

    func onPressSave() {
        let ids = getIDsFor(indexPaths: selectedCells)
        let idsToSave = try! FileSaver.getToSave(names: ids)
        let data: [String: Data] = Dictionary(uniqueKeysWithValues:
            idsToSave.compactMap {
                if let data = base.cache[$0] {
                    return ($0, data)
                } else {
                    return nil
                }
            }
        )
        data.forEach { (name, data) in
            do {
                try FileSaver.save(data: (name, data))
                savedStorage.cache[name] = data
            } catch {
                print("ERROR: ", error)
            }
        }
        savedStorage.reloadPresenters()
        resetSelected()
        isSelecting = false
    }

    func onPressCancel() {
        resetSelected()
        isSelecting = false
    }

    func onPressSelect() {
        isSelecting = true
        print(#function)
    }

    func isSelected(at indexPath: IndexPath) -> Bool {
        return selectedCells.contains(indexPath)
    }

    init(base: BaseViewModel, savedStorage: SavedPhotosStorage) {
        self.base = base
        self.savedStorage = savedStorage
    }

    func itemsCount() -> Int {
        return base.getPhotosCount()
    }

    func onDoubleTap(at indexPath: IndexPath) {
        guard !isSelecting,
              let present = presenter?.present else { return }
        let vm = VMSliderViewController(base: base, initial: indexPath)
        let vc = ImageSliderViewController()
        vc.viewModel = vm
        present(vc)
    }

    func onSingleTap(at indexPath: IndexPath, select: () -> Void, deselect: () -> Void) {
        guard isSelecting else { return }
        if isSelected(at: indexPath) {
            didDeselctItem(at: indexPath)
            deselect()
        } else {
            didSelectItem(at: indexPath)
            select()
        }
    }

    func getImageSetter(for indexPath: IndexPath) -> (ImagedCell) -> Void {
        return base.getImageSetter(for: indexPath.row, type: .thumb)
    }

    func onPressSearchButton(query: String) {
        base.mode = .query
        base.query = query
        base.queryPhotoUrls = []
        resetSelected()
        presenter?.isLoading = true
        base.load { [weak self] result in
            switch result {
            case .success: self?.presenter?.reload()
            case .failure(let error): self?.presenter?.show(error: error)
            }
        }
    }

    func onEditSearchBar(query: String) {
        guard query.isEmpty else { return }
        base.query = query
        base.mode = .random
        resetSelected()
        if base.photos.isEmpty {
            base.load { [weak self] result in
                switch result {
                case .success: self?.presenter?.reload()
                case .failure(let error): self?.presenter?.show(error: error)
                }
            }
        } else {
            presenter?.reload()
        }
    }

    func onChangeScreen(size: CGSize) {
        let widthOfCell = size.width / 4
        let cols = size.width / widthOfCell
        let rows = ceil(size.height / widthOfCell)
        base.itemsPerPage = UInt8(cols * rows)
    }

    func onLastCell() {
        base.onLastCell()
    }

    func resetSelected() {
        selectedCells = []
        presenter?.deselectAll()
    }

    deinit {
        print(type(of: self), #function)
    }

    func didSelectItem(at indexPath: IndexPath) {
        guard isSelecting else { return }
        selectedCells.append(indexPath)
    }

    func didDeselctItem(at indexPath: IndexPath) {
        guard isSelecting,
              let index = selectedCells.firstIndex(of: indexPath)
            else { return }
        selectedCells.remove(at: index)
    }

    func getIDsFor(indexPaths: [IndexPath]) -> [PhotoID] {
        return indexPaths.compactMap {
            guard let url = base.photos[safe: $0.row]?.thumb
                else { return nil }
            return PhotoURLs.getID(of: url, type: .thumb)
        }
    }
}
