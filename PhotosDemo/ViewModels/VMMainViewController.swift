//
// Created by Vlad Zhavoronkov on 11/10/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation
import UIKit

class VMMainViewController: MainViewModel {
    private let base: BaseViewModel
    weak var presenter: MainPresenter? {
        didSet {
            guard presenter != nil else { return }
            base.presenters.append({ [weak self] in return self?.presenter })
            presenter?.reload()
        }
    }
    private var isSelecting = false
    private var selectedCells: [IndexPath] = []

    func onPressSave() {
        func namesToIDs(names: [String]) -> [PhotoID] {
            return names.compactMap {
                guard let t = $0.split(separator: Character(".")).first
                    else { return nil }
                return "\(t)"
            }
        }
        let ids = getIDsFor(indexPaths: selectedCells)
        let names = ids.map { "\($0).\(PhotoURLs.Extension.thumb.rawValue)" }
        let hashesToSave = namesToIDs(names: try! FileSaver.getToSave(names: names))
        let data: [String: Data] = Dictionary(uniqueKeysWithValues:
            hashesToSave.compactMap {
                if let data = base.photos[$0] {
                    return ("\($0).\(PhotoURLs.Extension.thumb.rawValue)", data)
                } else {
                    return nil
                }
            }
        )
        print("toSave: ", data.keys)
        do {
            try FileSaver.save(data: data)
        } catch {
            print("ERROR: ", error)
        }
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

    init(base: BaseViewModel) {
        self.base = base
    }

    func itemsCount() -> Int {
        return base.itemsCount()
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
        let url = base.photoUrls[indexPath.row].thumb
        if let cached = base.photos[PhotoURLs.getID(of: url)] {
            return base.setCached(url: url, cached: cached)
        } else {
            return base.setTask(url: url)
        }
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
        if base.photoUrls.isEmpty {
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
            guard let url = base.photoUrls[safe: $0.row]?.thumb
                else { return nil }
            return PhotoURLs.getID(of: url)
        }
    }
}
