//
//  GeneralImageCacheImagePublisherTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 20.09.2024.
//

@testable import ForaBank
import SwiftUI
import XCTest

final class GeneralImageCacheImagePublisherTests: XCTestCase {

    func test_local_shouldDeliverImage() {
        
        let key = "1"
        let (_, imageCache) = makeSUT()
        let spy = ValueSpy(imageCache.image(forKey: .init(key)))

        XCTAssertFalse(spy.values.isEmpty)
    }
    
    func test_remote_shouldDeliverImageOnEmptyImages() {
        
        let key = "dict/getBannerCatalogImage?image=banner_1"
        let (model, imageCache) = makeSUT()
        let spy = ValueSpy(imageCache.image(forKey: .init(key)))
        
        XCTAssertFalse(spy.values.isEmpty)
        XCTAssertNil(model.images.value[key])
    }
    
    func test_remote_shouldDeliverImageOnUpdatedImages() {
        
        let key = "dict/getBannerCatalogImage?image=banner_1"
        let (model, imageCache) = makeSUT()
        let spy = ValueSpy(imageCache.image(forKey: .init(key)))

        model.updateImage(for: key, with: .init(named: "ic24IconMessage"))
        
        XCTAssertFalse(spy.values.isEmpty)
        XCTAssertNotNil(model.images.value[key])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        model: Model,
        imageCache: ImageCache
    ) {
        let model: Model = .mockWithEmptyExcept()
        let imageCache = model.generalImageCache()
        
        trackForMemoryLeaks(model, file: file, line: line)
        trackForMemoryLeaks(imageCache, file: file, line: line)
        
        return (model, imageCache)
    }
}

private extension Model {
    
    func updateImage(
        for key: String,
        with imageData: ImageData?
    ) {
        
        images.value[key] = imageData
    }
}
