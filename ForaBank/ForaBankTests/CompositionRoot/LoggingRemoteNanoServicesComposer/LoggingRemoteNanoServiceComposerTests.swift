//
//  LoggingRemoteNanoServiceComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 08.09.2024.
//

@testable import ForaBank
import XCTest

final class LoggingRemoteNanoServiceComposerTests: XCTestCase {
    
    func test_init_shouldDNotCallCollaborators() {
        
        let (sut, httpClient, logger) = makeSUT()
        
        XCTAssertEqual(httpClient.callCount, 0)
        XCTAssertEqual(logger.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_composed_shouldCallMakeRequestWithPayload() {
        
        let payload = makePayload()
        let (sut, _,_) = makeSUT()
        let makeRequest = CallSpy<Payload, URLRequest>(stubs: [anyURLRequest()])
        let service: NanoService<Payload> = sut.compose(
            createRequest: makeRequest.call(payload:),
            mapResponse: { (_,_) -> Result<Response, Error> in unimplemented() },
            mapError: { _ in unimplemented() }
        )
        
        service(payload) { _ in }
        
        XCTAssertNoDiff(makeRequest.payloads, [payload])
    }
    
    func test_composed_shouldCallHTTPClientWithRequest() {
        
        let request = anyURLRequest()
        let (sut, httpClient, _) = makeSUT()
        let service: NanoService<Payload> = sut.compose(
            createRequest: { _ in request },
            mapResponse: { (_,_) -> Result<Response, Error> in unimplemented() },
            mapError: { _ in unimplemented() }
        )
        
        service(makePayload()) { _ in }
        
        XCTAssertNoDiff(httpClient.requests, [request])
    }
    
    func test_composed_shouldDeliverMappedFailureOnHTTPClientFailure() {
        
        let failure = makeFailure()
        let (sut, httpClient, _) = makeSUT()
        
        expect(sut, with: makePayload(), mappedFailure: failure, delivers: .failure(failure)) {
            
            httpClient.complete(with: .failure(anyError()))
        }
    }
    
    func test_composed_shouldDeliverMappedResponseOnHTTPClientSuccess() {
        
        let response = makeResponse()
        let (sut, httpClient, _) = makeSUT()
        
        expect(sut, with: makePayload(), mapResponseResult: .success(response), delivers: .success(response)) {
            
            httpClient.complete(with: .success((anyData(), anyHTTPURLResponse())))
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = LoggingRemoteNanoServiceComposer
    private typealias NanoService<Payload> = RemoteDomain<Payload, Response, Error, Failure>.Service
    
    private func makeSUT(
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
    
    private struct Payload: Equatable {
        
        let value: String
    }
    
    private func makePayload(
        _ value: String = anyMessage()
    ) -> Payload {
        
        return .init(value: value)
    }
    
    private struct Response: Equatable {
        
        let value: String
    }
    
    private func makeResponse(
        _ value: String = anyMessage()
    ) -> Response {
        
        return .init(value: value)
    }
    
    private struct Failure: Error, Equatable {
        
        let value: String
    }
    
    private func makeFailure(
        _ value: String = anyMessage()
    ) -> Failure {
        
        return .init(value: value)
    }
    
    private func expect<Payload>(
        _ sut: SUT,
        with payload: Payload,
        request: URLRequest = anyURLRequest(),
        mapResponseResult: Result<Response, Error>? = nil,
        mappedFailure: Failure? = nil,
        delivers expectedResult: Result<Response, Failure>,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        let nanoService: NanoService<Payload> = sut.compose(
            createRequest: { _ in request },
            mapResponse: { _,_ in mapResponseResult ?? .success(self.makeResponse()) },
            mapError: { _ in mappedFailure ?? self.makeFailure() }
        )
        
        nanoService(payload) { receivedResult in
            
            XCTAssertNoDiff(receivedResult, expectedResult, file: file, line: line)
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 0.1)
    }
}
