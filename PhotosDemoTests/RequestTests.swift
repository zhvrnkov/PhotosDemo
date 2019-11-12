//
// Created by Vlad Zhavoronkov on 11/9/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation
import XCTest

class RequestsTest: XCTestCase {
    func testQueryRequests() {
        let exp = XCTestExpectation(description: "wait for requests")
        let params = QueryParams.Query(
            query: "dogs", 
            orientation: .squarish,
            page: 1,
            perPage: 20)
        ApiTaskProvider.getQueryTask(
            params: params
        ) {
            switch $0 {
            case .success(let res):
                let (status, error) = PhotosQueryResponseDecodingTest.validate(response: res)
                XCTAssertTrue(status, error?.message ?? "")
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            exp.fulfill()
        }.resume()
        wait(for: [exp], timeout: 3)
    }

    func testRandomRequest() {
        let exp = XCTestExpectation(description: "wait for requests")
        let params = QueryParams.Random(
            count: 2,
            orientation: .squarish)

        ApiTaskProvider.getRandomTask(params: params) {
            switch $0 {
            case .success(let res):
                let (status, error) = PhotosRandomResponseDecodingTest.validate(response: res)
                XCTAssertTrue(status, error?.message ?? "")
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            exp.fulfill()
        }.resume()
        wait(for: [exp], timeout: 3)
    }
}