//
// Created by Vlad Zhavoronkov on 11/10/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation

struct ErrorWithMessage: Error {
    let message: String
}

class FileSaver {
    static func getDocDir() throws -> URL {
        guard let dir =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            else { throw Errors.badDocDir }
        return dir
    }

    static func getAll(of ext: String) throws -> [String: Data] {
        let docDir = try getDocDir()
        do {
            let allContent = try getContentsOf(url: docDir)
            let desiredFiles = allContent.filter { $0.pathExtension == ext }
            let output = try desiredFiles.map { ($0.lastPathComponent, try Data(contentsOf: $0)) }
            return Dictionary(uniqueKeysWithValues: output)
        }
    }
    
    static func getToSave(names: [String]) throws -> [String] {
        let docDir = try getDocDir()
        do {
            let saved = try getContentsOf(url: docDir).map { $0.absoluteString }
            return names.filter { !saved.contains(docDir.absoluteString + $0) }
        } catch {
            throw error
        }
    }

    static func save(data: (String, Data)) throws {
        let docDir = try getDocDir()
        let (name, value) = data
        let path = docDir.appendingPathComponent(name)
        try value.write(to: path)
    }

    static func readFile(name: String) throws -> Data {
        let docDir = try getDocDir()
        let path = docDir.appendingPathComponent(name)
        return try Data(contentsOf: path)
    }

    static func getContentsOf(url: URL) throws -> [URL] {
        let manager = FileManager.default
        do {
            return try manager.contentsOfDirectory(at: url, includingPropertiesForKeys: [])
        } catch {
            throw error
        }
    }

    static func deleteFile(name: String) throws {
        let docDir = try getDocDir()
        let path = docDir.appendingPathComponent(name)
        try FileManager.default.removeItem(at: path)
    }

    enum Errors: Error {
        case badDocDir
        case badPath
    }
}
