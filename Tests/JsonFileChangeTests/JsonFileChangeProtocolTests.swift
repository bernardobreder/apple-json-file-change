//
//  ChangeTests.swift
//  FileStore
//
//  Created by Bernardo Breder on 05/01/17.
//
//

import XCTest
@testable import DataStore
@testable import JsonFileChange
@testable import Json
@testable import Literal

class ChangeTests: XCTestCase {
    
    func testCodec() throws {
        XCTAssertEqual(try JsonFileChangeCreateFile([], name: "a.txt"), try JsonFileChangeDecoder.decode(record: JsonFileChangeCreateFile([], name: "a.txt").encode()) as? JsonFileChangeCreateFile)
        XCTAssertEqual(try JsonFileChangeDeleteFile([], name: "a.txt"), try JsonFileChangeDecoder.decode(record: JsonFileChangeDeleteFile([], name: "a.txt").encode()) as? JsonFileChangeDeleteFile)
        XCTAssertEqual(try JsonFileChangeRenameFile([], from: "a.txt", to: "b.txt"), try JsonFileChangeDecoder.decode(record: JsonFileChangeRenameFile([], from: "a.txt", to: "b.txt").encode()) as? JsonFileChangeRenameFile)
        
        XCTAssertEqual(try JsonFileChangeCreateFolder([], name: "a"), try JsonFileChangeDecoder.decode(record: JsonFileChangeCreateFolder([], name: "a").encode()) as? JsonFileChangeCreateFolder)
        XCTAssertEqual(try JsonFileChangeDeleteFolder([], name: "a"), try JsonFileChangeDecoder.decode(record: JsonFileChangeDeleteFolder([], name: "a").encode()) as? JsonFileChangeDeleteFolder)
        XCTAssertEqual(try JsonFileChangeRenameFolder([], from: "a", to: "b"), try JsonFileChangeDecoder.decode(record: JsonFileChangeRenameFolder([], from: "a", to: "b").encode()) as? JsonFileChangeRenameFolder)
        
        XCTAssertEqual(JsonFileChangeJson(parents: ["z"], name: "x", paths: ["a"], from: Json("b"), to: Json("c")), try JsonFileChangeDecoder.decode(record: JsonFileChangeJson(parents: ["z"], name: "x", paths: ["a"], from: Json("b"), to: Json("c")).encode()) as? JsonFileChangeJson)
    }
    
