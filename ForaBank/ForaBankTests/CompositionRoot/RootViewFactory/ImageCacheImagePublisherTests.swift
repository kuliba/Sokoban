//
//  ImageCacheImagePublisherTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 19.12.2023.
//

@testable import ForaBank
import SberQR
import SwiftUI
import XCTest

final class ImageCacheImagePublisherTests: XCTestCase {
    
    func test_local_shouldDeliverImage() {
        
        let icon = makeLocalIcon()
        let (_, imageCache) = makeSUT()
        let spy = ValueSpy(imageCache.imagePublisher(for: icon))
        
        XCTAssertFalse(spy.values.isEmpty)
    }
    
    func test_remote_shouldDeliverImageOnEmptyImages() {
        
        let key = "c37971b7264d55c3c467d2127ed600aa"
        let icon = makeRemoteIcon(key: key)
        let (model, imageCache) = makeSUT()
        let spy = ValueSpy(imageCache.imagePublisher(for: icon))
        
        XCTAssertFalse(spy.values.isEmpty)
        XCTAssertNil(model.images.value[key])
    }
    
    func test_remote_shouldDeliverImageOnUpdatedImages() {
        
        let key = "c37971b7264d55c3c467d2127ed600aa"
        let icon = makeRemoteIcon(key: key)
        let (model, imageCache) = makeSUT()
        let spy = ValueSpy(imageCache.imagePublisher(for: icon))
        
        model.updateImage(for: key, with: .init(named: "ic24IconMessage"))
        
        XCTAssertFalse(spy.values.isEmpty)
        XCTAssertNotNil(model.images.value[key])
    }
    
    // MARK: - Helpers
    
    private func makeLocalIcon(
        key: String = "ic24IconMessage"
    ) -> GetSberQRDataResponse.Parameter.Info.Icon {
        
        .init(type: .local, value: key)
    }
    
    private func makeRemoteIcon(
        key: String = "c37971b7264d55c3c467d2127ed600aa"
    ) -> GetSberQRDataResponse.Parameter.Info.Icon {
        
        .init(type: .remote, value: key)
    }
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        model: Model,
        imageCache: ImageCache
    ) {
        let model: Model = .mockWithEmptyExcept()
        let imageCache = model.imageCache()
        
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
