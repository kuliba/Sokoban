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

final class WIPImageProvider<Resource>: Provider {
    
    let cache: any Cache<Resource>
    
    init(
        cache: any Cache<Resource>
    ) {
        self.cache = cache
    }
}

extension WIPImageProvider {
    
    func value(forKey key: String) -> Resource {
        
        cache.value(forKey: key) ?? { fatalError() }()
    }
}

import SwiftUI
import XCTest

final class ProviderTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, cache, loader) = makeSUT()
        
        XCTAssertEqual(cache.callCount, 0)
        XCTAssertEqual(loader.callCount, 0)
        // TODO: add other collaborators
        XCTAssertNotNil(sut)
    }
    
    // MARK: - value
    
    func test_shouldCallCacheWithKey() {
        
        let key = anyMessage()
        let (sut, cache, _) = makeSUT()
        
        _ = sut.value(forKey: key)
        
        XCTAssertNoDiff(cache.payloads, [key])
    }
    
    func test_shouldDeliverCached_onCacheHit() {
        
        let (key, cached) = (anyMessage(), makeResource())
        let (sut, _,_) = makeSUT(cacheStubs: cached)
        
        XCTAssertNoDiff(sut.value(forKey: key), cached)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = WIPImageProvider<Resource>
    private typealias Cache = CallSpy<String, Resource?>
    private typealias Loader = CallSpy<String, Void>
    
    private func makeSUT(
        cacheStubs: Resource?...,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        cache: Cache,
        loader: Loader
    ) {
        let cache = Cache(stubs: cacheStubs.isEmpty ? [makeResource()] : cacheStubs)
        let loader = Loader(stubs: .init(repeating: (), count: 10))
        let sut = SUT(cache: cache)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        return (sut, cache, loader)
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
