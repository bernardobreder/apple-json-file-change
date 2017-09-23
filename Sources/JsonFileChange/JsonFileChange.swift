//
//  JsonFileSystem.swift
//  JsonFileChange
//
//  Created by Bernardo Breder on 12/01/17.
//
//

import Foundation
#if SWIFT_PACKAGE
import Json
import FileSystem
import DataStore
import IndexLiteral
import Literal
import DatabaseFileSystem
import JsonTrack
#endif

public class JsonFileChange {
    
    public let databaseFileSystem = DatabaseFileSystem()
    
    public var changes: [JsonFileChangeProtocol] = []
    
    public init() {}
    
    public func read<T>(reader: DataStoreReader, _ callback: @escaping (JsonFileChangeFileReader) throws -> T) throws -> T {
        return try databaseFileSystem.read(reader: reader) { rdb in return try callback(JsonFileChangeFileReader(reader: rdb)) }
    }
    
    public func write(writer: DataStoreWriter, _ callback: @escaping (JsonFileChangeFileWriter) throws -> Void) throws {
        try databaseFileSystem.write(writer: writer) { wdb in try callback(JsonFileChangeFileWriter(track: self, writer: wdb)) }
    }
    
    public func revert(writer: DataStoreWriter) throws {
        try databaseFileSystem.write(writer: writer) { wdb in
            try changes.reversed().forEach { c in try c.revert(writer: wdb) }
        }
    }
    
}

public enum JsonFileChangeError: Error {
    case parentFolderNotFound(String)
    case decodeChange
}
