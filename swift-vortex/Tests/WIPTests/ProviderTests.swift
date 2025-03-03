//
//  ProviderTests.swift
//
//
//  Created by Igor Malyarov on 03.03.2025.
//

protocol Provider<Resource> {
    
    associatedtype Resource
    
    func value(forKey key: String) -> Resource
}

protocol Cache<Resource> {
    
    associatedtype Resource
    
    func value(forKey key: String) -> Resource?
}

protocol Fallback<Resource> {
    
    associatedtype Resource
    
    func value(forKey key: String) -> Resource
}

final class WIPImageProvider<Resource>: Provider {
    
    let cache: any Cache<Resource>
    let fallback: any Fallback<Resource>
    
    init(
        cache: any Cache<Resource>,
        fallback: any Fallback<Resource>
    ) {
        self.cache = cache
        self.fallback = fallback
    }
}

extension WIPImageProvider {
    
    func value(forKey key: String) -> Resource {
        
        cache.value(forKey: key) ?? fallback.value(forKey: key)
    }
}

import SwiftUI
import XCTest

final class ProviderTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, cache, fallback, loader) = makeSUT()
        
        XCTAssertEqual(cache.callCount, 0)
        XCTAssertEqual(fallback.callCount, 0)
        XCTAssertEqual(loader.callCount, 0)
        // TODO: add other collaborators
        XCTAssertNotNil(sut)
    }
    
    // MARK: - value
    
    func test_shouldCallCacheWithKey() {
        
        let key = anyMessage()
        let (sut, cache, _,_) = makeSUT()
        
        _ = sut.value(forKey: key)
        
        XCTAssertNoDiff(cache.payloads, [key])
    }
    
    func test_shouldDeliverCached_onCacheHit() {
        
        let (key, cached) = (anyMessage(), makeResource())
        let (sut, _,_,_) = makeSUT(cacheStubs: cached)
        
        XCTAssertNoDiff(sut.value(forKey: key), cached)
    }
    
    func test_shouldCallFallback_onCacheMiss() {
        
        let key = anyMessage()
        let (sut, _, fallback, _) = makeSUT(cacheStubs: nil)
        
        _ = sut.value(forKey: key)
        
        XCTAssertNoDiff(fallback.payloads, [key])
    }
    
    func test_shouldDeliverFallback_onCacheMiss() {
        
        let (key, backed) = (anyMessage(), makeResource())
        let (sut, _,_,_) = makeSUT(fallbackStubs: backed)
        
        XCTAssertNoDiff(sut.value(forKey: key), backed)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = WIPImageProvider<Resource>
    private typealias Cache = CallSpy<String, Resource?>
    private typealias Fallback = CallSpy<String, Resource>
    private typealias Loader = CallSpy<String, Void>
    
    private func makeSUT(
        cacheStubs: Resource?...,
        fallbackStubs: Resource...,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        cache: Cache,
        fallback: Fallback,
        loader: Loader
    ) {
        let cache = Cache(stubs: cacheStubs.isEmpty ? [nil] : cacheStubs)
        let fallback = Fallback(stubs: fallbackStubs.isEmpty ? [makeResource()] : fallbackStubs)
        let loader = Loader(stubs: .init(repeating: (), count: 10))
        let sut = SUT(cache: cache, fallback: fallback)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        return (sut, cache, fallback, loader)
    }
    
    struct Resource: Equatable {
        
        let value: String
    }
    
    private func makeResource(
        _ value: String = anyMessage()
    ) -> Resource {
        
        return .init(value: value)
    }
}

extension CallSpy: Cache
where Payload == String,
      Response == ProviderTests.Resource? {
    
    func value(forKey key: String) -> Response {
        
        call(payload: key)
    }
}

extension CallSpy: Fallback
where Payload == String,
      Response == ProviderTests.Resource {
    
    func value(forKey key: String) -> Response {
        
        call(payload: key)
    }
}
