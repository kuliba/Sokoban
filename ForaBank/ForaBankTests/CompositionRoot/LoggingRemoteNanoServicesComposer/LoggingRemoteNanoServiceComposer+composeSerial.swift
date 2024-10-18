//
//  LoggingRemoteNanoServiceComposer+composeSerial.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 18.10.2024.
//

extension LoggingRemoteNanoServiceComposer {
    
    func composeSerial() {}
}

@testable import ForaBank
import XCTest

final class LoggingRemoteNanoServiceComposer_composeSerial: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, httpClientSpy, loggerSpy) = makeSUT()
        
        XCTAssertEqual(httpClientSpy.callCount, 0)
        XCTAssertEqual(loggerSpy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = LoggingRemoteNanoServiceComposer
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClientSpy: HTTPClientSpy,
        loggerSpy: LoggerSpy
    ) {
        let httpClientSpy = HTTPClientSpy()
        let loggerSpy = LoggerSpy() // TODO: add tests for logging
        let sut = SUT(
            httpClient: httpClientSpy,
            logger: loggerSpy
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(httpClientSpy, file: file, line: line)
        trackForMemoryLeaks(loggerSpy, file: file, line: line)
        
        return (sut, httpClientSpy, loggerSpy)
    }
}
