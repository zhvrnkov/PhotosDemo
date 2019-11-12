//
// Created by Vlad Zhavoronkov on 11/10/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation
import XCTest

class FileSaverTest: XCTestCase {
    let ext = "foo"
    lazy var data = Dictionary(uniqueKeysWithValues: (0..<10).map {
        ("\($0).\(ext)", "\($0)".data(using: .utf8)!)
    })

    private func save(data: [String: Data]) throws {
        try data.forEach { (name, data) in
            try FileSaver.save(data: (name, data))
        }
    }

    func testSave() {
        XCTAssertNoThrow(try save(data: data))
    }

    func testFilter() {
        XCTAssertNoThrow(try save(data: data))
        do {
            let output = try FileSaver.getToSave(names: data.map {
                $0.key
            })
            XCTAssertTrue(output.isEmpty, "\(output)")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testRead() {
        try? save(data: data)
        try? data.forEach {
            XCTAssertNoThrow(try FileSaver.readFile(name: $0.key))
        }
    }

    func testGetAll() {
        try? save(data: data)
        do {
            let all = try FileSaver.getAll(of: ext)
            XCTAssertEqual(all.count, data.count)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testDeleting() {
        try? save(data: data)
        do {
            let all = try FileSaver.getAll(of: ext)
            XCTAssertEqual(all.count, data.count)
            XCTAssertNoThrow(try all.forEach { try FileSaver.deleteFile(name: $0.key) })
            let allAfterDeletion = try FileSaver.getAll(of: ext)
            XCTAssert(allAfterDeletion.isEmpty)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
