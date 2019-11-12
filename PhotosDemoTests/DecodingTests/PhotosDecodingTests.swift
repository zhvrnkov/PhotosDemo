//
//  PhotosDecodingTests.swift
//  PhotosDemoTests
//
//  Created by Vlad Zhavoronkov on 11/8/19.
//  Copyright © 2019 Zhvrnkov. All rights reserved.
//

import XCTest
import Foundation
@testable import PhotosDemo

class DecodingTests: XCTestCase {
    func testPhotosQueryResponseDecoding() {
        let test = PhotosQueryResponseDecodingTest()
        let result = test.check()
        XCTAssertTrue(result.0, result.1?.message ?? "")
    }

    func testPhotosSingleRandomResponseDecoding() {
        let test = PhotosSingleRandomResponseDecodingTest()
        let result = test.check()
        XCTAssertTrue(result.0, result.1?.message ?? "")
    }

    func testPhotosRandomResponseDecoding() {
        let test = PhotosRandomResponseDecodingTest()
        let result = test.check()
        XCTAssertTrue(result.0, result.1?.message ?? "")
    }
}

class PhotosQueryResponseDecodingTest: GenericPhotosURLsDecodingTest {
    typealias Response = PhotosQueryResponse
    let fileName = "PhotosQueryResult"
}

class PhotosSingleRandomResponseDecodingTest: GenericPhotosURLsDecodingTest {
    typealias Response = PhotosRandomResponse
    let fileName: String = "PhotosSingleRandomResult"
}

class PhotosRandomResponseDecodingTest: GenericPhotosURLsDecodingTest {
    typealias Response = PhotosRandomResponse
    let fileName: String = "PhotosRandomResult"
}


protocol GenericPhotosURLsDecodingTest: class {
    associatedtype Response: PhotoResponse
    var fileName: String { get }
}

extension GenericPhotosURLsDecodingTest {
    var path: URL {
        let path = Bundle(for: Self.self).path(forResource: fileName, ofType: "json")!
        return URL(fileURLWithPath: path)
    }

    var json: Data {
        return try! Data(contentsOf: path)
    }

    func check() -> (Bool, ErrorWithMessage?) {
        do {
            let response = try JSONDecoder().decode(Response.self, from: json)
            return Self.validate(response: response)
        } catch {
            return (false, ErrorWithMessage(message: error.localizedDescription))
        }
    }

    static func validate(response: Response) -> (Bool, ErrorWithMessage?) {
        guard !response.urls.isEmpty
            else { return (false, ErrorWithMessage(message: "empty results")) }

        let t = response.urls.reduce(true) {
            $0 && [
                $1.small.absoluteString.isEmpty,
                $1.full.absoluteString.isEmpty,
                $1.raw.absoluteString.isEmpty,
                $1.regular.absoluteString.isEmpty,
                $1.thumb.absoluteString.isEmpty
            ].allSatisfy(!)
        }
        return t ? (t, nil) : (t, ErrorWithMessage(message: "bad urls"))
    }
}
