//
//  AsyncImageViewFactoryTests.swift
//
//
//  Created by Igor Malyarov on 30.06.2024.
//

import SwiftUI
import UIPrimitives
import XCTest

final class AsyncImageViewFactoryTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldShouldNotCallCollaborator() {
        
        let (_, fetcher) = makeSUT()
        
        XCTAssertEqual(fetcher.callCount, 0)
    }
    
    // MARK: - image
    
    func test_image_shouldRenderImage() {
        
        let (sut, _) = makeSUT()
        var renderedImages = [Image]()
        
        let view = sut.makeAsyncImageView(.image(.eraser)) {
            
            renderedImages.append($0)
            return .init(image: $0)
        }
        view.simulateOnAppear()
        
        XCTAssertEqual(renderedImages, [.eraser])
    }
    
    // MARK: - md5Hash
    
    func test_md5Hash_shouldRenderPlaceholder() {
        
        let md5Hash = UUID().uuidString
        let (sut, _) = makeSUT()
        var renderedImages = [Image]()
        let view = sut.makeAsyncImageView(.md5Hash(md5Hash)) {
            
            renderedImages.append($0)
            return .init(image: $0)
        }
        
        view.simulateOnAppear()
        XCTAssertEqual(renderedImages, [.placeholder])
    }
    
    func test_md5Hash_shouldCallFetcherWithMD5Hash() {
        
        let md5Hash = UUID().uuidString
        let (sut, fetcher) = makeSUT()
        let view = sut.makeAsyncImageView(.md5Hash(md5Hash))
        
        view.simulateOnAppear()
        
        XCTAssertEqual(fetcher.payloads, [md5Hash])
    }
    
    func test_md5Hash_shouldRenderFetchedImages() {
        
        let md5Hash = UUID().uuidString
        let (sut, fetcher) = makeSUT()
        var renderedImages = [Image]()
        let view = sut.makeAsyncImageView(.md5Hash(md5Hash)) {
            
            renderedImages.append($0)
            return .init(image: $0)
        }
        
        let controller = view.simulateOnAppear()
        XCTAssertEqual(fetcher.payloads, [md5Hash])
        
        fetcher.complete(with: .star)
        
        controller.loadViewIfNeeded()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(renderedImages, [.placeholder, .star])
        
        fetcher.complete(with: .pencil)
        
        controller.loadViewIfNeeded()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(renderedImages, [.placeholder, .star, .pencil])
    }
    
    // MARK: - named
    
    func test_named_shouldRenderImage() {
        
        let name = UUID().uuidString
        let (sut, _) = makeSUT()
        var renderedImages = [Image]()
        let view = sut.makeAsyncImageView(.named(name)) {
            
            renderedImages.append($0)
            return .init(image: $0)
        }
        
        _ = view.body
        
        XCTAssertEqual(renderedImages, [.init(name)])
    }
    
    // MARK: - svg
    
    func test_svg_shouldRenderPlaceholderOnInvalidSVG() throws {
        
        let (sut, _) = makeSUT()
        var renderedImages = [Image]()
        let view = sut.makeAsyncImageView(.svg(.invalidSVG)) {
            
            renderedImages.append($0)
            return .init(image: $0)
        }
        
        _ = view.body
        
        XCTAssertEqual(renderedImages, [.placeholder])
    }
    
    func test_svg_shouldRenderImage() {
        
        let (sut, _) = makeSUT()
        var renderedImages = [Image]()
#warning("add render spy")
        let view = sut.makeAsyncImageView(.svg(.smallSVG)) {
            
            renderedImages.append($0)
            return .init(image: $0)
        }
        
        _ = view.body
        
        XCTAssertEqual(renderedImages.count, 1, "The image should be rendered, but more precise assertion is too complex and involves diving into SVGKit implementations.")
        XCTAssertNotEqual(renderedImages, [.placeholder])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = AsyncImageViewFactory<ResizableFit>
    private typealias Fetcher = Spy<String, Image>
    
    private func makeSUT(
        placeholder: Image = .placeholder,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        fetcher: Fetcher
    ) {
        let fetcher = Fetcher()
        let sut = SUT(
            placeholder: placeholder,
            md5HashFetch: fetcher.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, fetcher)
    }
}
