//
//  ImageProviderTests.swift
//
//
//  Created by Igor Malyarov on 03.03.2025.
//

protocol ImageProvider {
    
}

final class WIPImageProvider: ImageProvider {
    
}

import XCTest

final class ImageProviderTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = WIPImageProvider
    private typealias Loader = CallSpy<String, Void>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loader: Loader
    ) {
        let loader = Loader(stubs: .init(repeating: (), count: 10))
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        return (sut, loader)
    }
}
