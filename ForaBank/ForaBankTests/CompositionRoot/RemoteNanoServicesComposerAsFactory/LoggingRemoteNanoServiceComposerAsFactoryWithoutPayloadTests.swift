//
//  LoggingRemoteNanoServiceComposerAsFactoryWithoutPayloadTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 08.09.2024.
//

@testable import ForaBank
import XCTest

final class LoggingRemoteNanoServiceComposerAsFactoryWithoutPayloadTests: LoggingRemoteNanoServiceComposerAsFactoryTests {
    
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
            _createRequest: { request },
            mapResponse: { _,_ in unimplemented() }
        )
        
        service { _ in }
        
        XCTAssertNoDiff(httpClient.requests, [request])
    }
    
    func test_composed_shouldDeliverMappedFailureOnHTTPClientFailure() {
        
        let (sut, httpClient, _) = makeSUT()
        
        expect(sut, delivers: .failure(anyError())) {
            
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
            _createRequest: { request },
            mapResponse: { (_,_) -> Result<Response, Error> in unimplemented() }
        )
        
        service { _ in }
        
        XCTAssertNoDiff(httpClient.requests, [request])
    }
    
    func test_composedWithoutErrorMapping_shouldDeliverFailureOnHTTPClientFailure() {
        
        let failure = anyError()
        let (sut, httpClient, _) = makeSUT()
        
        expect(sut, delivers: .failure(failure)) {
            
            httpClient.complete(with: .failure(failure))
        }
    }
    
    func test_composedWithoutErrorMapping_shouldDeliverMappedResponseOnHTTPClientSuccess() {
        
        let response = makeResponse()
        let (sut, httpClient, _) = makeSUT()
        
        expect(sut, mapResponseResult: .success(response), delivers: .success(response)) {
            
            httpClient.complete(with: .success((anyData(), anyHTTPURLResponse())))
        }
    }
    
    // MARK: - Helpers
    
    private typealias NanoService = Composer.NanoServiceVoid<Response>
    
    private func expect(
        _ sut: SUT,
        request: URLRequest = anyURLRequest(),
        mapResponseResult: Result<Response, Error>? = nil,
        delivers expectedResult: Result<Response, Error>,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        let nanoService: NanoService = sut.compose(
            _createRequest: { request },
            mapResponse: { _,_ in mapResponseResult ?? .success(self.makeResponse()) }
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
