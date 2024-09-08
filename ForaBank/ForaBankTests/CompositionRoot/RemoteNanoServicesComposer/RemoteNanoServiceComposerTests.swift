//
//  RemoteNanoServiceComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 08.09.2024.
//

@testable import ForaBank
import XCTest

class RemoteNanoServiceComposerTests: XCTestCase {
    
    typealias SUT = RemoteNanoServiceComposer
    
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
        let sut = SUT(httpClient: httpClient, logger: logger)
        
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
    
    struct Failure: Error, Equatable {
        
        let value: String
    }
    
    func makeFailure(
        _ value: String = anyMessage()
    ) -> Failure {
        
        return .init(value: value)
    }
}
