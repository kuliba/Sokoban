//
//  LoggingRemoteNanoServiceComposer+composeSerial.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 18.10.2024.
//

import SerialComponents

extension LoggingRemoteNanoServiceComposer {
    
    typealias SerialLoadCompletion<T> = (String?, @escaping (SerialStamped<String, T>) -> Void) -> Void
    typealias SerialLoad<T> = (String?, @escaping SerialLoadCompletion<T>) -> Void
    
    func composeSerial<T>(
        createRequest: @escaping (String?) throws -> URLRequest
    ) -> SerialLoad<T> {
        
        return { serial, completion in
            
            _ = try? createRequest(serial)
        }
    }
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
    
    func test_composeSerial_shouldCallCreateRequestWithNilOnNilSerial() {
        
        let serial: String? = nil
        let createRequestSpy = CreateRequestSpy(stubs: [anyURLRequest()])
        let composed: SerialLoad = makeSUT().sut.composeSerial(
            createRequest: createRequestSpy.call(payload:)
        )
        
        composed(serial) { _,_ in }
        
        XCTAssertNoDiff(createRequestSpy.payloads, [serial])
    }
    
    func test_composeSerial_shouldCallCreateRequestWithSerial() {
        
        let serial = anyMessage()
        let createRequestSpy = CreateRequestSpy(stubs: [anyURLRequest()])
        let composed: SerialLoad = makeSUT().sut.composeSerial(
            createRequest: createRequestSpy.call(payload:)
        )
        
        composed(serial) { _,_ in }
        
        XCTAssertNoDiff(createRequestSpy.payloads, [serial])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = LoggingRemoteNanoServiceComposer
    private typealias SerialLoad = SUT.SerialLoad<Value>
    private typealias CreateRequestSpy = CallSpy<String?, URLRequest>
    
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
    
    private struct Value: Equatable {
        
        let value: String
    }
    
    private func makeValue(
        _ value: String = anyMessage()
    ) -> Value {
        
        return .init(value: value)
    }
}
