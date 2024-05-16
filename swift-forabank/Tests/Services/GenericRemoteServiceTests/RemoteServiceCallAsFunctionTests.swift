//
//  RemoteServiceCallAsFunctionTests.swift
//
//
//  Created by Igor Malyarov on 16.05.2024.
//

import GenericRemoteService
import XCTest

final class RemoteServiceCallAsFunctionTests: XCTestCase {
    
    func test_init_shouldNotCallHTTPClient() {
        
        let request = anyRequest()
        let (_, client) = makeSUT(createRequest: { _ in .success(request) })
        
        XCTAssertEqual(client.callCount, 0)
    }
    
    func test_callAsFunction_shouldDeliverErrorOnMakeRequestError() {
        
        let createRequestError = CreateRequestError("make request error")
        let (sut, _) = makeSUT(createRequest: { _ in .failure(createRequestError) })
        
        assert(sut, delivers: [.failure(.createRequest(createRequestError))])
    }
    
    func test_callAsFunction_shouldCallHTTPClientWithRequest() {
        
        let request = anyRequest()
        let (sut, client) = makeSUT(createRequest: { _ in .success(request) })
        
        sut(()) { _ in }
        
        XCTAssertEqual(client.requests, [request])
    }
    
    func test_callAsFunction_shouldDeliverPerformRequestErrorOnHTTPClientError() {
        
        let httpError = PerformRequestError("HTTP Error")
        let (sut, client) = makeSUT()
        
        assert(sut, delivers: [
            .failure(.performRequest(.init()))
        ], on: {
            
            client.complete(with: .failure(httpError))
        })
    }
    
    func test_callAsFunction_shouldNotDeliverHTTPClientResultOnSUTInstanceDeallocation() {
        
        let client = HTTPClientSpy()
        var sut: SUT? = .init(
            createRequest: { _ in .success(anyRequest()) },
            performRequest: client.get(_:completion:),
            mapResponse: { _,_ in .failure(.init()) }
        )
        
        var result: SUT.ProcessResult?
        sut?.process(()) {
            result = $0
        }
        sut = nil
        client.complete(with: .failure(.init()))
        
        XCTAssertNil(result)
    }
    
    func test_callAsFunction_shouldDeliverMapResponseErrorOnMapResponseError() {
        
        let mapResponseError = MapResponseError("important!")
        let (sut, client) = makeSUT(mapResponse: { _,_ in .failure(mapResponseError) })
        
        assert(sut, delivers: [
            .failure(.mapResponse(mapResponseError))
        ], on: {
            
            client.complete(with: .success(successResponse()))
        })
    }
    
    func test_callAsFunction_shouldDeliverValueOnSuccess() {
        
        let output = Output()
        let (sut, client) = makeSUT(mapResponse: { _,_ in .success(output) })
        
        assert(sut, delivers: [.success(output)], on: {
            
            client.complete(with: .success(successResponse()))
        })
    }
    
    // MARK: - Helpers
    
    private typealias Input = Void
    private typealias SUT = RemoteService<Input, Output, CreateRequestError, PerformRequestError, MapResponseError>
    
    private func makeSUT(
        createRequest: SUT.CreateRequest? = nil,
        mapResponse: SUT.MapResponse? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        client: HTTPClientSpy
    ) {
        let createRequest = createRequest ?? { _ in .success(anyRequest()) }
        let mapResponse = mapResponse ?? { _ in .success(.init()) }
        let client = HTTPClientSpy()
        let sut = SUT(
            createRequest: createRequest,
            performRequest: client.get(_:completion:),
            mapResponse: mapResponse
        )
        
        return (sut, client)
    }
    
    private struct Output: Equatable {
        
        let value: String
        
        init(_ value: String = UUID().uuidString) {
            
            self.value = value
        }
    }
    
    private struct CreateRequestError: Error {
        
        let message: String
        
        init(_ message: String = UUID().uuidString) {
            
            self.message = message
        }
    }
    
    private struct PerformRequestError: Error {
        
        let message: String
        
        init(_ message: String = UUID().uuidString) {
            
            self.message = message
        }
    }
    
    private struct MapResponseError: Error {
        
        let message: String
        
        init(_ message: String = UUID().uuidString) {
            
            self.message = message
        }
    }
    
    private final class HTTPClientSpy {
        
        func get(
            _ request: URLRequest,
            completion: @escaping SUT.PerformCompletion
        ) {
            messages.append((request, completion))
        }
        
        private typealias Message = (
            request: URLRequest,
            completion: SUT.PerformCompletion
        )
        
        private var messages = [Message]()
        
        var requests: [URLRequest] { messages.map(\.request) }
        var callCount: Int { requests.count }
        
        func complete(
            with result: SUT.PerformResult,
            at index: Int = 0
        ) {
            messages[index].completion(result)
        }
    }
    
    private func assert(
        _ sut: SUT,
        with input: Input = (),
        delivers expectedResults: [SUT.ProcessResult],
        on action: @escaping () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [SUT.ProcessResult]()
        let exp = expectation(description: "wait for completion")
        
        sut(input) {
            
            receivedResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        waitForExpectations(timeout: 1.0)
        
        assert(receivedResults, equalsTo: expectedResults, file: file, line: line)
    }
}

private enum ServerResponse<Response: Equatable>: Equatable {
    
    case response(Response)
    case error(ServerError)
    
    struct ServerError: Equatable {
        
        let statusCode: Int
        let errorMessage: String
    }
}

private func anyRequest(
    _ url: URL = anyURL()
) -> URLRequest {
    
    .init(url: url)
}

private func anyURL(
    _ urlString: String = UUID().uuidString
) -> URL {
    
    .init(string: urlString)!
}

private func successResponse(
    _ string: String = UUID().uuidString
) -> (Data, HTTPURLResponse) {
    
    return (
        makeSuccessResponseData(string),
        makeHTTPURLResponse(statusCode: statusCodeOK)
    )
}

private func makeSuccessResponseData(
    _ string: String = UUID().uuidString
) -> Data {
    
    .init(string.utf8)
}

private func makeHTTPURLResponse(
    statusCode: Int
) -> HTTPURLResponse {
    
    .init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}

private let statusCodeOK = 200
private let statusCode500 = 500