    func testCreateJsonFileChangeFile() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let jfs = JsonFileChange()
        let change = try JsonFileChangeCreateFile([], name: "a.txt")
        XCTAssertEqual([], try db.read { reader in try jfs.read(reader: reader){ try $0.list() }.files })
        try db.write { writer in try jfs.write(writer: writer) { jfsw in try change.apply(writer: jfsw.writer) } }
        XCTAssertEqual(["a.txt"], try db.read { reader in try jfs.read(reader: reader){ try $0.list() }.files })
        try db.write { writer in try jfs.write(writer: writer) { jfsw in try change.revert(writer: jfsw.writer) } }
        XCTAssertEqual([], try db.read { reader in try jfs.read(reader: reader){ try $0.list() }.files })
    }
    
    func testJsonFileChangeDeleteFile() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let jfs = JsonFileChange()
        XCTAssertEqual([], try db.read { reader in try jfs.read(reader: reader){ try $0.list() }.files })
        try db.write { writer in try jfs.write(writer: writer) { jfsw in try JsonFileChangeCreateFile([], name: "a.txt").apply(writer: jfsw.writer) } }
        let change = try JsonFileChangeDeleteFile([], name: "a.txt")
        XCTAssertEqual(["a.txt"], try db.read { reader in try jfs.read(reader: reader){ try $0.list() }.files })
        try db.write { writer in try jfs.write(writer: writer) { jfsw in try change.apply(writer: jfsw.writer) } }
        XCTAssertEqual([], try db.read { reader in try jfs.read(reader: reader){ try $0.list() }.files })
        try db.write { writer in try jfs.write(writer: writer) { jfsw in try change.revert(writer: jfsw.writer) } }
        XCTAssertEqual(["a.txt"], try db.read { reader in try jfs.read(reader: reader){ try $0.list() }.files })
    }
    
    func testJsonFileChangeRenameFile() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let jfs = JsonFileChange()
        XCTAssertEqual([], try db.read { reader in try jfs.read(reader: reader){ try $0.list() }.files })
        try db.write { writer in try jfs.write(writer: writer) { jfsw in try JsonFileChangeCreateFile([], name: "a.txt").apply(writer: jfsw.writer) } }
        let change1 = try JsonFileChangeRenameFile([], from: "a.txt", to: "b.txt")
        let change2 = try JsonFileChangeRenameFile([], from: "b.txt", to: "c.txt")
        XCTAssertEqual(["a.txt"], try db.read { reader in try jfs.read(reader: reader){ try $0.list() }.files })
        try db.write { writer in try jfs.write(writer: writer) { jfsw in try change1.apply(writer: jfsw.writer) } }
        XCTAssertEqual(["b.txt"], try db.read { reader in try jfs.read(reader: reader){ try $0.list() }.files })
        try db.write { writer in try jfs.write(writer: writer) { jfsw in try change2.apply(writer: jfsw.writer) } }
        XCTAssertEqual(["c.txt"], try db.read { reader in try jfs.read(reader: reader){ try $0.list() }.files })
        try db.write { writer in try jfs.write(writer: writer) { jfsw in try change2.revert(writer: jfsw.writer) } }
        XCTAssertEqual(["b.txt"], try db.read { reader in try jfs.read(reader: reader){ try $0.list() }.files })
        try db.write { writer in try jfs.write(writer: writer) { jfsw in try change1.revert(writer: jfsw.writer) } }
        XCTAssertEqual(["a.txt"], try db.read { reader in try jfs.read(reader: reader){ try $0.list() }.files })
    }
    
    func testJsonFileChangeCreateFolder() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let jfs = JsonFileChange()
        let change = try JsonFileChangeCreateFolder([], name: "a")
        XCTAssertEqual([], try db.read { reader in try jfs.read(reader: reader){ try $0.list()}.folders })
        try db.write { writer in try jfs.write(writer: writer) { jfsw in try change.apply(writer: jfsw.writer) } }
        XCTAssertEqual(["a"], try db.read { reader in try jfs.read(reader: reader){ try $0.list()}.folders })
        try db.write { writer in try jfs.write(writer: writer) { jfsw in try change.revert(writer: jfsw.writer) } }
        XCTAssertEqual([], try db.read { reader in try jfs.read(reader: reader){ try $0.list()}.folders })
    }
    
    func testJsonFileChangeDeleteFolder() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let jfs = JsonFileChange()
        XCTAssertEqual([], try db.read { reader in try jfs.read(reader: reader){ try $0.list()}.folders })
        try db.write { writer in try jfs.write(writer: writer) { jfsw in try JsonFileChangeCreateFolder([], name: "a").apply(writer: jfsw.writer) } }
        let change = try JsonFileChangeDeleteFolder([], name: "a")
        XCTAssertEqual(["a"], try db.read { reader in try jfs.read(reader: reader){ try $0.list()}.folders })
        try db.write { writer in try jfs.write(writer: writer) { jfsw in try change.apply(writer: jfsw.writer) } }
        XCTAssertEqual([], try db.read { reader in try jfs.read(reader: reader){ try $0.list()}.folders })
        try db.write { writer in try jfs.write(writer: writer) { jfsw in try change.revert(writer: jfsw.writer) } }
        XCTAssertEqual(["a"], try db.read { reader in try jfs.read(reader: reader){ try $0.list()}.folders })
    }
    
    func testJsonFileChangeRenameFolder() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let jfs = JsonFileChange()
        XCTAssertEqual([], try db.read { reader in try jfs.read(reader: reader){ try $0.list()}.folders })
        try db.write { writer in try jfs.write(writer: writer) { jfsw in try JsonFileChangeCreateFolder([], name: "a").apply(writer: jfsw.writer) } }
        let change1 = try JsonFileChangeRenameFolder([], from: "a", to: "b")
        let change2 = try JsonFileChangeRenameFolder([], from: "b", to: "c")
        XCTAssertEqual(["a"], try db.read { reader in try jfs.read(reader: reader){ try $0.list()}.folders })
        try db.write { writer in try jfs.write(writer: writer) { jfsw in try change1.apply(writer: jfsw.writer) } }
        XCTAssertEqual(["b"], try db.read { reader in try jfs.read(reader: reader){ try $0.list()}.folders })
        try db.write { writer in try jfs.write(writer: writer) { jfsw in try change2.apply(writer: jfsw.writer) } }
        XCTAssertEqual(["c"], try db.read { reader in try jfs.read(reader: reader){ try $0.list()}.folders })
        try db.write { writer in try jfs.write(writer: writer) { jfsw in try change2.revert(writer: jfsw.writer) } }
        XCTAssertEqual(["b"], try db.read { reader in try jfs.read(reader: reader){ try $0.list()}.folders })
        try db.write { writer in try jfs.write(writer: writer) { jfsw in try change1.revert(writer: jfsw.writer) } }
        XCTAssertEqual(["a"], try db.read { reader in try jfs.read(reader: reader){ try $0.list()}.folders })
    }
    
    func testCreateJsonFileChangeFileChangeDecode() throws {
        XCTAssertEqual(try JsonFileChangeCreateFile(["a"], name: "b.txt"), try JsonFileChangeCreateFile(record: JsonFileChangeCreateFile(["a"], name: "b.txt").encode()))
    }
    
    func testJsonFileChangeDeleteFileDecode() throws {
        XCTAssertEqual(try JsonFileChangeDeleteFile(["a"], name: "b.txt"), try JsonFileChangeDeleteFile(record: JsonFileChangeDeleteFile(["a"], name: "b.txt").encode()))
    }
    
    func testJsonFileChangeRenameFileDecode() throws {
        XCTAssertEqual(try JsonFileChangeRenameFile(["a"], from: "b.txt", to: "c.txt"), try JsonFileChangeRenameFile(record: JsonFileChangeRenameFile(["a"], from: "b.txt", to: "c.txt").encode()))
    }
    
    func testJsonFileChangeCreateFolderDecode() throws {
        XCTAssertEqual(try JsonFileChangeCreateFolder(["a"], name: "b.txt"), try JsonFileChangeCreateFolder(record: JsonFileChangeCreateFolder(["a"], name: "b.txt").encode()))
    }
    
    func testJsonFileChangeDeleteFolderDecode() throws {
        XCTAssertEqual(try JsonFileChangeDeleteFolder(["a"], name: "b.txt"), try JsonFileChangeDeleteFolder(record: JsonFileChangeDeleteFolder(["a"], name: "b.txt").encode()))
    }
    
    func testJsonFileChangeRenameFolderDecode() throws {
        XCTAssertEqual(try JsonFileChangeRenameFolder(["a"], from: "b.txt", to: "c.txt"), try JsonFileChangeRenameFolder(record: JsonFileChangeRenameFolder(["a"], from: "b.txt", to: "c.txt").encode()))
    }
    
}

