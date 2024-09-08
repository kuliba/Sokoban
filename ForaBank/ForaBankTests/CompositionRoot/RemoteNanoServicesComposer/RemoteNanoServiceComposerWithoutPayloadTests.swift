//
//  RemoteNanoServiceComposerWithoutPayloadTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 08.09.2024.
//

@testable import ForaBank
import XCTest

final class RemoteNanoServiceComposerWithoutPayloadTests: RemoteNanoServiceComposerTests {
    
    func test_init_shouldDNotCallCollaborators() {
        
        let (sut, httpClient, logger) = makeSUT()
        
        XCTAssertEqual(httpClient.callCount, 0)
        XCTAssertEqual(logger.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_composed_shouldCallHTTPClientWithRequest() {
        
        let request = anyURLRequest()
        let (sut, httpClient, _) = makeSUT()
        let service: NanoService = sut.compose(
            createRequest: { request },
            mapResponse: { _,_ in unimplemented() },
            mapError: { _ in unimplemented() }
        )
        
        service { _ in }
        
        XCTAssertNoDiff(httpClient.requests, [request])
    }
    
    func test_composed_shouldDeliverMappedFailureOnHTTPClientFailure() {
        
        let failure = makeFailure()
        let (sut, httpClient, _) = makeSUT()
        
        expect(sut, mappedFailure: failure, delivers: .failure(failure)) {
            
            httpClient.complete(with: .failure(anyError()))
        }
    }
    
    func test_composed_shouldDeliverMappedResponseOnHTTPClientSuccess() {
        
        let response = makeResponse()
        let (sut, httpClient, _) = makeSUT()
        
        expect(sut, mapResponseResult: .success(response), delivers: .success(response)) {
            
            httpClient.complete(with: .success((anyData(), anyHTTPURLResponse())))
        }
    }
    
    // MARK: - without error mapping
    
    func test_composedWithoutErrorMapping_shouldCallHTTPClientWithRequest() {
        
        let request = anyURLRequest()
        let (sut, httpClient, _) = makeSUT()
        let service = sut.compose(
            createRequest: { request },
            mapResponse: { (_,_) -> Result<Response, Error> in unimplemented() }
        )
        
        service { _ in }
        
        XCTAssertNoDiff(httpClient.requests, [request])
    }
    
    func test_composedWithoutErrorMapping_shouldDeliverFailureOnHTTPClientFailure() {
        
        let failure = anyError()
        let (sut, httpClient, _) = makeSUT()
        
        expect2(sut, delivers: .failure(failure)) {
            
            httpClient.complete(with: .failure(failure))
        }
    }
    
    func test_composedWithoutErrorMapping_shouldDeliverMappedResponseOnHTTPClientSuccess() {
        
        let response = makeResponse()
        let (sut, httpClient, _) = makeSUT()
        
        expect2(sut, mapResponseResult: .success(response), delivers: .success(response)) {
            
            httpClient.complete(with: .success((anyData(), anyHTTPURLResponse())))
        }
    }
    
    // MARK: - Helpers
    
    private typealias NanoService = SUT.VoidNanoService<Response, Failure>
    
    private func expect(
        _ sut: SUT,
        request: URLRequest = anyURLRequest(),
        mapResponseResult: Result<Response, Error>? = nil,
        mappedFailure: Failure? = nil,
        delivers expectedResult: Result<Response, Failure>,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        let nanoService: NanoService = sut.compose(
            createRequest: { request },
            mapResponse: { _,_ in mapResponseResult ?? .success(self.makeResponse()) },
            mapError: { _ in mappedFailure ?? self.makeFailure() }
        )
        
        nanoService { receivedResult in
            
            XCTAssertNoDiff(receivedResult, expectedResult, file: file, line: line)
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 0.1)
    }
    
    private func expect2(
        _ sut: SUT,
        request: URLRequest = anyURLRequest(),
        mapResponseResult: Result<Response, Error>? = nil,
        delivers expectedResult: Result<Response, Error>,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        let nanoService = sut.compose(
            createRequest: { request },
            mapResponse: { (_,_) -> Result<Response, Error> in mapResponseResult ?? .success(self.makeResponse()) }
        )
        
        nanoService { receivedResult in
            
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
