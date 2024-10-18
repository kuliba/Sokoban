//
//  LoggingRemoteNanoServiceComposer+composeSerialTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 18.10.2024.
//

import SerialComponents

extension LoggingRemoteNanoServiceComposer {
    
    typealias SerialLoadCompletion<T> = (SerialStamped<String, T>?) -> Void
    typealias SerialLoad<T> = (String?, @escaping SerialLoadCompletion<T>) -> Void
    
    func composeSerial<T, MapResponseError: Error>(
        createRequest: @escaping (String?) throws -> URLRequest,
        mapResponse: @escaping (Data, HTTPURLResponse) -> Result<T, MapResponseError>
    ) -> SerialLoad<T> {
        
        return { [weak self] serial, completion in
            
            do {
                let request = try createRequest(serial)
                self?.httpClient.performRequest(request) {
                    
                    switch $0 {
                    case let .failure(failure):
                        completion(.none)
                        
                    case let .success((data, response)):
                        mapResponse(data, response)
                        completion(.none)
                    }
                }
            } catch {
                
            }
        }
    }
}

@testable import ForaBank
import XCTest

final class LoggingRemoteNanoServiceComposer_composeSerialTests: XCTestCase {
    
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
            createRequest: createRequestSpy.call(payload:),
            mapResponse: { _,_ in .failure(anyError()) }
        )
        
        composed(serial) { _ in }
        
        XCTAssertNoDiff(createRequestSpy.payloads, [serial])
    }
    
    func test_composeSerial_shouldCallCreateRequestWithSerial() {
        
        let serial = anyMessage()
        let createRequestSpy = CreateRequestSpy(stubs: [anyURLRequest()])
        let composed: SerialLoad = makeSUT().sut.composeSerial(
            createRequest: createRequestSpy.call(payload:),
            mapResponse: { _,_ in .failure(anyError()) }
        )
        
        composed(serial) { _ in }
        
        XCTAssertNoDiff(createRequestSpy.payloads, [serial])
    }
    
    func test_composeSerial_shouldCallHTTPClientWithRequest() {
        
        let request = anyURLRequest()
        let (sut, httpClientSpy, _) = makeSUT()
        let composed: SerialLoad = sut.composeSerial(
            createRequest: { _ in request },
            mapResponse: { _,_ in .failure(anyError()) }
        )
        
        composed(anyMessage()) { _ in }
        
        XCTAssertNoDiff(httpClientSpy.requests, [request])
    }
    
    func test_composeSerial_shouldNotCallMapResponseOnHTTPClientFailure() {
        
        let (sut, httpClientSpy, _) = makeSUT()
        let mapResponseSpy = MapResponseSpy(stubs: [.success(makeValue())])
        let composed: SerialLoad = sut.composeSerial(
            createRequest: { _ in anyURLRequest() },
            mapResponse: mapResponseSpy.call(_:_:)
        )
        let exp = expectation(description: "wait for completion")
        
        composed(anyMessage()) { _ in exp.fulfill() }
        
        httpClientSpy.complete(with: anyError())
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(mapResponseSpy.callCount, 0)
    }
    
    func test_composeSerial_shouldCallMapResponseWithDataAndResponseOnHTTPClientSuccess() {
        
        let (data, response) = (anyData(), anyHTTPURLResponse())
        let (sut, httpClientSpy, _) = makeSUT()
        let mapResponseSpy = MapResponseSpy(stubs: [.success(makeValue())])
        let composed: SerialLoad = sut.composeSerial(
            createRequest: { _ in anyURLRequest() },
            mapResponse: mapResponseSpy.call(_:_:)
        )
        let exp = expectation(description: "wait for completion")
        
        composed(anyMessage()) { _ in exp.fulfill() }
        
        httpClientSpy.complete(with: (data, response))
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertNoDiff(mapResponseSpy.payloads.map(\.0), [data])
        XCTAssertNoDiff(mapResponseSpy.payloads.map(\.1), [response])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = LoggingRemoteNanoServiceComposer
    private typealias SerialLoad = SUT.SerialLoad<Value>
    private typealias CreateRequestSpy = CallSpy<String?, URLRequest>
    private typealias MapResponseSpy = CallSpy<(Data, HTTPURLResponse), Result<Value, Failure>>
    
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
    
    private struct Failure: Error, Equatable {
        
        let value: String
    }
    
    private func makeFailure(
        _ value: String = anyMessage()
    ) -> Failure {
        
        return .init(value: value)
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
