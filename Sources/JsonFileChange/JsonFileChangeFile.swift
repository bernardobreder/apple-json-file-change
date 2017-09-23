//
//  JsonFileChangeFile.swift
//  JsonFileChange
//
//  Created by Bernardo Breder on 29/01/17.
//
//

import Foundation

#if SWIFT_PACKAGE
    import DatabaseFileSystem
#endif

public class JsonFileChangeFileReader {
    
    let reader: DatabaseFileSystemReader
    
    public init(reader: DatabaseFileSystemReader) {
        self.reader = reader
    }
    
    public func list(_ parents: [String] = []) throws -> (folders: [String], files: [String]) {
        return try reader.list(parents)
    }
    
    public func existFile(_ parents: [String], name: String) throws -> Bool {
        return try reader.existFile(parents, name: name)
    }
    
    public func read<T>(_ parents: [String], name: String, _ block: (JsonFileChangeJsonReader) throws -> T) throws -> T {
        let json = try reader.readFile(parents, name: name)
        return try block(JsonFileChangeJsonReader(json: json))
    }
    
}

public class JsonFileChangeFileWriter: JsonFileChangeFileReader {
    
    public let writer: DatabaseFileSystemWriter
    
    let track: JsonFileChange
    
    public init(track: JsonFileChange, writer: DatabaseFileSystemWriter) {
        self.writer = writer
        self.track = track
        super.init(reader: writer)
    }
    
    public func createFile(_ parents: [String], name: String) throws {
        let change = try JsonFileChangeCreateFile(parents, name: name)
        try change.apply(writer: writer)
        track.changes.append(change)
    }
    
    public func deleteFile(_ parents: [String], name: String) throws {
        let change = try JsonFileChangeDeleteFile(parents, name: name)
        try change.apply(writer: writer)
        track.changes.append(change)
    }
    
    public func renameFile(_ parents: [String], oldName: String, newName: String) throws {
        let change = try JsonFileChangeRenameFile(parents, from: oldName, to: newName)
        try change.apply(writer: writer)
        track.changes.append(change)
    }
    
    public func createFolder(_ parents: [String], name: String) throws {
        let change = try JsonFileChangeCreateFolder(parents, name: name)
        try change.apply(writer: writer)
        track.changes.append(change)
    }
    
    public func deleteFolder(_ parents: [String], name: String) throws {
        let paths = parents.appendAndReturn(name)
        var (folders, files) = try writer.list(paths, deep: true)
        folders.insert(paths.reducePath(), at: 0)
        for item in files {
            if let (parents, name) = item.components().componentsParentName() {
                let change = try JsonFileChangeDeleteFile(parents, name: name)
                try change.apply(writer: writer)
                track.changes.append(change)
            }
        }
        for item in folders.reversed() {
            if let (parents, name) = item.components().componentsParentName() {
                let change = try JsonFileChangeDeleteFolder(parents, name: name)
                try change.apply(writer: writer)
                track.changes.append(change)
            }
        }
    }
    
    public func renameFolder(_ parents: [String], oldName: String, newName: String) throws {
        let change = try JsonFileChangeRenameFolder(parents, from: oldName, to: newName)
        try change.apply(writer: writer)
        track.changes.append(change)
    }
    
    public func write(_ parents: [String], name: String, _ block: (JsonFileChangeJsonWriter) throws -> Void) throws {
        let json = try writer.readFile(parents, name: name)
        let jsonWriter = JsonFileChangeJsonWriter(track: track, json: json)
        try block(jsonWriter)
        track.changes.append(contentsOf: jsonWriter.changes.map { c in
            JsonFileChangeJson(parents: parents, name: name, paths: c.paths, from: c.from, to: c.to)
        })
        try writer.writeFile(parents, name: name, json: json)
    }
    
}
