//
//  LoggingRemoteNanoServiceComposer+composeSerialLoadTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 18.10.2024.
//

@testable import Vortex
import XCTest

final class LoggingRemoteNanoServiceComposer_composeSerialLoadTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, httpClientSpy, loggerSpy) = makeSUT()
        
        XCTAssertEqual(httpClientSpy.callCount, 0)
        XCTAssertEqual(loggerSpy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_composeSerial_shouldCallCreateRequestWithNilOnNilSerial() {
        
        let createRequestSpy = CreateRequestSpy(stubs: [anyURLRequest()])
        let sut = makeSUT().sut
        let composed: SerialLoad = sut.composeSerialLoad(
            createRequest: createRequestSpy.call(payload:),
            mapResponse: { _,_ in .failure(anyError()) }
        )
        
        composed(nil) { _ in }
        
        XCTAssertNoDiff(createRequestSpy.payloads, [nil])
        XCTAssertNotNil(sut)
    }
    
    func test_composeSerial_shouldCallCreateRequestWithSerial() {
        
        let serial = anyMessage()
        let createRequestSpy = CreateRequestSpy(stubs: [anyURLRequest()])
        let sut = makeSUT().sut
        let composed: SerialLoad = sut.composeSerialLoad(
            createRequest: createRequestSpy.call(payload:),
            mapResponse: { _,_ in .failure(anyError()) }
        )
        
        composed(serial) { _ in }
        
        XCTAssertNoDiff(createRequestSpy.payloads, [serial])
        XCTAssertNotNil(sut)
    }
    
    func test_composeSerial_shouldDeliverFailureOnCreateRequestFailure() {
        
        let (sut, _,_) = makeSUT()
        
        expect(
            sut,
            createRequest: { _ in throw anyError() },
            response: .failure(makeFailure()),
            with: anyMessage(),
            assert: { XCTAssertNil($0) },
            on: ()
        )
    }
    
    func test_composeSerial_shouldLogFailureOnCreateRequestFailure() {
        
        let (sut, _, loggerSpy) = makeSUT()
        
        expect(
            sut,
            createRequest: { _ in throw TestFailure() },
            response: .failure(makeFailure()),
            with: anyMessage(),
            assert: { _ in
                
                XCTAssertNoDiff(loggerSpy.events.last, .init(level: .error, category: .network, message: "RemoteService: TestFailure()"))
            },
            on: ()
        )
    }
    
    func test_composeSerial_shouldCallHTTPClientWithRequest() {
        
        let request = anyURLRequest()
        let (sut, httpClientSpy, _) = makeSUT()
        let composed: SerialLoad = sut.composeSerialLoad(
            createRequest: { _ in request },
            mapResponse: { _,_ in .failure(anyError()) }
        )
        
        composed(anyMessage()) { _ in }
        
        XCTAssertNoDiff(httpClientSpy.requests, [request])
    }
    
    func test_composeSerial_shouldDeliverFailureOnHTTPClientFailure() {
        
        let (sut, httpClientSpy, _) = makeSUT()
        
        expect(
            sut,
            createRequest: { _ in anyURLRequest() },
            response: .failure(makeFailure()),
            with: anyMessage(),
            assert: { XCTAssertNil($0) },
            on: httpClientSpy.complete(with: anyError())
        )
    }
    
    func test_composeSerial_shouldLogFailureOnHTTPClientFailure() {
        
        let url = anyURL()
        let (sut, httpClientSpy, loggerSpy) = makeSUT()
        
        expect(
            sut,
            createRequest: { _ in anyURLRequest(url: url) },
            response: .failure(makeFailure()),
            with: anyMessage(),
            assert: { _ in
                
                XCTAssertNoDiff(loggerSpy.events.last, .init(level: .error, category: .network, message: "Perform request \(url.lastPathComponent) failure: TestFailure()."))
            },
            on: httpClientSpy.complete(with: TestFailure())
        )
    }
    
    func test_composeSerial_shouldNotCallMapResponseOnHTTPClientFailure() {
        
        let (sut, httpClientSpy, _) = makeSUT()
        let mapResponseSpy = MapResponseSpy(stubs: [.success(makeStamped())])
        
        expect(
            sut,
            createRequest: { _ in anyURLRequest() },
            mapResponse: mapResponseSpy.call(_:_:),
            with: anyMessage(),
            on: httpClientSpy.complete(with: anyError())
        )
        
        XCTAssertEqual(mapResponseSpy.callCount, 0)
    }
    
    func test_composeSerial_shouldCallMapResponseWithDataAndResponseOnHTTPClientSuccess() {
        
        let (data, response) = (anyData(), anyHTTPURLResponse())
        let (sut, httpClientSpy, _) = makeSUT()
        let mapResponseSpy = MapResponseSpy(stubs: [.success(makeStamped())])
        
        expect(
            sut,
            createRequest: { _ in anyURLRequest() },
            mapResponse: mapResponseSpy.call(_:_:),
            with: anyMessage(),
            on: httpClientSpy.complete(with: (data, response))
        )
        
        XCTAssertNoDiff(mapResponseSpy.payloads.map(\.0), [data])
        XCTAssertNoDiff(mapResponseSpy.payloads.map(\.1), [response])
    }
    
    func test_composeSerial_shouldDeliverFailureOnMapResponseFailure() {
        
        let (sut, httpClientSpy, _) = makeSUT()
        
        expect(
            sut,
            createRequest: { _ in anyURLRequest() },
            response: .failure(makeFailure()),
            with: anyMessage(),
            assert: { XCTAssertNil($0) },
            on: httpClientSpy.complete(with: (anyData(), anyHTTPURLResponse()))
        )
    }
    
    func test_composeSerial_shouldLogFailureOnMapResponseFailure() {
        
        let (sut, httpClientSpy, loggerSpy) = makeSUT()
        
        expect(
            sut,
            createRequest: { _ in anyURLRequest() },
            response: .failure(makeFailure("mapping-failure")),
            with: anyMessage(),
            assert: { _ in
                
                XCTAssertNoDiff(loggerSpy.events.last, .init(level: .error, category: .network, message: "RemoteService: response mapping failure Failure(value: \"mapping-failure\")"))
            },
            on: httpClientSpy.complete(with: (anyData(), anyHTTPURLResponse()))
        )
    }
    
    func test_composeSerial_shouldDeliverFailureOnSameSerial() {
        
        let serial = anyMessage()
        let (sut, httpClientSpy, _) = makeSUT()
        
        expect(
            sut,
            createRequest: { _ in anyURLRequest() },
            response: makeStampedSuccess(serial: serial),
            with: serial,
            assert: { XCTAssertNil($0) },
            on: httpClientSpy.complete(with: (anyData(), anyHTTPURLResponse()))
        )
    }
    
    func test_composeSerial_shouldLogFailureOnSameSerial() {
        
        let serial = anyMessage()
        let url = anyURL()
        let (sut, httpClientSpy, loggerSpy) = makeSUT()
        
        expect(
            sut,
            createRequest: { _ in anyURLRequest(url: url) },
            response: makeStampedSuccess(serial: serial),
            with: serial,
            assert: { _ in
                
                XCTAssertNoDiff(loggerSpy.events.last, .init(level: .info, category: .network, message: "Response for \(url.lastPathComponent) has same serial."))
            },
            on: httpClientSpy.complete(with: (anyData(), anyHTTPURLResponse()))
        )
    }
    
    func test_composeSerial_shouldDeliverStampedOnDifferentSerial() {
        
        let stamped = makeStamped()
        let (sut, httpClientSpy, _) = makeSUT()
        
        expect(
            sut,
            createRequest: { _ in anyURLRequest() },
            response: makeStampedSuccess(stamped),
            with: anyMessage(),
            assert: { XCTAssertNoDiff($0, stamped) },
            on: httpClientSpy.complete(with: (anyData(), anyHTTPURLResponse()))
        )
    }
    
    func test_composeSerial_shouldLogSuccessOnDifferentSerial() {
        
        let stamped = makeStamped()
        let url = anyURL()
        let (sut, httpClientSpy, loggerSpy) = makeSUT()
        
        expect(
            sut,
            createRequest: { _ in anyURLRequest(url: url) },
            response: makeStampedSuccess(stamped),
            with: anyMessage(),
            assert: { _ in
                
                XCTAssertNoDiff(loggerSpy.events.last, .init(level: .info, category: .network, message: "Response for \(url.lastPathComponent) has different serial."))
            },
            on: httpClientSpy.complete(with: (anyData(), anyHTTPURLResponse()))
        )
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
    
    private struct TestFailure: Error {}
    
    private func expect(
        _ sut: SUT,
        createRequest: @escaping (String?) throws -> URLRequest,
        response: Result<Stamped, Failure>,
        with serial: String? = anyMessage(),
        assert: @escaping (Stamped?) -> Void = { _ in },
        on action: @autoclosure () -> Void,
        timeout: TimeInterval = 1
    ) {
        expect(
            sut,
            createRequest: createRequest,
            mapResponse: { _,_ in response },
            with: serial,
            assert: assert,
            on: action(),
            timeout: timeout
        )
    }
    
    private func expect(
        _ sut: SUT,
        createRequest: @escaping (String?) throws -> URLRequest,
        mapResponse: @escaping (Data, HTTPURLResponse) -> Result<Stamped, Failure>,
        with serial: String? = anyMessage(),
        assert: @escaping (Stamped?) -> Void = { _ in },
        on action: @autoclosure () -> Void,
        timeout: TimeInterval = 1
    ) {
        let composed: SerialLoad = sut.composeSerialLoad(
            createRequest: createRequest,
            mapResponse: mapResponse
        )
        let exp = expectation(description: "wait for completion")
        
        composed(serial) {
            
            assert($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}
