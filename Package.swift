//
//  Package.swift
//  JsonFileChange
//
//

import PackageDescription

let package = Package(
	name: "JsonFileChange",
	targets: [
		Target(name: "JsonFileChange", dependencies: ["DatabaseFileSystem", "Json", "JsonTrack", "Literal"]),
		Target(name: "Array", dependencies: []),
		Target(name: "AtomicValue", dependencies: []),
		Target(name: "DataStore", dependencies: ["Array", "AtomicValue", "Dictionary", "FileSystem", "IndexLiteral", "Json", "Literal", "Optional", "Regex"]),
		Target(name: "DatabaseFileSystem", dependencies: ["Array", "AtomicValue", "DataStore", "Dictionary", "FileSystem", "IndexLiteral", "Json", "Literal", "Optional", "Regex"]),
		Target(name: "Dictionary", dependencies: []),
		Target(name: "FileSystem", dependencies: []),
		Target(name: "IndexLiteral", dependencies: []),
		Target(name: "Json", dependencies: ["Array", "IndexLiteral", "Literal"]),
		Target(name: "JsonTrack", dependencies: ["Array", "IndexLiteral", "Json", "Literal"]),
		Target(name: "Literal", dependencies: []),
		Target(name: "Optional", dependencies: []),
		Target(name: "Regex", dependencies: []),
	]
)

