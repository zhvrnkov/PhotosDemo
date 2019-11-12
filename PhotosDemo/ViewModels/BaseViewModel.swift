//
// Created by Vlad Zhavoronkov on 11/10/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation
import UIKit

typealias PhotoID = String

class BaseViewModel: PhotosProvider {
    var presenters: [() -> BasePresenter?] = []
    var cache: [PhotoID: Data] = [:]
    var photos: [PhotoURLs] {
        switch mode {
        case .query: return queryPhotoUrls
        case .random: return randomPhotoUrls
        }
    }

    var randomPhotoUrls: [PhotoURLs] = [] {
        willSet {
            randomPhotoUrlsCountBeforeSet = randomPhotoUrls.count
        }
        didSet {
            handleUpdate(was: randomPhotoUrlsCountBeforeSet, now: randomPhotoUrls.count)
        }
    }
    var queryPhotoUrls: [PhotoURLs] = [] {
        willSet {
            queryPhotoUrlsCountBeforeSet = queryPhotoUrls.count
        }
        didSet {
            handleUpdate(was: queryPhotoUrlsCountBeforeSet, now: queryPhotoUrls.count)
        }
    }

    var queryPage: UInt16 = 1
    var query: String = ""
    var mode: WorkMode = .random {
        didSet {
            queryPage = 1
            query = ""
        }
    }

    var itemsPerPage: UInt8 = 4
    private var randomPhotoUrlsCountBeforeSet = 0
    private var queryPhotoUrlsCountBeforeSet = 0

    init() {
        initialLoad()
    }

    func getImageSetter(for row: Int, type: PhotoURLs.Extension) -> (ImagedCell) -> Void {
        let url = type.get(url: photos[row])
        let id = PhotoURLs.getID(of: url, type: type)
        if let cached = cache[id] {
            return getCachedSetter(id: id, cached: cached)
        } else {
            return getTaskSetter(url: url, type: type)
        }
    }

    func getPhotosCount() -> Int {
        return photos.count
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

    func load(completion: @escaping (Result<Void, Error>) -> Void) {
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

    func onLastCell() {
        load { [weak self] result in
            switch result {
            case .success: ()
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

    private func handleUpdate(was: Int, now: Int) {
        if was < now {
            let range = (was...(now - 1))
            let indexPaths = getIndexPaths(for: range)
            presenters.forEach {
                $0()?.update(indexPaths: indexPaths)
            }
        } else {
            presenters.forEach {
                $0()?.reload()
            }
        }
    }

    private func getIndexPaths(for range: ClosedRange<Int>) -> [IndexPath] {
        return range.map { IndexPath(row: $0, section: 0) }
    }

    enum WorkMode {
        case random
        case query
    }
}
