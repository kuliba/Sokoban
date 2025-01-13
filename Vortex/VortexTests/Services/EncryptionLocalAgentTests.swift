//
//  EncryptionLocalAgentTests.swift
//  VortexTests
//
//  Created by Max Gribov on 24.07.2023.
//

import XCTest
@testable import Vortex

final class EncryptionLocalAgentTests: XCTestCase {
    
    static let context = LocalAgent.Context(cacheFolderName: "testCache", encoder: .serverDate, decoder: .serverDate, fileManager: FileManager.default)

    override func setUpWithError() throws {

        try removeCachedFiles()
    }

    override func tearDownWithError() throws {

        try removeCachedFiles()
    }
    
    //MARK: - File Name

    func test_fileNameForType_expectedFileName() throws {
        
        let (sut, _) = makeSUT()
        
        XCTAssertEqual(sut.fileName(for: Sample.self), "sample.json")
    }
    
    func test_fileNameForArray_expectedFileName() throws {
        
        let (sut, _) = makeSUT()
        
        XCTAssertEqual(sut.fileName(for: [Sample].self), "array_sample.json")
    }
    
    func test_fileNameForDictionary_expectedFileName() throws {
        
        let (sut, _) = makeSUT()
        
        XCTAssertEqual(sut.fileName(for: Dictionary<String, Sample>.self), "dictionary_string_sample.json")
    }
    
    func test_fileNameForSet_expectedFileName() throws {
        
        let (sut, _) = makeSUT()
        
        XCTAssertEqual(sut.fileName(for: Set<Sample>.self), "set_sample.json")
    }
    
    //MARK: - Store
    
    func test_store_encryptedDataOnDisk() throws {
        
        let (sut, encryptionAgentSpy) = makeSUT()
        let sample = Sample(value: "sample")

        // when
        try sut.store(sample)
        
        // then
        XCTAssertEqual(encryptionAgentSpy.requests, [.encrypt])
        XCTAssertEqual(try dataFromFile(named: "sample.json"), encryptionAgentSpy.encryptedResults.first)
    }
    
    func test_storeArray_encryptedDataOnDisk() throws {
        
        let (sut, encryptionAgentSpy) = makeSUT()
        let sample = [Sample(value: "sample")]

        // when
        try sut.store(sample)
        
        // then
        XCTAssertEqual(encryptionAgentSpy.requests, [.encrypt])
        XCTAssertEqual(try dataFromFile(named: "array_sample.json"), encryptionAgentSpy.encryptedResults.first)
    }
    
    func test_storeDictionary_encryptedDataOnDisk() throws {
        
        let (sut, encryptionAgentSpy) = makeSUT()
        let sample = ["sample": Sample(value: "sample")]

        // when
        try sut.store(sample)
        
        // then
        XCTAssertEqual(encryptionAgentSpy.requests, [.encrypt])
        XCTAssertEqual(try dataFromFile(named: "dictionary_string_sample.json"), encryptionAgentSpy.encryptedResults.first)
    }
    
    func test_storeSet_encryptedDataOnDisk() throws {
        
        let (sut, encryptionAgentSpy) = makeSUT()
        let sample = Set([Sample(value: "sample")])

        // when
        try sut.store(sample)
        
        // then
        XCTAssertEqual(encryptionAgentSpy.requests, [.encrypt])
        XCTAssertEqual(try dataFromFile(named: "set_sample.json"), encryptionAgentSpy.encryptedResults.first)
    }
    
    //MARK: - Load
    
    func test_load_resultEqualToInitialSample() throws {
        
        let (sut, encryptionAgentSpy) = makeSUT()
        let sample = Sample(value: "sample")

        // when
        try sut.store(sample)
        let result = sut.load(type: Sample.self)
        
        // then
        XCTAssertEqual(encryptionAgentSpy.requests, [.encrypt, .decrypt])
        XCTAssertEqual(try dataFromFile(named: "sample.json"), encryptionAgentSpy.encryptedResults.first)
        XCTAssertEqual(result, sample)
    }
    
