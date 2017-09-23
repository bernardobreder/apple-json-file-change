//
//  Change.swift
//  FileStore
//
//  Created by Bernardo Breder on 05/01/17.
//
//

import Foundation
#if SWIFT_PACKAGE
import Json
import Literal
import IndexLiteral
import DataStore
import Optional
import DatabaseFileSystem
#endif

public protocol JsonFileChangeProtocol {
    
    var type: JsonFileChangeType { get }
    
    init(record: DataStoreRecord) throws
    
    func apply(writer: DatabaseFileSystemWriter) throws
    
    func revert(writer: DatabaseFileSystemWriter) throws
    
    func encode() throws -> DataStoreRecord
    
}

public enum JsonFileChangeType: Int {
    
    case createFile = 1
    case deleteFile
    case renameFile
    case createFolder
    case deleteFolder
    case renameFolder
    case changeJson
    
    public func decode(record: DataStoreRecord) throws -> JsonFileChangeProtocol {
        switch self {
        case .createFile: return try JsonFileChangeCreateFile(record: record)
        case .deleteFile: return try JsonFileChangeDeleteFile(record: record)
        case .renameFile: return try JsonFileChangeRenameFile(record: record)
        case .createFolder: return try JsonFileChangeCreateFolder(record: record)
        case .deleteFolder: return try JsonFileChangeDeleteFolder(record: record)
        case .renameFolder: return try JsonFileChangeRenameFolder(record: record)
        case .changeJson: return try JsonFileChangeJson(record: record)
        }
    }
    
}

public class JsonFileChangeDecoder {
    
    public class func decode(record: DataStoreRecord) throws -> JsonFileChangeProtocol {
        guard let type = JsonFileChangeType(rawValue: try record.requireClassId()) else { throw JsonFileChangeChangeError.classIdUnknown }
        return try type.decode(record: record)
    }
    
}

public struct JsonFileChangeJson: JsonFileChangeProtocol {
    
    public let type = JsonFileChangeType.changeJson
    
    public let parents: [String]
    
    public let name: String
    
    public let paths: [IndexLiteral]
    
    public let from: Json
    
    public let to: Json
    
    public init(record: DataStoreRecord) throws {
        let parents = try record.requireStringArray("parents")
        let name = try record.requireString("name")
        let paths = try record.requireStringComponents("path", decoder: IndexLiteral.init(encoded:))
        let from = try record.requireJson("from")
        let to = try record.requireJson("to")
        self.init(parents: parents, name: name, paths: paths, from: from, to: to)
    }
    
    public init(parents: [String], name: String, paths: [IndexLiteral], from: Json, to: Json) {
        self.parents = parents
        self.name = name
        self.paths = paths
        self.from = from
        self.to = to
    }
    
    public func apply(writer: DatabaseFileSystemWriter) throws {
        let json = try writer.readFile(parents, name: name)
        json[paths] = to
        try writer.writeFile(parents, name: name, json: json)
    }
    
    public func revert(writer: DatabaseFileSystemWriter) throws {
        let json = try writer.readFile(parents, name: name)
        json[paths] = from
        try writer.writeFile(parents, name: name, json: json)
    }
    
    public func encode() throws -> DataStoreRecord {
        return DataStoreRecord(json: Json([DataStoreRecord.classid: type.rawValue,
                                               "parents": paths,
                                               "name": name,
                                               "path": paths.map{$0.encode()}.reducePath(),
                                               "from": from.jsonToInlineString(sorted: true),
                                               "to": to.jsonToInlineString(sorted: true)]))
    }
    
}

public struct JsonFileChangeCreateFile: JsonFileChangeProtocol {
    
    public let type = JsonFileChangeType.createFile
    
    public let parent: String
    
    public let parents: [String]
    
    public let name: String
    
    public init(_ parents: [String], name: String) throws {
        self.parent = parents.reducePath()
        self.parents = parent.components()
        self.name = name
    }
    
    public init(record: DataStoreRecord) throws {
        let parents = try record.requireStringComponents("parent", decoder: {$0})
        let name = try record.requireString("name")
        try self.init(parents, name: name)
    }
    
    public func apply(writer: DatabaseFileSystemWriter) throws {
        try writer.createFile(parents, name: name)
    }
    
    public func revert(writer: DatabaseFileSystemWriter) throws {
        try writer.deleteFile(parents, name: name)
    }
    
    public func encode() throws -> DataStoreRecord {
        return DataStoreRecord(json: Json([
            DataStoreRecord.classid: type.rawValue,
            "parent": parent, "name": name]))
    }
    
}

public struct JsonFileChangeDeleteFile: JsonFileChangeProtocol {
    
    public let type = JsonFileChangeType.deleteFile
    
    public let parent: String
    
    public let parents: [String]
    
    public let name: String
    
    public init(_ parents: [String], name: String) throws {
        self.parent = parents.reducePath()
        self.parents = parent.components()
        self.name = name
    }

