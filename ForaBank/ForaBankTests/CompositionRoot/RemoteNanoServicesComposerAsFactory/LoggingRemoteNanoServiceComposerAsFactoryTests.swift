//
//  LoggingRemoteNanoServiceComposerAsFactoryTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 08.09.2024.
//

@testable import ForaBank
import XCTest

class LoggingRemoteNanoServiceComposerAsFactoryTests: XCTestCase {
    
    typealias SUT = RemoteNanoServiceFactory
    typealias Composer = LoggingRemoteNanoServiceComposer
    
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClient: HTTPClientSpy,
        logger: LoggerSpy
    ) {
        let httpClient = HTTPClientSpy()
        let logger = LoggerSpy()
        let sut = Composer(httpClient: httpClient, logger: logger)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(httpClient, file: file, line: line)
        trackForMemoryLeaks(logger, file: file, line: line)
        
        return (sut, httpClient, logger)
    }
    
    struct Payload: Equatable {
        
        let value: String
    }
    
    func makePayload(
        _ value: String = anyMessage()
    ) -> Payload {
        
        return .init(value: value)
    }
    
    struct Response: Equatable {
        
        let value: String
    }
    
    func makeResponse(
        _ value: String = anyMessage()
    ) -> Response {
        
        return .init(value: value)
    }
}