    func test_loadArray_resultEqualToInitialSample() throws {
        
        let (sut, encryptionAgentSpy) = makeSUT()
        let sample = [Sample(value: "sample")]

        // when
        try sut.store(sample)
        let result = sut.load(type: [Sample].self)
        
        // then
        XCTAssertEqual(encryptionAgentSpy.requests, [.encrypt, .decrypt])
        XCTAssertEqual(try dataFromFile(named: "array_sample.json"), encryptionAgentSpy.encryptedResults.first)
        XCTAssertEqual(result, sample)
    }
    
    func test_loadDictionary_resultEqualToInitialSample() throws {
        
        let (sut, encryptionAgentSpy) = makeSUT()
        let sample = ["sample" : Sample(value: "sample")]

        // when
        try sut.store(sample)
        let result = sut.load(type: Dictionary<String, Sample>.self)
        
        // then
        XCTAssertEqual(encryptionAgentSpy.requests, [.encrypt, .decrypt])
        XCTAssertEqual(try dataFromFile(named: "dictionary_string_sample.json"), encryptionAgentSpy.encryptedResults.first)
        XCTAssertEqual(result, sample)
    }
    
    func test_loadSet_resultEqualToInitialSample() throws {
        
        let (sut, encryptionAgentSpy) = makeSUT()
        let sample = Set([Sample(value: "sample")])

        // when
        try sut.store(sample)
        let result = sut.load(type: Set<Sample>.self)
        
        // then
        XCTAssertEqual(encryptionAgentSpy.requests, [.encrypt, .decrypt])
        XCTAssertEqual(try dataFromFile(named: "set_sample.json"), encryptionAgentSpy.encryptedResults.first)
        XCTAssertEqual(result, sample)
    }
    
    //MARK: - Clear
    
    func test_clear_resultEqualToInitialSample() throws {
        
        let (sut, _) = makeSUT()
        let sample = Sample(value: "sample")
        let fileName = "sample.json"

        // when
        try sut.store(sample)
        try expectFile(named: fileName, exists: true)
        try sut.clear(type: Sample.self)
        
        // then
        try expectFile(named: fileName, exists: false)
    }
    
    func test_clearArray_resultEqualToInitialSample() throws {
        
        let (sut, _) = makeSUT()
        let sample = [Sample(value: "sample")]
        let fileName = "array_sample.json"

        // when
        try sut.store(sample)
        try expectFile(named: fileName, exists: true)
        try sut.clear(type: [Sample].self)
        
        // then
        try expectFile(named: fileName, exists: false)
    }
    
    func test_clearDictionary_resultEqualToInitialSample() throws {
        
        let (sut, _) = makeSUT()
        let sample = ["sample" : Sample(value: "sample")]
        let fileName = "dictionary_string_sample.json"

        // when
        try sut.store(sample)
        try expectFile(named: fileName, exists: true)
        try sut.clear(type: Dictionary<String, Sample>.self)
        
        // then
        try expectFile(named: fileName, exists: false)
    }
    
    func test_clearSet_resultEqualToInitialSample() throws {
        
        let (sut, _) = makeSUT()
        let sample = Set([Sample(value: "sample")])
        let fileName = "set_sample.json"

        // when
        try sut.store(sample)
        try expectFile(named: fileName, exists: true)
        try sut.clear(type: Set<Sample>.self)
        
        // then
        try expectFile(named: fileName, exists: false)
    }
    
    //MARK: - Serial
    
    func test_serial_storedSerialEqualToSampleSerial() throws {
        
        let (sut, _) = makeSUT()
        let sample = Sample(value: "sample")
        let serial = UUID().uuidString

        // when
        try sut.store(sample, serial: serial)
        let result = sut.serial(for: Sample.self)
        
        // then
        XCTAssertEqual(result, serial)
    }
    
    func test_serialArray_storedSerialEqualToSampleSerial() throws {
        
        let (sut, _) = makeSUT()
        let sample = [Sample(value: "sample")]
        let serial = UUID().uuidString

        // when
        try sut.store(sample, serial: serial)
        let result = sut.serial(for: [Sample].self)
        
        // then
        XCTAssertEqual(result, serial)
    }
    
