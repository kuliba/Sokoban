//
//  LocalAgentTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 02.02.2022.
//

import XCTest
@testable import ForaBank

class LocalAgentTests: XCTestCase {

    static let context = LocalAgent.Context(cacheFolderName: "cache", encoder: .serverDate, decoder: .serverDate, fileManager: FileManager.default)
    let localAgent = LocalAgent(context: LocalAgentTests.context)
 
    override func tearDownWithError() throws {
        
        let rootFolderURL = try localAgent.rootFolderURL()
        let urls = try Self.context.fileManager.contentsOfDirectory(at: rootFolderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        for url in urls {
            
            try Self.context.fileManager.removeItem(at: url)
        }
    }

    //MARK: - FileName
    
    func testFileName_Item() throws {

        // when
        let result = localAgent.fileName(for: SampleType.self)
        
        // then
        XCTAssertEqual(result, "sampletype.json")
    }
    
    func testFileName_Array() throws {

        // when
        let result = localAgent.fileName(for: [SampleType].self)
        
        // then
        XCTAssertEqual(result, "array_sampletype.json")
    }
    
    func testFileName_Dictionary() throws {

        // when
        let result = localAgent.fileName(for: Dictionary<String, SampleType>.self)
        
        // then
        XCTAssertEqual(result, "dictionary_string_sampletype.json")
    }
    
    func testFileName_Set() throws {

        // when
        let result = localAgent.fileName(for: Set<SampleType>.self)
        
        // then
        XCTAssertEqual(result, "set_sampletype.json")
    }
    
    //MARK: - Store
    
    func testStore_Item() throws {
        
        // given
        let sample = SampleType()

        // when
        try localAgent.store(sample)
        
        // then
        let rootFolderURL = try localAgent.rootFolderURL()
        let fileUrl = rootFolderURL.appendingPathComponent("sampletype.json")
        let data = try Data(contentsOf: fileUrl)
        let result = try JSONDecoder().decode(SampleType.self, from: data)
        
        XCTAssertEqual(result, sample)
    }
    
    func testStore_Array() throws {
        
        // given
        let sample = SampleType()

        // when
        try localAgent.store([sample])
        
        // then
        let rootFolderURL = try localAgent.rootFolderURL()
        let fileUrl = rootFolderURL.appendingPathComponent("array_sampletype.json")
        let data = try Data(contentsOf: fileUrl)
        let result = try JSONDecoder().decode([SampleType].self, from: data)
        
        XCTAssertEqual(result, [sample])
    }
    
    //MARK: - Load
    
    func testLoad_Item() throws {
        
        // given
        let sample = SampleType()

        // when
        try localAgent.store(sample)
        let result = localAgent.load(type: SampleType.self)
        
        // then
        XCTAssertEqual(result, sample)
    }
    
    func testLoad_Array() throws {
        
        // given
        let sample = SampleType()

        // when
        try localAgent.store([sample])
        let result = localAgent.load(type: [SampleType].self)
        
        // then
        XCTAssertEqual(result, [sample])
    }
    
    //MARK: - Clear
    
    func testClear_Item() throws {
        
        // given
        let sample = SampleType()
        try localAgent.store(sample)
        let rootFolderURL = try localAgent.rootFolderURL()
        let fileUrl = rootFolderURL.appendingPathComponent("sampletype.json")
        XCTAssertTrue(Self.context.fileManager.fileExists(atPath: fileUrl.path))

        // when
        try localAgent.clear(type: SampleType.self)

        // then
        XCTAssertFalse(Self.context.fileManager.fileExists(atPath: fileUrl.path))
    }
    
    func testClear_Array() throws {
        
        // given
        let sample = SampleType()
        try localAgent.store([sample])
        let rootFolderURL = try localAgent.rootFolderURL()
        let fileUrl = rootFolderURL.appendingPathComponent("array_sampletype.json")
        XCTAssertTrue(Self.context.fileManager.fileExists(atPath: fileUrl.path))

        // when
        try localAgent.clear(type: [SampleType].self)

        // then
        XCTAssertFalse(Self.context.fileManager.fileExists(atPath: fileUrl.path))
    }
    
    //MARK: - Serial
    
    func testSerial_Item() throws {
        
        // given
        let sample = SampleType()
        let serial = UUID().uuidString
        try localAgent.store(sample, serial: serial)

        // when
        let result = localAgent.serial(for: SampleType.self)
        
        // then
        XCTAssertEqual(result, serial)
    }
    
    func testSerial_Array() throws {
        
        // given
        let sample = SampleType()
        let serial = UUID().uuidString
        try localAgent.store([sample], serial: serial)

        // when
        let result = localAgent.serial(for: [SampleType].self)
        
        // then
        XCTAssertEqual(result, serial)
    }
    
    func testSerial_Item_Clear() throws {
        
        // given
        let sample = SampleType()
        let serial = UUID().uuidString
        try localAgent.store(sample, serial: serial)

        // when
        try localAgent.clear(type: SampleType.self)
        
        // then
        XCTAssertNil(localAgent.serial(for: SampleType.self))
    }
    
    func testSerial_Array_Clear() throws {
        
        // given
        let sample = SampleType()
        let serial = UUID().uuidString
        try localAgent.store([sample], serial: serial)

        // when
        try localAgent.clear(type: [SampleType].self)
        
        // then
        XCTAssertNil(localAgent.serial(for: [SampleType].self))
    }
}

extension LocalAgentTests {
    
    struct SampleType: Cachable, Hashable, Equatable {
        
        var id = UUID()
    }
}
