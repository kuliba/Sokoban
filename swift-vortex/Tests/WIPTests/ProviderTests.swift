//
//  ProviderTests.swift
//
//
//  Created by Igor Malyarov on 03.03.2025.
//

import Combine

protocol Provider<Resource> {
    
    associatedtype Resource
    
    func value(forKey key: String) -> CurrentValueSubject<Resource, Never>
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
    
    // TODO: protect shared mutable state
    private var subjects = [String: Subject]()
    private var requested = Set<String>()
    // TODO: manage subscriptions lifetime
    private var cancellables = Set<AnyCancellable>()
    
    init(
        cache: any Cache<Resource>,
        fallback: any Fallback<Resource>,
        loader: any Loader<Resource>
    ) {
        self.cache = cache
        self.fallback = fallback
        self.loader = loader
    }
    
    typealias Subject = CurrentValueSubject<Resource, Never>
}

extension WIPProvider {
    
    func value(forKey key: String) -> Subject {
        
        if let subject = subjects[key] {
            return subject
        }
        
        let subject = Subject(fallback.value(forKey: key))
        subjects[key] = subject
        
        if let resource = cache.value(forKey: key) {
            subject.send(resource)
            return subject
        } else {
            if !requested.contains(key) {
                requested.insert(key)
                loader.requestDownload(for: key)
                loader.publisher
                    .compactMap { $0.key == key ? $0.resource : nil }
                    .sink { [weak subject] in subject?.send($0) }
                    .store(in: &cancellables)
            }
            
            return subject
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
        let spy = ValueSpy(sut.value(forKey: key))
        
        XCTAssertNoDiff(spy.values, [cached])
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
        let spy = ValueSpy(sut.value(forKey: key))
        
        XCTAssertNoDiff(spy.values, [backed])
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
    
    func test_shouldNotUpdateSubject_onLoaderDownloadForDifferentKey() {
        
        let (key, foreign, backed) = (anyMessage(), anyMessage(), makeResource())
        let (sut, _,_, loader) = makeSUT(fallbackStubs: backed)
        let spy = ValueSpy(sut.value(forKey: key))
        
        loader.emit((foreign, makeResource()))
        
        XCTAssertNoDiff(spy.values, [backed])
    }
    
    func test_shouldUpdateSubject_onLoaderDownloadForKey() {
        
        let (key, backed, new) = (anyMessage(), makeResource(), makeResource())
        let (sut, _,_, loader) = makeSUT(fallbackStubs: backed)
        let spy = ValueSpy(sut.value(forKey: key))
        
        loader.emit((key, new))
        
        XCTAssertNoDiff(spy.values, [backed, new])
    }
    
    func test_shouldUpdateSubjectTwice_onLoaderSecondDownloadForKey() {
        
        let (key, backed) = (anyMessage(), makeResource())
        let (first, second) = (makeResource(), makeResource())
        let (sut, _,_, loader) = makeSUT(fallbackStubs: backed)
        let spy = ValueSpy(sut.value(forKey: key))
        
        loader.emit((key, first))
        loader.emit((key, second))
        
        XCTAssertNoDiff(spy.values, [backed, first, second])
    }
    
    func test_shouldReturnSameSubject_onRepeatedImageRequestsWithEmptyCache() {
        
        let key = anyMessage()
        let (sut, _,_,_) = makeSUT(
            cacheStubs: nil, nil,
            fallbackStubs: makeResource(), makeResource()
        )
        
        let first = sut.value(forKey: key)
        let second = sut.value(forKey: key)
        
        XCTAssertNoDiff(ObjectIdentifier(first), .init(second))
    }
    
    func test_shouldReturnSameSubject_onRepeatedImageRequests() {
        
        let key = anyMessage()
        let (sut, _,_,_) = makeSUT(
            cacheStubs: makeResource(), nil,
            fallbackStubs: makeResource(), makeResource()
        )
        
        let first = sut.value(forKey: key)
        let second = sut.value(forKey: key)
        
        XCTAssertNoDiff(ObjectIdentifier(first), .init(second))
    }
    
    func test_shouldReturnSameSubject_onRepeatedImageRequests2() {
        
        let key = anyMessage()
        let (sut, _,_,_) = makeSUT(
            cacheStubs: makeResource(), makeResource(),
            fallbackStubs: makeResource(), makeResource()
        )
        
        let first = sut.value(forKey: key)
        let second = sut.value(forKey: key)
        
        XCTAssertNoDiff(ObjectIdentifier(first), .init(second))
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
