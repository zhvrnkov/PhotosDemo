//
// Created by Vlad Zhavoronkov on 11/11/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation
import UIKit.UIImage

final class VMSavedPhotosViewController: SavedPhotosViewModel {
    weak var presenter: PresenterThatCanDeleteAndSaveToIOSPhotoLibrary? {
        didSet {
            presenter?.reload()
        }
    }

    func onPressSelect() {
        isSelecting = true
    }

    func onPressSave() {
        let selectedIds = selectedCells.map { ids[$0.row] }
        let deletedIds: [PhotoID] = delete(ids: selectedIds)
        let indexPathsToDelete: [IndexPath] = deleteIdsToIndexPaths(deletedIds, allIds: ids)
        deletedIds.forEach { id in
            self.items.removeValue(forKey: id)
            self.ids.removeAll { $0 == id }
        }
        resetSelected()
        isSelecting = false
        presenter?.delete(indexPaths: indexPathsToDelete)
    }

    func onPressCancel() {
        let selectedIds = selectedCells.map { ids[$0.row] }
        let data = selectedIds.compactMap { items[$0] }
        let images = data.compactMap { UIImage(data: $0) }
        presenter?.save(images: images)
        resetSelected()
        isSelecting = false
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

    func itemsCount() -> Int {
        return ids.count
    }

    func getImageSetter(for indexPath: IndexPath) -> (ImagedCell) -> Void {
        let id = ids[indexPath.row]
        guard let image = items[id],
              let uiImage = UIImage(data: image)
            else { return { _ in } }
        return { cell in
            cell.imageID = id
            cell.image = uiImage
        }
    }

    func onLastCell() {
        print(#function)
    }

    func isSelected(at indexPath: IndexPath) -> Bool {
        return selectedCells.contains(indexPath)
    }

    private func delete(ids: [PhotoID]) -> [PhotoID] {
        return ids.compactMap { id in
            do {
                try FileSaver.deleteFile(name: "\(id).\(PhotoURLs.Extension.thumb.rawValue)")
                return id
            } catch {
                print("ERROR: ", error)
                return nil
            }
        }
    }

    private func deleteIdsToIndexPaths(_ delIds: [PhotoID], allIds: [PhotoID]) -> [IndexPath] {
        return delIds.compactMap { id in
            guard let index = allIds.firstIndex(of: id) else { return nil }
            return IndexPath(row: index, section: 0)
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

    init() {
        items = fetchSaved()
        ids = items.map { $0.key }
    }

    private func fetchSaved() -> [PhotoID: Data] {
        do {
            let t = (try FileSaver.getAll(of: PhotoURLs.Extension.thumb.rawValue))
                .map { (PhotoURLs.fileNameToID($0.key), $0.value) }
            return Dictionary(uniqueKeysWithValues: t)
        } catch {
            print("ERROR: ", error.localizedDescription)
            return  [:]
        }
    }

    private var ids: [PhotoID] = []
    private var items: [PhotoID: Data] = [:]
    private var isSelecting = false
    private var selectedCells: [IndexPath] = []
}
