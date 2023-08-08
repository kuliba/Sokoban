//
//  AuthenticatedHTTPClientDecoratorTests.swift
//
//
//  Created by Igor Malyarov on 26.07.2023.
//

@testable import ForaBank
import XCTest

final class AuthenticatedHTTPClientDecoratorTests: XCTestCase {
    
    func test_sendRequest_shouldSignRequestOnTokenRequestSuccess() {
        
        let (sut, tokenProvider, httpClient) = makeSUT()
        let token = anyToken()
        let unsignedRequest = anyRequest()
        let signedRequest = unsignedRequest.signed(with: token)
        
        sut.performRequest(unsignedRequest) { _ in }
        tokenProvider.complete(with: .success(token))
        
        XCTAssertEqual(httpClient.requests, [signedRequest])
    }
    
    func test_sendRequest_shouldNotCallDecorateeOnOnTokenRequestFailure() {
        
        let (sut, tokenProvider, httpClient) = makeSUT()
        
        sut.performRequest(anyRequest()) { _ in }
        tokenProvider.complete(with: .failure(anyError()))
        
        XCTAssertEqual(httpClient.requests, [])
    }
    
    func test_sendRequest_shouldReuseRunningTokenRequestOnMultipleCalls() {
        
        let (sut, tokenProvider, _) = makeSUT()
        XCTAssertEqual(tokenProvider.completions.count, 0)
        
        sut.performRequest(anyRequest()) { _ in }
        sut.performRequest(anyRequest()) { _ in }
        
        XCTAssertEqual(tokenProvider.completions.count, 1)
        
        tokenProvider.complete(with: .failure(anyError()))
        
        sut.performRequest(anyRequest()) { _ in }
        
        XCTAssertEqual(tokenProvider.completions.count, 2)
    }
    
    func test_sendRequest_shouldCompleteWithRespectiveClientResultOnMultipleCalls() throws {
        
        let (sut, tokenProvider, httpClient) = makeSUT()
        XCTAssertEqual(tokenProvider.completions.count, 0)
        
        var result1: HTTPClient.Result?
        sut.performRequest(anyRequest()) { result1 = $0 }
        
        var result2: HTTPClient.Result?
        sut.performRequest(anyRequest()) { result2 = $0 }
        
        tokenProvider.complete(with: .success(anyToken()))
        
        let successResponse = makeSuccessResponse()
        httpClient.complete(with: .success(successResponse), at: 0)
        
        let received1 = try XCTUnwrap(result1).get()
        XCTAssertEqual(received1.0, successResponse.0)
        XCTAssertEqual(received1.1, successResponse.1)
        
        httpClient.complete(with: .failure(anyError()), at: 1)
        try XCTAssertThrowsError(result2?.get())
    }
    
    func test_sendRequest_shouldDeliverErrorOnGetTokenError() {
        
        let (sut, tokenProvider, _) = makeSUT()
        
        expect(sut, toDeliver: [.failure(anyError("token error"))], on: {
            
            tokenProvider.complete(with: .failure(anyError("token error")))
        })
    }
    
    func test_sendRequest_shouldDeliverErrorOnHTTPClientError() {
        
        let (sut, tokenProvider, httpClient) = makeSUT()
        
        expect(sut, toDeliver: [.failure(anyError())], on: {
            
            tokenProvider.complete(with: .success(anyToken()))
            httpClient.complete(with: .failure(anyError()))
        })
    }
    
    func test_sendRequest_shouldDeliverSuccessResponseOnSuccess() {
        
        let (sut, tokenProvider, httpClient) = makeSUT()
        let successResponse = makeSuccessResponse()
        
        expect(sut, toDeliver: [.success(successResponse)], on: {
            
            tokenProvider.complete(with: .success(anyToken()))
            httpClient.complete(with: .success(successResponse))
        })
    }
    
