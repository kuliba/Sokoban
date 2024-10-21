//
//  RootViewModelFactoryTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 21.10.2024.
//

@testable import ForaBank
import XCTest

class RootViewModelFactoryTests: XCTestCase {
    
    typealias SUT = RootViewModelFactory
    
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClient: HTTPClientSpy,
        logger: LoggerSpy
    ) {
        let model: Model = .mockWithEmptyExcept()
        let httpClient = HTTPClientSpy()
        let logger = LoggerSpy() // TODO: add logging tests
        let sut = SUT(
            model: model,
            httpClient: httpClient,
            logger: logger
        )
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(model, file: file, line: line)
        trackForMemoryLeaks(httpClient, file: file, line: line)
        trackForMemoryLeaks(logger, file: file, line: line)
        
        return (sut, httpClient, logger)
    }
}
