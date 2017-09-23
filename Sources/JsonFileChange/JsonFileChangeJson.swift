//
//  JsonFileChangeJson.swift
//  JsonFileChange
//
//  Created by Bernardo Breder on 29/01/17.
//
//

import Foundation

#if SWIFT_PACKAGE
    import JsonTrack
    import Json
    import Literal
    import IndexLiteral
#endif


public class JsonFileChangeJsonReader {
    
    private let json: Json
    
    public init(json: Json) {
        self.json = json
    }
    
    public subscript(_ array: [IndexLiteral]) -> Literal? { get {
        return json[array].literal
        } }
    
}

public class JsonFileChangeJsonWriter: JsonFileChangeJsonReader {
    
    private let JsonFileChange: JsonFileChange
    
    private let jsonTrack: JsonTrack
    
    public init(track: JsonFileChange, json: Json) {
        self.JsonFileChange = track
        self.jsonTrack = JsonTrack(json: json)
        super.init(json: json)
    }
    
    @discardableResult
    public func apply(_ paths: [IndexLiteral], value: Literal) -> Self {
        jsonTrack.apply(paths, value: value); return self
    }
    
    @discardableResult
    public func applyArray(_ paths: [IndexLiteral]) -> Self {
        jsonTrack.applyArray(paths); return self
    }
    
    @discardableResult
    public func applyDictionary(_ paths: [IndexLiteral]) -> Self {
        jsonTrack.applyDictionary(paths); return self
    }
    
    public var changes: [JsonTrackChange] {
        return jsonTrack.changes
    }
    
}
