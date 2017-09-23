//
//  JsonFileSystemTests.swift
//  JsonFileSystemTests
//
//  Created by Bernardo Breder on 14/01/17.
//
//

import XCTest
import Foundation
@testable import DataStore
@testable import JsonFileChange
@testable import Json
@testable import Literal

class JsonFileChangeTests: XCTestCase {
    
    func testRead() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let jfs = JsonFileChange()
        try db.write { writer in try jfs.write(writer: writer) {try $0.createFile([], name: "a.txt")} }
        try db.read { reader in try jfs.read(reader: reader) {_ = try $0.list() } }
    }
    
    func testCreateFile() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let jfs = JsonFileChange()
        try db.write { writer in try jfs.write(writer: writer) {try $0.createFile([], name: "a.txt")} }
        XCTAssertEqual(["a.txt"], try db.read { reader in try jfs.read(reader: reader){try $0.list()}.files.sorted() })
        try db.write { writer in try jfs.write(writer: writer) {try $0.createFile([], name: "b.txt")} }
        XCTAssertEqual(["a.txt", "b.txt"], try db.read { reader in try jfs.read(reader: reader){try $0.list()}.files.sorted() })
    }
    
    func testCreateFileError() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let jfs = JsonFileChange()
        XCTAssertNil(try? db.write { writer in try jfs.write(writer: writer) {try $0.createFile(["a"], name: "a.txt")} })
        XCTAssertEqual([], try db.read { reader in try jfs.read(reader: reader){try $0.list()}.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a"])}.files.sorted() })
        
    }
    
    func testCreateFolder() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let jfs = JsonFileChange()
        try db.write { writer in try jfs.write(writer: writer) {try $0.createFolder([], name: "a")} }
        XCTAssertEqual(["a"], try db.read { reader in try jfs.read(reader: reader){try $0.list()}.folders.sorted() })
        try db.write { writer in try jfs.write(writer: writer) {try $0.createFolder([], name: "b")} }
        XCTAssertEqual(["a", "b"], try db.read { reader in try jfs.read(reader: reader){try $0.list()}.folders.sorted() })
        try db.write { writer in try jfs.write(writer: writer) {try $0.createFolder(["a"], name: "c")} }
        XCTAssertEqual(["a", "b"], try db.read { reader in try jfs.read(reader: reader){try $0.list()}.folders.sorted() })
        XCTAssertEqual(["c"], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a"])}.folders.sorted() })
    }
    
    func testCreateFolderFile() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let jfs = JsonFileChange()
        
        try db.write { writer in try jfs.write(writer: writer) {try $0.createFolder([], name: "a")} }
        XCTAssertEqual(["a"], try db.read { reader in try jfs.read(reader: reader){try $0.list()}.folders.sorted() })
        
        try db.write { writer in try jfs.write(writer: writer) {try $0.createFolder([], name: "b")} }
        XCTAssertEqual(["a", "b"], try db.read { reader in try jfs.read(reader: reader){try $0.list()}.folders.sorted() })
        
        try db.write { writer in try jfs.write(writer: writer) {try $0.createFolder(["a"], name: "c")} }
        XCTAssertEqual(["c"], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a"])}.folders.sorted() })
        
        try db.write { writer in try jfs.write(writer: writer) {try $0.createFolder(["a", "c"], name: "d")} }
        XCTAssertEqual(["a", "b"], try db.read { reader in try jfs.read(reader: reader){try $0.list()}.folders.sorted() })
        XCTAssertEqual(["c"], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a"])}.folders.sorted() })
        XCTAssertEqual(["d"], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a", "c"])}.folders.sorted() })
        
        try db.write { writer in try jfs.write(writer: writer) {try $0.createFile(["a", "c", "d"], name: "e.txt")} }
        XCTAssertEqual(["a", "b"], try db.read { reader in try jfs.read(reader: reader){try $0.list()}.folders.sorted() })
        XCTAssertEqual(["c"], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a"])}.folders.sorted() })
        XCTAssertEqual(["d"], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a", "c"])}.folders.sorted() })
        XCTAssertEqual(["e.txt"], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a", "c", "d"])}.files.sorted() })
        
        try db.write { writer in try jfs.write(writer: writer) {try $0.createFile(["a", "c"], name: "f.txt")} }
        XCTAssertEqual(["a", "b"], try db.read { reader in try jfs.read(reader: reader){try $0.list()}.folders.sorted() })
        XCTAssertEqual(["c"], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a"])}.folders.sorted() })
        XCTAssertEqual(["d"], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a", "c"])}.folders.sorted() })
        XCTAssertEqual(["f.txt"], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a", "c"])}.files.sorted() })
        XCTAssertEqual(["e.txt"], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a", "c", "d"])}.files.sorted() })
        
        try db.write { writer in try jfs.write(writer: writer) {try $0.createFile(["a"], name: "g.txt")} }
        XCTAssertEqual(["a", "b"], try db.read { reader in try jfs.read(reader: reader){try $0.list()}.folders.sorted() })
        XCTAssertEqual(["c"], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a"])}.folders.sorted() })
        XCTAssertEqual(["g.txt"], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a"])}.files.sorted() })
        XCTAssertEqual(["d"], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a", "c"])}.folders.sorted() })
        XCTAssertEqual(["f.txt"], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a", "c"])}.files.sorted() })
        XCTAssertEqual(["e.txt"], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a", "c", "d"])}.files.sorted() })
        
        try db.write { writer in try jfs.write(writer: writer) {try $0.deleteFile(["a"], name: "g.txt")} }
        XCTAssertEqual(["a", "b"], try db.read { reader in try jfs.read(reader: reader){try $0.list()}.folders.sorted() })
        XCTAssertEqual(["c"], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a"])}.folders.sorted() })
        XCTAssertEqual(["d"], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a", "c"])}.folders.sorted() })
        XCTAssertEqual(["f.txt"], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a", "c"])}.files.sorted() })
        XCTAssertEqual(["e.txt"], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a", "c", "d"])}.files.sorted() })
        
        try db.write { writer in try jfs.write(writer: writer) {try $0.deleteFolder(["a"], name: "c")} }
        XCTAssertEqual(["a", "b"], try db.read { reader in try jfs.read(reader: reader){try $0.list()}.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a"])}.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a", "c"])}.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a", "c", "d"])}.folders.sorted() })
        
        try db.write { writer in try jfs.write(writer: writer) {try $0.deleteFolder([], name: "a")} }
        XCTAssertEqual(["b"], try db.read { reader in try jfs.read(reader: reader){try $0.list()}.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a"])}.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a", "c"])}.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a", "c", "d"])}.folders.sorted() })
        
        try db.write { writer in try jfs.write(writer: writer) {try $0.deleteFolder([], name: "b")} }
        XCTAssertEqual([], try db.read { reader in try jfs.read(reader: reader){try $0.list()}.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a"])}.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a", "c"])}.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a", "c", "d"])}.folders.sorted() })
    }
    
    func testRenameFile() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let jfs = JsonFileChange()
        try db.write { writer in try jfs.write(writer: writer) {try $0.createFile([], name: "a.txt")} }
        XCTAssertEqual(["a.txt"], try db.read { reader in try jfs.read(reader: reader){try $0.list()}.files.sorted() })
        try db.write { writer in try jfs.write(writer: writer) {try $0.renameFile([], oldName: "a.txt", newName: "b.txt")} }
        XCTAssertEqual(["b.txt"], try db.read { reader in try jfs.read(reader: reader){try $0.list()}.files.sorted() })
    }
    
    func testRenameFolder() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let jfs = JsonFileChange()
        try db.write { writer in try jfs.write(writer: writer) {try $0.createFolder([], name: "a")} }
        try db.write { writer in try jfs.write(writer: writer) {try $0.createFolder(["a"], name: "b")} }
        XCTAssertEqual(["a"], try db.read { reader in try jfs.read(reader: reader){try $0.list()}.folders.sorted() })
        XCTAssertEqual(["b"], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a"])}.folders.sorted() })
        try db.write { writer in try jfs.write(writer: writer) {try $0.renameFolder(["a"], oldName: "b", newName: "c")} }
        XCTAssertEqual(["a"], try db.read { reader in try jfs.read(reader: reader){try $0.list()}.folders.sorted() })
        XCTAssertEqual(["c"], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a"])}.folders.sorted() })
        try db.write { writer in try jfs.write(writer: writer) {try $0.renameFolder([], oldName: "a", newName: "d")} }
        XCTAssertEqual(["d"], try db.read { reader in try jfs.read(reader: reader){try $0.list()}.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a"])}.folders.sorted() })
        XCTAssertEqual(["c"], try db.read { reader in try jfs.read(reader: reader){try $0.list(["d"])}.folders.sorted() })
        try db.write { writer in try jfs.write(writer: writer) {try $0.renameFolder(["d"], oldName: "c", newName: "e")} }
        XCTAssertEqual(["d"], try db.read { reader in try jfs.read(reader: reader){try $0.list()}.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try jfs.read(reader: reader){try $0.list(["a"])}.folders.sorted() })
        XCTAssertEqual(["e"], try db.read { reader in try jfs.read(reader: reader){try $0.list(["d"])}.folders.sorted() })
    }

}