    public init(record: DataStoreRecord) throws {
        let parents = try record.requireStringComponents("parent", decoder: {$0})
        let name = try record.requireString("name")
        try self.init(parents, name: name)
    }
    
    public func apply(writer: DatabaseFileSystemWriter) throws {
        try writer.deleteFile(parents, name: name)
    }
    
    public func revert(writer: DatabaseFileSystemWriter) throws {
        try writer.createFile(parents, name: name)
    }
    
    public func encode() throws -> DataStoreRecord {
       return DataStoreRecord(json: Json([
        DataStoreRecord.classid: type.rawValue,
        "parent": parent, "name": name]))
    }
    
}

public struct JsonFileChangeRenameFile: JsonFileChangeProtocol {
    
    public let type = JsonFileChangeType.renameFile
    
    public let parent: String
    
    public let parents: [String]
    
    public let from: String
    
    public let to: String
    
    public init(_ parents: [String], from: String, to: String) throws {
        self.parent = parents.reducePath()
        self.parents = parent.components()
        self.from = from
        self.to = to
    }

    public init(record: DataStoreRecord) throws {
        let parents = try record.requireStringComponents("parent", decoder: {$0})
        let from = try record.requireString("from")
        let to = try record.requireString("to")
        try self.init(parents, from: from, to: to)
    }
    
    public func apply(writer: DatabaseFileSystemWriter) throws {
        try writer.renameFile(parents, from: from, to: to)
    }
    
    public func revert(writer: DatabaseFileSystemWriter) throws {
        try writer.renameFile(parents, from: to, to: from)
    }
    
    public func encode() throws -> DataStoreRecord {
     return DataStoreRecord(json: Json([
        DataStoreRecord.classid: type.rawValue,
        "parent": parent, "from": from, "to": to]))
    }
    
}

public struct JsonFileChangeCreateFolder: JsonFileChangeProtocol {
    
    public let type = JsonFileChangeType.createFolder
    
    public let parent: String
    
    public let parents: [String]
    
    public let name: String
    
    public init(_ parents: [String], name: String) throws {
        self.parent = parents.reducePath()
        self.parents = parent.components()
        self.name = name
    }

    public init(record: DataStoreRecord) throws {
        let parents = try record.requireStringComponents("parent", decoder: {$0})
        let name = try record.requireString("name")
        try self.init(parents, name: name)
    }
    
    public func apply(writer: DatabaseFileSystemWriter) throws {
        try writer.createFolder(parents, name: name)
    }
    
    public func revert(writer: DatabaseFileSystemWriter) throws {
        try writer.deleteFolder(parents, name: name)
    }
    
    public func encode() throws -> DataStoreRecord {
       return DataStoreRecord(json: Json([
        DataStoreRecord.classid: type.rawValue,
        "parent": parent, "name": name]))
    }
    
}

public struct JsonFileChangeDeleteFolder: JsonFileChangeProtocol {
    
    public let type = JsonFileChangeType.deleteFolder
    
    public let parent: String
    
    public let parents: [String]
    
    public let name: String
    
    public init(_ parents: [String], name: String) throws {
        self.parent = parents.reducePath()
        self.parents = parent.components()
        self.name = name
    }

    public init(record: DataStoreRecord) throws {
        let parents = try record.requireStringComponents("parent", decoder: {$0})
        let name = try record.requireString("name")
        try self.init(parents, name: name)
    }
    
    public func apply(writer: DatabaseFileSystemWriter) throws {
        try writer.deleteFolder(parents, name: name)
    }
    
    public func revert(writer: DatabaseFileSystemWriter) throws {
        try writer.createFolder(parents, name: name)
    }
    
    public func encode() throws -> DataStoreRecord {
       return DataStoreRecord(json: Json([
        DataStoreRecord.classid: type.rawValue,
        "parent": parent, "name": name]))
    }
    
}

public struct JsonFileChangeRenameFolder: JsonFileChangeProtocol {
    
    public let type = JsonFileChangeType.renameFolder
    
    public let parent: String
    
    public let parents: [String]
    
    public let from: String
    
    public let to: String
    
    public init(_ parents: [String], from: String, to: String) throws {
        self.parent = parents.reducePath()
        self.parents = parent.components()
        self.from = from
        self.to = to
    }

    public init(record: DataStoreRecord) throws {
        let parents = try record.requireStringComponents("parent", decoder: {$0})
        let from = try record.requireString("from")
        let to = try record.requireString("to")
        try self.init(parents, from: from, to: to)
    }
    
    public func apply(writer: DatabaseFileSystemWriter) throws {
        try writer.renameFolder(parents, from: from, to: to)
    }
    
    public func revert(writer: DatabaseFileSystemWriter) throws {
        try writer.renameFolder(parents, from: to, to: from)
    }
    
    public func encode() throws -> DataStoreRecord {
       return DataStoreRecord(json: Json([
        DataStoreRecord.classid: type.rawValue,
        "parent": parent, "from": from, "to": to]))
    }
    
}

public enum JsonFileChangeChangeError: Error {
    case classIdUnknown
}
