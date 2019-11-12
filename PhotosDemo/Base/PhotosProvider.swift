//
// Created by Vlad Zhavoronkov on 11/12/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation
import UIKit

protocol PhotosProvider: class {
    var cache: [PhotoID: Data] { get set }

    func getImageSetter(for row: Int, type: PhotoURLs.Extension) -> (ImagedCell) -> Void
    func getPhotosCount() -> Int
}

extension PhotosProvider {
    func getCachedSetter(id: PhotoID, cached: Data) -> (ImagedCell) -> Void {
        return { [weak self] in
            $0.imageID = id
            self?.setImage(from: cached, for: $0, where: id)
        }
    }

    func getTaskSetter(url: URL, type: PhotoURLs.Extension) -> (ImagedCell) -> Void {
        return { cell in
            let id = PhotoURLs.getID(of: url, type: type)
            cell.image = nil
            cell.imageID = id
            ApiTaskProvider.getLoadTask(
                for: url
            ) { [weak self] result in
                switch result {
                case .success(let data):
                    self?.cache[id] = data
                    self?.setImage(from: data, for: cell, where: id)
                case .failure(let error):
                    print("ERROR: ", error)
                }
            }.resume()
        }
    }

    func setImage(from data: Data, for cell: ImagedCell, where id: PhotoID) {
        guard cell.imageID == id else { return }
        DispatchQueue.main.async {
            if let image = UIImage(data: data) {
                cell.image = image
            }
        }
    }
}