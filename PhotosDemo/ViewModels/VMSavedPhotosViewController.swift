//
// Created by Vlad Zhavoronkov on 11/11/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation
import UIKit.UIImage

final class VMSavedPhotosViewController: SavedPhotosViewModel {
    let savedStorage: SavedPhotosStorage
    weak var presenter: PresenterThatCanDeleteAndSaveToIOSPhotoLibrary? {
        didSet {
            guard presenter != nil else { return }
            presenter?.reload()
            savedStorage.presenters.append({ [weak self] in self?.presenter })
        }
    }

    init(savedStorage: SavedPhotosStorage) {
        self.savedStorage = savedStorage
    }

    func onPressSelect() {
        isSelecting = true
    }

    func onLastCell() {}

    func onPressSave() {
        let selectedIds = selectedCells.map { ids[$0.row] }
        let data = selectedIds.compactMap { photos[$0] }
        let images = data.compactMap { UIImage(data: $0) }
        presenter?.save(images: images)
        resetSelected()
        isSelecting = false
    }

    func onPressDelete() {
        let selectedIds = selectedCells.map { ids[$0.row] }
        let idsBeforeDeletion = ids
        let deletionResults: [Result<PhotoID, Error>] = savedStorage.delete(ids: selectedIds)
        let indexPathsToDelete: [IndexPath] = deletionResultsToIndexPaths(deletionResults, allIds: idsBeforeDeletion)
        resetSelected()
        isSelecting = false
        print(indexPathsToDelete)
        presenter?.delete(indexPaths: indexPathsToDelete)
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

    func onDoubleTap(at indexPath: IndexPath) {
        guard !isSelecting,
              let present = presenter?.present else { return }
        let vm = VMSliderViewController(base: savedStorage, initial: indexPath)
        let vc = ImageSliderViewController()
        vc.viewModel = vm
        present(vc)
    }

    func itemsCount() -> Int {
        return ids.count
    }

    func getImageSetter(for indexPath: IndexPath) -> (ImagedCell) -> Void {
        let id = ids[indexPath.row]
        guard let image = photos[id],
              let uiImage = UIImage(data: image)
            else { return { _ in } }
        return { cell in
            cell.imageID = id
            cell.image = uiImage
        }
    }

    func isSelected(at indexPath: IndexPath) -> Bool {
        return selectedCells.contains(indexPath)
    }

    private func deletionResultsToIndexPaths(
        _ results: [Result<PhotoID, Error>],
        allIds: [PhotoID]
    ) -> [IndexPath] {
        return results.compactMap { result in
            do {
                let id = try result.get()
                guard let index = allIds.firstIndex(of: id) else { print(id, allIds); return nil }
                return IndexPath(row: index, section: 0)
            } catch {
                print(error)
                return nil
            }
        }
    }

    private func resetSelected() {
        selectedCells = []
        presenter?.deselectAll()
    }

    private func didSelectItem(at indexPath: IndexPath) {
        guard isSelecting else { return }
        selectedCells.append(indexPath)
    }

    private func didDeselctItem(at indexPath: IndexPath) {
        guard isSelecting,
              let index = selectedCells.firstIndex(of: indexPath)
            else { return }
        selectedCells.remove(at: index)
    }

    private var ids: [PhotoID] {
        return savedStorage.ids
    }
    private var photos: [PhotoID: Data] {
        return savedStorage.cache
    }

    private var isSelecting = false
    private var selectedCells: [IndexPath] = []
}
