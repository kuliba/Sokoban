//
//  RemoteNanoServiceComposerWithPayloadTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 08.09.2024.
//

@testable import ForaBank
import XCTest

final class RemoteNanoServiceComposerWithPayloadTests: RemoteNanoServiceComposerTests {
    
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
            mapResponse: { _,_ in unimplemented() },
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
            mapResponse: { _,_ in unimplemented() },
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
    
    // MARK: - without error mapping
    
    func test_composedWithoutErrorMapping_shouldCallHTTPClientWithRequest() {
        
        let request = anyURLRequest()
        let (sut, httpClient, _) = makeSUT()
        let service = sut.compose(
            createRequest: { (_: Payload) in request },
            mapResponse: { (_,_) -> Result<Response, Error> in unimplemented() }
        )
        
        service(makePayload()) { _ in }
        
        XCTAssertNoDiff(httpClient.requests, [request])
    }
    
    func test_composedWithoutErrorMapping_shouldDeliverFailureOnHTTPClientFailure() {
        
        let failure = anyError()
        let (sut, httpClient, _) = makeSUT()
        
        expect2(sut, with: makePayload(), delivers: .failure(failure)) {
            
            httpClient.complete(with: .failure(failure))
        }
    }
    
    func test_composedWithoutErrorMapping_shouldDeliverMappedResponseOnHTTPClientSuccess() {
        
        let response = makeResponse()
        let (sut, httpClient, _) = makeSUT()
        
        expect2(sut, with: makePayload(), mapResponseResult: .success(response), delivers: .success(response)) {
            
            httpClient.complete(with: .success((anyData(), anyHTTPURLResponse())))
        }
    }
    
    // MARK: - Void
    
    func test_composedVoid_shouldCallHTTPClientWithRequest() {
        
        let request = anyURLRequest()
        let (sut, httpClient, _) = makeSUT()
        let service: NanoService<Void> = sut.compose(
            createRequest: { _ in request },
            mapResponse: { _,_ in unimplemented() },
            mapError: { _ in unimplemented() }
        )
        
        service(()) { _ in }
        
        XCTAssertNoDiff(httpClient.requests, [request])
    }
    
    func test_composedVoid_shouldDeliverMappedFailureOnHTTPClientFailure() {
        
        let failure = makeFailure()
        let (sut, httpClient, _) = makeSUT()
        
        expect(sut, with: (), mappedFailure: failure, delivers: .failure(failure)) {
            
            httpClient.complete(with: .failure(anyError()))
        }
    }
    
    func test_composedVoid_shouldDeliverMappedResponseOnHTTPClientSuccess() {
        
        let response = makeResponse()
        let (sut, httpClient, _) = makeSUT()
        
        expect(sut, with: (), mapResponseResult: .success(response), delivers: .success(response)) {
            
            httpClient.complete(with: .success((anyData(), anyHTTPURLResponse())))
        }
    }
    
    // MARK: - Helpers
    
    typealias NanoService<Payload> = SUT.NanoService<Payload, Response, Failure>
    
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
    
    private func expect2<Payload>(
        _ sut: SUT,
        with payload: Payload,
        request: URLRequest = anyURLRequest(),
        mapResponseResult: Result<Response, Error>? = nil,
        delivers expectedResult: Result<Response, Error>,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        let nanoService = sut.compose(
            createRequest: { (_: Payload) in request },
            mapResponse: { (_,_) -> Result<Response, Error> in mapResponseResult ?? .success(self.makeResponse()) }
        )
        
        nanoService(payload) { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case (.failure, .failure):
                break
                
            case let (.success(receivedResponse), .success(expectedResponse)):
                XCTAssertNoDiff(receivedResponse, expectedResponse, file: file, line: line)
                
            default:
                
                XCTFail("Expected \(expectedResult), but got \(receivedResult) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 0.1)
    }
}
