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
/// - Warning: `KeyChainStore` cannot be tested on iOS Simulator without app target with entitlements.
final class KeyChainStoreTests: XCTestCase {
    
    override func setUp() {
        
        clear()
    }
    
    func test_load_shouldDeliverErrorOnEmptyStore() {
        
        XCTAssertThrowsError(try load())
    }
    
#if os(macOS)
    func test_save_shouldDeliverLastSavedKey() throws {
        
        let firstKey = anyKey("first key")
        let firstExpiration = Date()
        try save((firstKey, firstExpiration))
        let firstCachedKey = try start()
        
        XCTAssertEqual(firstCachedKey.0, firstKey)
        XCTAssertEqual(firstCachedKey.validUntil, firstExpiration)
        
        let lastKey = anyKey("last key")
        let lastExpiration = Date()
        try save((lastKey, lastExpiration))
        let lastCachedKey = try start()
        
        XCTAssertEqual(lastCachedKey.0, lastKey)
        XCTAssertEqual(lastCachedKey.validUntil, lastExpiration)
    }
    
    func test_clear_shouldRemoveSavedKey() throws {
        
        let key = anyKey("first key")
        let expiration = Date()
        try save((key, expiration))
        let cachedKey = try start()
        
        XCTAssertEqual(cachedKey.0, key)
        XCTAssertEqual(cachedKey.validUntil, expiration)
        
        clear()
        
        XCTAssertThrowsError(try start())
    }
#endif
    
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
