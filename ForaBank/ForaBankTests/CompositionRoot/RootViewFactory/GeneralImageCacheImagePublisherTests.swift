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
    
    func test_remote_shouldDeliverImageOnEmptyImages() {
        
        let key = anyMessage()
        let (model, imagesSpy) = makeSUT(key: key)
        
        XCTAssertNoDiff(imagesSpy.values.count, 1)
        XCTAssertNil(model.images.value[key])
    }
    
    func test_remote_shouldDeliverImageOnUpdatedImages() {
        
        let key = anyMessage()
        let image = ImageData(named: "ic24IconMessage")
        let (model, imagesSpy) = makeSUT(key: key)

        model.updateImage(for: key, with: image)
        
        XCTAssertNoDiff(imagesSpy.values.count, 1)
        XCTAssertNoDiff(model.images.value[key], image)
    }
    
    func test_remote_1shouldDeliverImageOnUpdatedImages() {
        
        let key = anyMessage()
        let (model, imagesSpy) = makeSUT(defaultImage: .ic16Tv, key: key)

        model.action.send(ModelAction.General.DownloadImage.Response(endpoint: key, result: .failure(anyError())))

        XCTAssertNoDiff(imagesSpy.values.count, 1)
        XCTAssertNoDiff(imagesSpy.values[0], .ic16Tv)
        XCTAssertNil(model.images.value[key])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        defaultImage: Image? = nil,
        key: String,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        model: Model,
        imageSpy: ValueSpy<Image>
    ) {
        let model: Model = .mockWithEmptyExcept()
        let imageCache = model.generalImageCache(defaultImage)
        let spy = ValueSpy(imageCache.image(forKey: .init(key)))

        trackForMemoryLeaks(model, file: file, line: line)
        trackForMemoryLeaks(imageCache, file: file, line: line)
        
        return (model, spy)
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
