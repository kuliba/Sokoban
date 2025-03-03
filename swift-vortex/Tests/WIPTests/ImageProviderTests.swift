//
//  ImageProviderTests.swift
//
//
//  Created by Igor Malyarov on 03.03.2025.
//

// TODO: decouple from Image
protocol ImageProvider {
    
    func image(forKey key: String) -> Image
}

protocol ImageCache {
    
    func image(forKey key: String) -> Image?
}

final class WIPImageProvider: ImageProvider {
    
    let cache: ImageCache
    
    init(
        cache: any ImageCache
    ) {
        self.cache = cache
    }
}

extension WIPImageProvider {
    
    func image(forKey key: String) -> Image {
        
        cache.image(forKey: key) ?? .init(systemName: "plane")
    }
}

import SwiftUI
import XCTest

final class ImageProviderTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, cache, loader) = makeSUT()
        
        XCTAssertEqual(cache.callCount, 0)
        XCTAssertEqual(loader.callCount, 0)
        // TODO: add other collaborators
        XCTAssertNotNil(sut)
    }
    
    // MARK: - image
    
    func test_shouldCallCachedImageWithKey() {
        
        let key = anyMessage()
        let (sut, cache, _) = makeSUT()
        
        _ = sut.image(forKey: key)
        
        XCTAssertNoDiff(cache.payloads, [key])
    }
    
    func test_shouldReturnCachedImage_onCacheHit() {
        
        let key = anyMessage()
        let cachedIImage = Image(systemName: "photo")
        let (sut, _,_) = makeSUT(cacheStubs: cachedIImage)
        
        XCTAssertNoDiff(sut.image(forKey: key), cachedIImage)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = WIPImageProvider
    private typealias Cache = CallSpy<String, Image?>
    private typealias Loader = CallSpy<String, Void>
    
    private func makeSUT(
        cacheStubs: Image?...,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        cache: Cache,
        loader: Loader
    ) {
        let cache = Cache(stubs: cacheStubs.isEmpty ? [nil] : cacheStubs)
        let loader = Loader(stubs: .init(repeating: (), count: 10))
        let sut = SUT(cache: cache)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        return (sut, cache, loader)
    }
}

extension CallSpy: ImageCache
where Payload == String,
      Response == Image? {
    
    func image(forKey key: String) -> Image? {
        
        call(payload: key)
    }
}
