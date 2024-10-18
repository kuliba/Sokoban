//
//  LoggingRemoteNanoServiceComposer+composeSerialTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 18.10.2024.
//

import GenericRemoteService
import SerialComponents

extension LoggingRemoteNanoServiceComposer {
    
    typealias Stamped<T> = SerialStamped<String, T>
    typealias SerialLoadCompletion<T> = (Stamped<T>?) -> Void
    typealias SerialLoad<T> = (String?, @escaping SerialLoadCompletion<T>) -> Void
    
    func composeSerial<T, MapResponseError: Error>(
        createRequest: @escaping (String?) throws -> URLRequest,
        mapResponse: @escaping (Data, HTTPURLResponse) -> Result<Stamped<T>, MapResponseError>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SerialLoad<T> {
        
        return { [self] serial, completion in
            
            let createRequest = logger.decorate(createRequest, with: .network, file: file, line: line)
            let mapResponse = logger.decorate(mapResponse: mapResponse, with: .network, file: file, line: line)
            
            do {
                let request = try createRequest(serial)
                httpClient.performRequest(request) {
                    
                    switch $0 {
                    case .failure:
                        completion(.none)
                        
                    case let .success((data, response)):
                        switch mapResponse(data, response) {
                        case .failure:
                            completion(.none)
                            
                        case let .success(stamped):
                            if stamped.serial == serial {
                                completion(.none)
                            } else {
                                completion(stamped)
                            }
                        }
                    }
                }
            } catch {
                completion(.none)
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
    
    func test_composeSerial_shouldDeliverFailureOnCreateRequestFailure() {
        
        let (sut, _,_) = makeSUT()
        let composed: SerialLoad = sut.composeSerial(
            createRequest: { _ in throw anyError() },
            mapResponse: { _,_ in .failure(anyError()) }
        )
        let exp = expectation(description: "wait for completion")
        
        composed(anyMessage()) {
            
            XCTAssertNil($0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
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
    
    func test_composeSerial_shouldDeliverFailureOnHTTPClientFailure() {
        
        let (sut, httpClientSpy, _) = makeSUT()
        let composed: SerialLoad = sut.composeSerial(
            createRequest: { _ in anyURLRequest() },
            mapResponse: { _,_ in .failure(anyError()) }
        )
        let exp = expectation(description: "wait for completion")
        
        composed(anyMessage()) {
            
            XCTAssertNil($0)
            exp.fulfill()
        }
        
        httpClientSpy.complete(with: anyError())
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_composeSerial_shouldNotCallMapResponseOnHTTPClientFailure() {
        
        let (sut, httpClientSpy, _) = makeSUT()
        let mapResponseSpy = MapResponseSpy(stubs: [.success(makeStamped())])
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
        let mapResponseSpy = MapResponseSpy(stubs: [.success(makeStamped())])
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
    
    func test_composeSerial_shouldDeliverFailureOnMapResponseFailure() {
        
        let (sut, httpClientSpy, _) = makeSUT()
        let composed: SerialLoad = sut.composeSerial(
            createRequest: { _ in anyURLRequest() },
            mapResponse: { _,_ in .failure(anyError()) }
        )
        let exp = expectation(description: "wait for completion")
        
        composed(anyMessage()) {
            
            XCTAssertNil($0)
            exp.fulfill()
        }
        
        httpClientSpy.complete(with: (anyData(), anyHTTPURLResponse()))
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_composeSerial_shouldDeliverFailureOnSameSerial() {
        
        let serial = anyMessage()
        let (sut, httpClientSpy, _) = makeSUT()
        let composed: SerialLoad = sut.composeSerial(
            createRequest: { _ in anyURLRequest() },
            mapResponse: { _,_ in self.makeStampedSuccess(serial: serial) }
        )
        let exp = expectation(description: "wait for completion")
        
        composed(serial) {
            
            XCTAssertNil($0)
            exp.fulfill()
        }
        
        httpClientSpy.complete(with: (anyData(), anyHTTPURLResponse()))
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_composeSerial_shouldDeliverStampedOnDifferentSerial() {
        
        let stamped = makeStamped()
        let (sut, httpClientSpy, _) = makeSUT()
        let composed: SerialLoad = sut.composeSerial(
            createRequest: { _ in anyURLRequest() },
            mapResponse: { _,_ in self.makeStampedSuccess(stamped) }
        )
        let exp = expectation(description: "wait for completion")
        
        composed(anyMessage()) {
            
            XCTAssertNoDiff($0, stamped)
            exp.fulfill()
        }
        
        httpClientSpy.complete(with: (anyData(), anyHTTPURLResponse()))
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = LoggingRemoteNanoServiceComposer
    private typealias SerialLoad = SUT.SerialLoad<Value>
    private typealias CreateRequestSpy = CallSpy<String?, URLRequest>
    private typealias Stamped = SUT.Stamped<Value>
    private typealias MapResponseSpy = CallSpy<(Data, HTTPURLResponse), Result<Stamped, Failure>>
    
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
    
    private func makeStamped(
        value: Value? = nil,
        serial: String = anyMessage()
    ) -> Stamped {
        
        return .init(value: value ?? makeValue(), serial: serial)
    }
    
    private func makeStampedSuccess(
        _ stamped: Stamped
    ) -> Result<Stamped, Failure> {
        
        return .success(stamped)
    }
    
    private func makeStampedSuccess(
        value: Value? = nil,
        serial: String = anyMessage()
    ) -> Result<Stamped, Failure> {
        
        return .success(makeStamped(value: value, serial: serial))
    }
}