    func test_sendRequest_shouldNotDeliverResultOnSUTInstanceDeallocation_befereTokenResult() {
        
        let httpClient = HTTPClientSpy()
        let tokenProvider = TokenProviderSpy()
        var sut: AuthenticatedHTTPClientDecorator? = .init(
            decoratee: httpClient,
            tokenProvider: tokenProvider,
            signRequest: { $0.signed(with: $1) }
        )
        var receivedResults = [HTTPClient.Result]()
        
        sut?.performRequest(.init(url: anyURL()), completion: {
            
            receivedResults.append($0)
        })
        sut = nil
        tokenProvider.complete(with: .success(anyToken()))
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    func test_sendRequest_shouldNotDeliverResultOnSUTInstanceDeallocation_beforeHTTPClientResult() {
        
        let httpClient = HTTPClientSpy()
        let tokenProvider = TokenProviderSpy()
        var sut: AuthenticatedHTTPClientDecorator? = .init(
            decoratee: httpClient,
            tokenProvider: tokenProvider,
            signRequest: { $0.signed(with: $1) }
        )
        var receivedResults = [HTTPClient.Result]()
        
        sut?.performRequest(.init(url: anyURL()), completion: {
            
            receivedResults.append($0)
        })
        tokenProvider.complete(with: .success(anyToken()))
        sut = nil
        httpClient.complete(with: .failure(anyError()))
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: HTTPClient,
        tokenProvider: TokenProviderSpy,
        httpClient: HTTPClientSpy
    ) {
        let tokenProvider = TokenProviderSpy()
        let httpClient = HTTPClientSpy()
        let sut = AuthenticatedHTTPClientDecorator(
            decoratee: httpClient,
            tokenProvider: tokenProvider,
            signRequest: { $0.signed(with: $1) }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(tokenProvider, file: file, line: line)
        trackForMemoryLeaks(httpClient, file: file, line: line)
        
        return (sut, tokenProvider, httpClient)
    }
    
    private func expect(
        _ sut: HTTPClient,
        toDeliver expectedResults: [HTTPClient.Result],
        with request: HTTPClient.Request = anyRequest(),
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [HTTPClient.Result]()
        let exp = expectation(description: "wait for data")
        
        sut.performRequest(request) {
            
            receivedResults.append($0)
            exp.fulfill()
        }
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedResults.count, expectedResults.count, file: file, line: line)
        
        zip(receivedResults, expectedResults)
            .enumerated()
            .forEach { index, result in
                
                switch result {
                case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                    XCTAssertEqual(receivedError, expectedError, "Expected \(expectedError) at index \(index), got \(receivedError) instead", file: file, line: line)
                    
                case let (.success(received), .success(expected)):
                    XCTAssertEqual(received.0, expected.0, "Expected \(expected.0), got \(received.0) instead.", file: file, line: line)
                    XCTAssertEqual(received.1, expected.1, "Expected \(expected.1), got \(received.1) instead.", file: file, line: line)
                    
                default:
                    XCTFail("Expected \(result.1), got \(result.0) instead.", file: file, line: line)
                }
            }
    }
    
    private final class TokenProviderSpy: TokenProvider {
        
        func getToken(completion: @escaping Completion) {
            
            completions.append(completion)
        }
        
        private(set) var completions = [Completion]()
        
        func complete(
            with result: GetTokenResult,
            at index: Int = 0
        ) {
            completions[index](result)
        }
    }
    
    private func makeSuccessResponse() -> (Data, HTTPURLResponse) {
        
        return (
            makeSuccessResponseData(),
            makeHTTPURLResponse(statusCode: statusCodeOK)
        )
    }
    
    private func makeSuccessResponseData() -> Data {
        
        .init()
    }
    
    private func makeHTTPURLResponse(
        statusCode: Int
    ) -> HTTPURLResponse {
        
        .init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
    
    private let statusCodeOK = 200
    private let statusCode500 = 500
}

private func anyRequest() -> URLRequest {
    
    .init(url: anyURL())
}

private func anyToken() -> TokenProvider.Token {
    
    "any token"
}

private func anyURL() -> URL {
    
    .init(string: "http://any.url")!
}

private extension URLRequest {
    
    func signed(
        with token: String,
        tokenHeaderField: String = "token-field"
    ) -> Self {
        
        var request = self
        request.setValue(token, forHTTPHeaderField: tokenHeaderField)
        
        return request
    }
}