    func test_serialDictionary_storedSerialEqualToSampleSerial() throws {
        
        let (sut, _) = makeSUT()
        let sample = ["sample" : Sample(value: "sample")]
        let serial = UUID().uuidString

        // when
        try sut.store(sample, serial: serial)
        let result = sut.serial(for: Dictionary<String, Sample>.self)
        
        // then
        XCTAssertEqual(result, serial)
    }
    
    func test_serialSet_storedSerialEqualToSampleSerial() throws {
        
        let (sut, _) = makeSUT()
        let sample = Set([Sample(value: "sample")])
        let serial = UUID().uuidString

        // when
        try sut.store(sample, serial: serial)
        let result = sut.serial(for: Set<Sample>.self)
        
        // then
        XCTAssertEqual(result, serial)
    }
    
    func test_serial_clear_storedSerialIsNil() throws {
        
        let (sut, _) = makeSUT()
        let sample = Sample(value: "sample")
        let serial = UUID().uuidString

        // when
        try sut.store(sample, serial: serial)
        try sut.clear(type: Sample.self)
        let result = sut.serial(for: Sample.self)
        
        // then
        XCTAssertNil(result)
    }
    
    func test_serialArray_clear_storedSerialIsNil() throws {
        
        let (sut, _) = makeSUT()
        let sample = [Sample(value: "sample")]
        let serial = UUID().uuidString

        // when
        try sut.store(sample, serial: serial)
        try sut.clear(type: [Sample].self)
        let result = sut.serial(for: [Sample].self)
        
        // then
        XCTAssertNil(result)
    }
    
    func test_serialDictionary_clear_storedSerialIsNil() throws {
        
        let (sut, _) = makeSUT()
        let sample = ["sample" : Sample(value: "sample")]
        let serial = UUID().uuidString

        // when
        try sut.store(sample, serial: serial)
        try sut.clear(type: Dictionary<String, Sample>.self)
        let result = sut.serial(for: Dictionary<String, Sample>.self)
        
        // then
        XCTAssertNil(result)
    }
    
    func test_serialSet_clear_storedSerialIsNil() throws {
        
        let (sut, _) = makeSUT()
        let sample = Set([Sample(value: "sample")])
        let serial = UUID().uuidString

        // when
        try sut.store(sample, serial: serial)
        try sut.clear(type: Set<Sample>.self)
        let result = sut.serial(for: Set<Sample>.self)
        
        // then
        XCTAssertNil(result)
    }
    
    func test_serial_afterLoadDeletedCacheData_resultNil() throws {
        
        let (sut, _) = makeSUT()
        let sample = Sample(value: "sample")
        let fileName = "sample.json"
        let serial = UUID().uuidString

        // given
        try sut.store(sample, serial: serial)
        try expectFile(named: fileName, exists: true)
        try deleteFile(named: fileName)
        try expectFile(named: fileName, exists: false)
        
        // when
        let _ = sut.load(type: Sample.self)
        let result = sut.serial(for: Sample.self)
        
        // then
        XCTAssertNil(result)
    }
    
    func test_serialArray_afterLoadDeletedCacheData_resultNil() throws {
        
        let (sut, _) = makeSUT()
        let sample = [Sample(value: "sample")]
        let fileName = "array_sample.json"
        let serial = UUID().uuidString

        // given
        try sut.store(sample, serial: serial)
        try expectFile(named: fileName, exists: true)
        try deleteFile(named: fileName)
        try expectFile(named: fileName, exists: false)
        
        // when
        let _ = sut.load(type: [Sample].self)
        let result = sut.serial(for: [Sample].self)
        
        // then
        XCTAssertNil(result)
    }
    