extension JsonFileChangeCreateFile: Equatable {
    
    public static func ==(lhs: JsonFileChangeCreateFile, rhs: JsonFileChangeCreateFile) -> Bool {
        return lhs.name == rhs.name && lhs.parent == rhs.parent && lhs.name == rhs.name
    }
    
}

extension JsonFileChangeDeleteFile: Equatable {
    
    public static func ==(lhs: JsonFileChangeDeleteFile, rhs: JsonFileChangeDeleteFile) -> Bool {
        return lhs.name == rhs.name && lhs.parent == rhs.parent && lhs.name == rhs.name
    }
    
}

extension JsonFileChangeRenameFile: Equatable {
    
    public static func ==(lhs: JsonFileChangeRenameFile, rhs: JsonFileChangeRenameFile) -> Bool {
        return lhs.parent == rhs.parent && lhs.from == rhs.from && lhs.to == rhs.to
    }
    
}

extension JsonFileChangeCreateFolder: Equatable {
    
    public static func ==(lhs: JsonFileChangeCreateFolder, rhs: JsonFileChangeCreateFolder) -> Bool {
        return lhs.name == rhs.name && lhs.parent == rhs.parent && lhs.name == rhs.name
    }
    
}

extension JsonFileChangeDeleteFolder: Equatable {
    
    public static func ==(lhs: JsonFileChangeDeleteFolder, rhs: JsonFileChangeDeleteFolder) -> Bool {
        return lhs.name == rhs.name && lhs.parent == rhs.parent && lhs.name == rhs.name
    }
    
}

extension JsonFileChangeRenameFolder: Equatable {
    
    public static func ==(lhs: JsonFileChangeRenameFolder, rhs: JsonFileChangeRenameFolder) -> Bool {
        return lhs.parent == rhs.parent && lhs.from == rhs.from && lhs.to == rhs.to
    }
    
}

extension JsonFileChangeJson: Equatable {
    
    public static func ==(lhs: JsonFileChangeJson, rhs: JsonFileChangeJson) -> Bool {
        return lhs.paths == rhs.paths && lhs.from == rhs.from && lhs.to == rhs.to
    }
    
}
