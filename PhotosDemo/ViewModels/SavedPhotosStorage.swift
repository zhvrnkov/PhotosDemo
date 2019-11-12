//
// Created by Vlad Zhavoronkov on 11/12/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation
import UIKit

class SavedPhotosStorage: PhotosProvider {
    var presenters: [() -> BasePresenter?] = []
    var cache: [PhotoID: Data] = [:]
    var ids: [PhotoID] {
        return Array(cache.keys)
    }

    init() {
        cache = fetchSaved()
        reloadPresenters()
    }

    func getPhotosCount() -> Int {
        return ids.count
    }

    func getImageSetter(for row: Int, type: PhotoURLs.Extension) -> (ImagedCell) -> Void {
        return { [weak self] cell in
            guard let id = self?.ids[safe: row], let image = self?.cache[id] else {
                print("ERROR: ", self?.cache, row)
                return
            }
            cell.imageID = id
            cell.image = UIImage(data: image)
        }
    }

    func reloadPresenters() {
        presenters.forEach { $0()?.reload() }
    }

    func delete(ids: [PhotoID]) -> [Result<PhotoID, Error>] {
        return ids.map { id in
            do {
                try FileSaver.deleteFile(name: id)
                remove(id: id)
                return Result.success(id)
            } catch {
                return Result.failure(error)
            }
        }
    }

    private func remove(id: PhotoID) {
        cache.removeValue(forKey: id)
    }

    private func fetchSaved() -> [PhotoID: Data] {
        do {
            return (try FileSaver.getAll(of: PhotoURLs.Extension.thumb.rawValue))
        } catch {
            print("ERROR: ", error.localizedDescription)
            return  [:]
        }
    }
}