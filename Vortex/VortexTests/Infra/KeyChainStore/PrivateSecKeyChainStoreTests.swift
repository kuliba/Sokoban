//
//  PrivateSecKeyChainStoreTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 14.10.2023.
//

import KeyChainStore
import XCTest
import VortexCrypto

final class PrivateSecKeyChainStoreTests: XCTestCase {
    
    override func setUp() {
        
        clear()
    }
    
    func test_load_shouldDeliverErrorOnEmptyStore() {
        
        XCTAssertThrowsError(try load())
    }
    
    func test_save_shouldDeliverLastSavedKey() throws {
        
        let firstKey = try anySecKey(.privateKey)
        let firstExpiration = Date()
        try save((firstKey, firstExpiration))
        let firstCachedKey = try load()
        
        XCTAssertEqual(firstCachedKey.0, firstKey)
        XCTAssertEqual(firstCachedKey.validUntil, firstExpiration)

        let lastKey = try anySecKey(.privateKey)
        let lastExpiration = Date()
        try save((lastKey, lastExpiration))
        let lastCachedKey = try load()
        
        XCTAssertEqual(lastCachedKey.0, lastKey)
        XCTAssertEqual(lastCachedKey.validUntil, lastExpiration)
    }
    
    func test_clear_shouldRemoveSavedKey() throws {
        
        let key = try anySecKey(.privateKey)
        let expiration = Date()
        try save((key, expiration))
        let cachedKey = try load()
        
        XCTAssertEqual(cachedKey.0, key)
        XCTAssertEqual(cachedKey.validUntil, expiration)
        
        clear()
        
        XCTAssertThrowsError(try load())
    }

    // MARK: Helpers
    
    private typealias SUT = KeyChainStore<KeyTag, SecKey>
    
    private func makeSUT(
        keyTag: KeyTag = anyKeyTag("test key tag"),
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            keyTag: keyTag,
            data: { try $0.rawRepresentation() },
            key: Crypto.createPrivateSecKey
        )
        
        trackForMemoryLeaks(sut, file: file, line:  line)
        
        return sut
    }
    
    private func load(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Cached<SecKey> {
        
        try makeSUT(file: file, line: line).load()
    }
    
    private func save(
        _ cachedKey: Cached<SecKey>,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        try makeSUT(file: file, line: line).save(cachedKey)
    }

    private func clear(
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        makeSUT(file: file, line: line).clear()
    }
}

private extension Crypto {
    
    static func createPrivateSecKey(
        from data: Data
    ) throws -> SecKey {
        
        try createSecKey(
            from: data,
            keyType: .rsa,
            keyClass: .privateKey,
            keySize: .bits4096
        )
    }
}