    func test_serialDictionary_afterLoadDeletedCacheData_resultNil() throws {
        
        let (sut, _) = makeSUT()
        let sample = ["sample" : Sample(value: "sample")]
        let fileName = "dictionary_string_sample.json"
        let serial = UUID().uuidString

        // given
        try sut.store(sample, serial: serial)
        try expectFile(named: fileName, exists: true)
        try deleteFile(named: fileName)
        try expectFile(named: fileName, exists: false)
        
        // when
        let _ = sut.load(type: Dictionary<String, Sample>.self)
        let result = sut.serial(for: Dictionary<String, Sample>.self)
        
        // then
        XCTAssertNil(result)
    }
    
    func test_serialSet_afterLoadDeletedCacheData_resultNil() throws {
        
        let (sut, _) = makeSUT()
        let sample = Set([Sample(value: "sample")])
        let fileName = "set_sample.json"
        let serial = UUID().uuidString

        // given
        try sut.store(sample, serial: serial)
        try expectFile(named: fileName, exists: true)
        try deleteFile(named: fileName)
        try expectFile(named: fileName, exists: false)
        
        // when
        let _ = sut.load(type: Set<Sample>.self)
        let result = sut.serial(for: Set<Sample>.self)
        
        // then
        XCTAssertNil(result)
    }
    
    //MARK: - Helpers
    
    func makeSUT() -> (EncryptionLocalAgent<EncryptionAgentSpy>, EncryptionAgentSpy) {
        
        let encryptionAgentSpy = EncryptionAgentSpy()
        let sut = EncryptionLocalAgent(context: Self.context, encryptionAgent: encryptionAgentSpy)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(encryptionAgentSpy)
        
        return (sut, encryptionAgentSpy)
    }
    
    func dataFromFile(named: String) throws -> Data {
        
        let rootFolderURL = try Self.context.fileManager.rootFolderURL(with: Self.context.cacheFolderName)
        let fileUrl = rootFolderURL.appendingPathComponent(named)
        
        return try Data(contentsOf: fileUrl)
    }
    
    func deleteFile(named: String) throws {
        
        let rootFolderURL = try Self.context.fileManager.rootFolderURL(with: Self.context.cacheFolderName)
        let fileUrl = rootFolderURL.appendingPathComponent(named)
        try Self.context.fileManager.removeItem(at: fileUrl)
    }
    
    func expectFile(named: String,
                    exists: Bool,
                    file: StaticString = #filePath,
                    line: UInt = #line) throws {
        
        let rootFolderURL = try Self.context.fileManager.rootFolderURL(with: Self.context.cacheFolderName)
        let fileUrl = rootFolderURL.appendingPathComponent(named)
        
        XCTAssertEqual(Self.context.fileManager.fileExists(atPath: fileUrl.path), exists, file: file, line: line)
    }
    
    struct Sample: Codable, Hashable {
        
        let value: String
    }
    
    final class EncryptionAgentSpy: EncryptionAgent {
        
        private(set) var requests: [RequestType] = []
        private(set) var encryptedResults: [Data] = []
        static let encryptionSecret = 8
        private let _encrypt: (Data) -> Data = { data in
            var encryptedData = data
            encryptedData.append(Data(count: EncryptionAgentSpy.encryptionSecret))
            
            return encryptedData
        }
        private let _decrypt: (Data) -> Data = { data in
            
            var decryptedData = data
            decryptedData.removeLast(EncryptionAgentSpy.encryptionSecret)
            
            return decryptedData
        }
        
        init(with keyData: Data = .init()) {}
        
        func encrypt(_ data: Data) throws -> Data {
            
            requests.append(.encrypt)
            let encrypted = _encrypt(data)
            encryptedResults.append(encrypted)
            
            return encrypted
        }
        
        func decrypt(_ data: Data) throws -> Data {
            
            requests.append(.decrypt)
            let decrypted = _decrypt(data)
            
            return decrypted
        }
        
        enum RequestType {
            case encrypt, decrypt
        }
    }
    
    func removeCachedFiles() throws {
        
        let rootFolderURL = try Self.context.fileManager.rootFolderURL(with: Self.context.cacheFolderName)
        let urls = try Self.context.fileManager.contentsOfDirectory(at: rootFolderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        for url in urls {
            
            try Self.context.fileManager.removeItem(at: url)
        }
    }
}
