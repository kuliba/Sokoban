//
//  RootViewFactoryComposerTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 25.05.2024.
//

@testable import Vortex
import XCTest

final class RootViewFactoryComposerTests: XCTestCase {
    
    func test_compose_shouldNotFail() {
        
        _ = makeSUT().compose { _ in }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RootViewFactoryComposer
    
    private func makeSUT(
        model: Model? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            model: model ?? .mockWithEmptyExcept(),
            httpClient: HTTPClientSpy(),
            schedulers: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
