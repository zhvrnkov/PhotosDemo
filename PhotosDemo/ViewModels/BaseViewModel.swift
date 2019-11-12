//
// Created by Vlad Zhavoronkov on 11/10/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation
import UIKit

typealias PhotoID = String

class BaseViewModel {
    var presenters: [() -> BasePresenter?] = []
    func itemsCount() -> Int {
        return photoUrls.count
    }

    init() {
        initialLoad()
    }

    func initialLoad() {
        load { [weak self] result in
            switch result {
            case .success(_): self?.presenters.forEach { $0()?.reload() }
            case .failure(let error):
                print("ERROR: ", error)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    self?.initialLoad()
                }
            }
        }
    }

    var randomPhotoUrls: [PhotoURLs] = []
    var queryPhotoUrls: [PhotoURLs] = []

    var photos: [PhotoID: Data] = [:]

    var queryPage: UInt16 = 1
    var query: String = ""
    var mode: WorkMode = .random {
        didSet {
            queryPage = 1
            query = ""
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

    func setCached(url: URL, cached: Data) -> (ImagedCell) -> Void {
        return { [weak self] in
            let id = PhotoURLs.getID(of: url)
            $0.imageID = id
            self?.setImage(from: cached, for: $0, where: id)
        }
    }

    func setTask(url: URL) -> (ImagedCell) -> Void {
        return { cell in
            let id = PhotoURLs.getID(of: url)
            cell.image = nil
            cell.imageID = id
            ApiTaskProvider.getLoadTask(
                for: url
            ) { [weak self] result in
                switch result {
                case .success(let data):
                    self?.photos[id] = data
                    self?.setImage(from: data, for: cell, where: id)
                case .failure(let error):
                    self?.presenters.forEach { $0()?.show(error: error) }
                }
            }.resume()
        }
    }

    var itemsPerPage: UInt8 = 10
    var photoUrls: [PhotoURLs] {
        switch mode {
        case .query: return queryPhotoUrls
        case .random: return randomPhotoUrls
        }
    }

    func load(completion: @escaping (Result<Void, Error>) -> Void) {
        print(#function)
        switch mode {
        case .query: loadQuery(completion: completion)
        case .random: loadRandom(completion: completion)
        }
    }

    func loadRandom(completion: @escaping (Result<Void, Error>) -> Void) {
        let params = QueryParams.Random(count: itemsPerPage, orientation: .squarish)
        let task = ApiTaskProvider.getRandomTask(
            params: params,
            completion: taskHandler { [weak self] in
                switch $0 {
                case .success: self?.queryPage += 1
                default: break
                }
                completion($0)
            }
        )
        task.resume()
    }

    fileprivate func loadQuery(completion: @escaping (Result<Void, Error>) -> Void) {
        let params = QueryParams.Query(
            query: query,
            orientation: .squarish,
            page: queryPage,
            perPage: itemsPerPage
        )
        let task = ApiTaskProvider.getQueryTask(
            params: params,
            completion: taskHandler(completion: completion))
        task.resume()
    }

    func onLastCell() {
        let beforeLoadCount = photoUrls.count
        load { [weak self] result in
            switch result {
            case .success:
                let newCount = self?.photoUrls.count ?? 0
                guard newCount > beforeLoadCount
                    else { return }
                let range = (beforeLoadCount..<(newCount)).map { IndexPath(row: $0, section: 0) }
                self?.presenters.forEach { $0()?.update(indexPaths: range) }
            case .failure(let error):
                self?.presenters.forEach { $0()?.show(error: error) }
            }
        }
    }


    func taskHandler<R: PhotoResponse>(
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> (Result<R, Error>) -> Void {
        return { [weak self] result in
            switch result {
            case .success(let res):
                guard let mode = self?.mode
                    else { return }
                switch mode {
                case .random: self?.randomPhotoUrls += res.urls
                case .query: self?.queryPhotoUrls += res.urls
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    enum WorkMode {
        case random
        case query
    }
}
