//
//  JsonFileChangeTests.swift
//  JsonFileChange
//
//  Created by Bernardo Breder.
//
//

import XCTest
@testable import JsonFileChangeTests

extension ChangeTests {

	static var allTests : [(String, (ChangeTests) -> () throws -> Void)] {
		return [
			("testCodec", testCodec),
			("testCreateJsonFileChangeFile", testCreateJsonFileChangeFile),
			("testCreateJsonFileChangeFileChangeDecode", testCreateJsonFileChangeFileChangeDecode),
			("testJsonFileChangeCreateFolder", testJsonFileChangeCreateFolder),
			("testJsonFileChangeCreateFolderDecode", testJsonFileChangeCreateFolderDecode),
			("testJsonFileChangeDeleteFile", testJsonFileChangeDeleteFile),
			("testJsonFileChangeDeleteFileDecode", testJsonFileChangeDeleteFileDecode),
			("testJsonFileChangeDeleteFolder", testJsonFileChangeDeleteFolder),
			("testJsonFileChangeDeleteFolderDecode", testJsonFileChangeDeleteFolderDecode),
			("testJsonFileChangeRenameFile", testJsonFileChangeRenameFile),
			("testJsonFileChangeRenameFileDecode", testJsonFileChangeRenameFileDecode),
			("testJsonFileChangeRenameFolder", testJsonFileChangeRenameFolder),
			("testJsonFileChangeRenameFolderDecode", testJsonFileChangeRenameFolderDecode),
		]
	}

}

extension JsonFileChangeTests {

	static var allTests : [(String, (JsonFileChangeTests) -> () throws -> Void)] {
		return [
			("testCreateFile", testCreateFile),
			("testCreateFileError", testCreateFileError),
			("testCreateFolder", testCreateFolder),
			("testCreateFolderFile", testCreateFolderFile),
			("testRead", testRead),
			("testRenameFile", testRenameFile),
			("testRenameFolder", testRenameFolder),
		]
	}

}

XCTMain([
	testCase(ChangeTests.allTests),
	testCase(JsonFileChangeTests.allTests),
])

