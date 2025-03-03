//
//  ProviderTests.swift
//
//
//  Created by Igor Malyarov on 03.03.2025.
//

import Combine

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

protocol Loader<Resource> {
    
    associatedtype Resource
    
    func requestDownload(for key: String)
    
    var publisher: AnyPublisher<(key: String, resource: Resource), Never> { get }
}

final class WIPProvider<Resource>: Provider {
    
    let cache: any Cache<Resource>
    let fallback: any Fallback<Resource>
    let loader: any Loader<Resource>
    
    private var requested = Set<String>()
    
    init(
        cache: any Cache<Resource>,
        fallback: any Fallback<Resource>,
        loader: any Loader<Resource>
    ) {
        self.cache = cache
        self.fallback = fallback
        self.loader = loader
    }
}

extension WIPProvider {
    
    func value(forKey key: String) -> Resource {
        
        if let resource = cache.value(forKey: key) {
            return resource
        } else {
            if !requested.contains(key) {
                requested.insert(key)
                loader.requestDownload(for: key)
            }
            return fallback.value(forKey: key)
        }
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
    
    func test_shouldCallLoader_onCacheMiss() {
        
        let key = anyMessage()
        let (sut, _,_, loader) = makeSUT(cacheStubs: nil)
        
        _ = sut.value(forKey: key)
        
        XCTAssertNoDiff(loader.requested, [key])
    }
    
    func test_shouldNotCallLoaderAgain_onCacheMiss() {
        
        let key = anyMessage()
        let (sut, _,_, loader) = makeSUT(
            cacheStubs: nil, nil,
            fallbackStubs: makeResource(), makeResource()
        )
        
        _ = sut.value(forKey: key)
        _ = sut.value(forKey: key)
        
        XCTAssertNoDiff(loader.requested, [key])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = WIPProvider<Resource>
    private typealias Cache = CallSpy<String, Resource?>
    private typealias Fallback = CallSpy<String, Resource>
    
    private func makeSUT(
        cacheStubs: Resource?...,
        fallbackStubs: Resource...,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        cache: Cache,
        fallback: Fallback,
        loader: LoaderSpy
    ) {
        let cache = Cache(stubs: cacheStubs.isEmpty ? [nil] : cacheStubs)
        let fallback = Fallback(stubs: fallbackStubs.isEmpty ? [makeResource()] : fallbackStubs)
        let loader = LoaderSpy()
        let sut = SUT(cache: cache, fallback: fallback, loader: loader)
        
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
    
    private final class LoaderSpy: Loader {
        
        typealias Value = (key: String, resource: Resource)
        
        private let subject = PassthroughSubject<Value, Never>()
        private(set) var requested = [String]()
        
        var callCount: Int { requested.count }
        
        var publisher: AnyPublisher<Value, Never> {
            
            subject.eraseToAnyPublisher()
        }
        
        func emit(_ value: Value) {
            
            subject.send(value)
        }
        
        func requestDownload(for key: String) {
            
            requested.append(key)
        }
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
