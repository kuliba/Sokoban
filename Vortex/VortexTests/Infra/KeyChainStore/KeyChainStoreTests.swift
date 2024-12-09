//
//  KeyChainStoreTests.swift
//
//
//  Created by Igor Malyarov on 14.10.2023.
//

import KeyChainStore
import XCTest

/// [Troubleshooting -34018 Keychain Er… | Apple Developer Forums](https://developer.apple.com/forums/thread/114456)
/// [Error -34018 errSecMissingEntitlem… | Apple Developer Forums](https://developer.apple.com/forums/thread/64699)
///
/// - Note: This is a copy of `KeyChainStoreTests` from `swift-vortex` package, needed here due to entitlements that cannot be set in Swift Package test targets running on Simulator (no problem on a Mac).
final class KeyChainStoreTests: XCTestCase {
    
    override func setUp() {
        
        clear()
    }
    
    func test_load_shouldDeliverErrorOnEmptyStore() {
        
        XCTAssertThrowsError(try load())
    }
    
    func test_save_shouldDeliverLastSavedKey() throws {
        
        let firstKey = anyKey("first key")
        let firstExpiration = Date()
        try save((firstKey, firstExpiration))
        let firstCachedKey = try load()
        
        XCTAssertEqual(firstCachedKey.0, firstKey)
        XCTAssertEqual(firstCachedKey.validUntil, firstExpiration)
        
        let lastKey = anyKey("last key")
        let lastExpiration = Date()
        try save((lastKey, lastExpiration))
        let lastCachedKey = try load()
        
        XCTAssertEqual(lastCachedKey.0, lastKey)
        XCTAssertEqual(lastCachedKey.validUntil, lastExpiration)
    }
    
    func test_clear_shouldRemoveSavedKey() throws {
        
        let key = anyKey("first key")
        let expiration = Date()
        try save((key, expiration))
        let cachedKey = try load()
        
        XCTAssertEqual(cachedKey.0, key)
        XCTAssertEqual(cachedKey.validUntil, expiration)
        
        clear()
        
        XCTAssertThrowsError(try load())
    }
    
    // MARK: Helpers
    
    private typealias SUT = KeyChainStore<KeyTag, Key>
    
    private func makeSUT(
        keyTag: KeyTag = anyKeyTag("test key tag"),
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(keyTag: keyTag)
        
        trackForMemoryLeaks(sut, file: file, line:  line)
        
        return sut
    }
    
    private func load(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Cached<Key> {
        
        try makeSUT(file: file, line: line).load()
    }
    
    private func save(
        _ cachedKey: Cached<Key>,
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
