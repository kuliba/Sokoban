//
//  RemoteServiceTests.swift
//  
//
//  Created by Igor Malyarov on 01.08.2023.
//

import GenericRemoteService
import XCTest

final class RemoteServiceTests: XCTestCase {
    
    func test_init_shouldNotRequestHTTPClient() {
        
        let request = anyRequest("some.url")
        let (_, client) = makeSUT(createRequest: { _ in request })
        
        XCTAssertEqual(client.requests, [])
    }
    
    func test_process_shouldDeliverErrorOnMakeRequestError() {
        
        let createRequestError = anyError(domain: "make request error")
        let (sut, _) = makeSUT(createRequest: { _ in throw createRequestError })
        let exp = expectation(description: "wait for completion")
        
        sut.process(()) { result in
            
            switch result {
            case let .failure(error as NSError):
                XCTAssertNoDiff(error, createRequestError as NSError)
                
            default:
                XCTFail("Expected \(createRequestError), got \(result) instead.")
            }
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_process_shouldRequestHTTPClient() {
        
        let request = anyRequest("some.url")
        let (sut, client) = makeSUT(createRequest: { _ in request })
        
        sut.process(()) { _ in }
        
        XCTAssertEqual(client.requests, [request])
    }
    
    func test_process_shouldDeliverErrorOnHTTPClientError() {
        
        let httpError = anyError(domain: "HTTP Error")
        let (sut, client) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.process(()) { result in
            
            switch result {
            case let .failure(error as NSError):
                XCTAssertNoDiff(error, httpError as NSError)
                
            default:
                XCTFail("Expected \(httpError), got \(result) instead.")
            }
            
            exp.fulfill()
        }
        client.complete(with: .failure(httpError))
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_process_shouldNotDeliverHTTPClientResultOnSUTInstanceDeallocation() {
        
        let client = HTTPClientSpy()
        var sut: ProcessingSessionCodeService? = .init(
            createRequest: { _ in anyRequest() },
            performRequest: client.get(_:completion:),
            mapResponse: { _, _ in serverResponseError() }
        )
        
        var result: Result<Output, Error>?
        sut?.process(()) {
            result = $0
        }
        sut = nil
        client.complete(with: .failure(anyError()))
        
        XCTAssertNil(result)
    }
    
    func test_process_shouldDeliverServerErrorOnServerError() {
        
        let (sut, client) = makeSUT(mapResponse: { _, _ in serverResponseError() })
        let exp = expectation(description: "wait for completion")
        
        sut.process(()) { result in
            
            switch result {
            case let .success(.error(error)):
                XCTAssertNoDiff(error, serverError())
                
            default:
                XCTFail("Expected result, got \(result) instead.")
            }
            
            exp.fulfill()
        }
        client.complete(with: .success(successResponse()))
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_process_shouldDeliverValueOnServerResponseOK() {
        
        let (sut, client) = makeSUT(mapResponse: { _, _ in serverResponseOK() })
        let exp = expectation(description: "wait for completion")
        
        sut.process(()) { result in
            
            switch result {
            case let .success(.response(response)):
                XCTAssertNoDiff(response, anyProcessingSessionCode())
                
            default:
                XCTFail("Expected result, got \(result) instead.")
            }
            
            exp.fulfill()
        }
        client.complete(with: .success(successResponse()))
        
        waitForExpectations(timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private typealias Input = Void
    private typealias Output = ServerResponse<ProcessingSessionCode>
    private typealias ProcessingSessionCodeService = RemoteService<Input, Output>
    
    private func makeSUT(
        createRequest: @escaping ProcessingSessionCodeService.CreateRequest = { _ in anyRequest() },
        mapResponse: @escaping ProcessingSessionCodeService.MapResponse = { _ in serverResponseError() },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: ProcessingSessionCodeService,
        client: HTTPClientSpy
    ) {
        let client = HTTPClientSpy()
        let sut = ProcessingSessionCodeService(
            createRequest: createRequest,
            performRequest: client.get(_:completion:),
            mapResponse: mapResponse
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private final class HTTPClientSpy {
        
        func get(
            _ request: HTTPDomain.Request,
            completion: @escaping HTTPDomain.Completion
        ) {
            messages.append((request, completion))
        }
        
        private typealias Message = (request: HTTPDomain.Request, completion: HTTPDomain.Completion)
        
        private var messages = [Message]()
        
        var requests: [HTTPDomain.Request] {
            
            messages.map(\.request)
        }
        
        func complete(
            with result: HTTPDomain.Result,
            at index: Int = 0
        ) {
            messages[index].completion(result)
        }
    }
    
    private func successResponse() -> (Data, HTTPURLResponse) {
        
        return (
            makeSuccessResponseData(),
            makeHTTPURLResponse(statusCode: statusCodeOK)
        )
    }
    
    private func makeSuccessResponseData(
        code: String = "22345200-abe8-4f60-90c8-0d43c5f6c0f6",
        phone: String = "71234567890"
    ) -> Data {
        
        let json: [String: Any] = [
            "code": code,
            "phone": phone
        ]
        
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func makeHTTPURLResponse(
        statusCode: Int
    ) -> HTTPURLResponse {
        
        .init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
    
    private let statusCodeOK = 200
    private let statusCode500 = 500
}

private enum ServerResponse<Response> {
    
    case response(Response)
    case error(ServerError)
    
    struct ServerError: Equatable {
        
        let statusCode: Int
        let errorMessage: String
    }
}

private struct ProcessingSessionCode: Equatable {
    
    let code: String
    let phone: String
}

private func serverResponseError() -> ServerResponse<ProcessingSessionCode> {
    
    .error(serverError())
}
private func serverError() -> ServerResponse<ProcessingSessionCode>.ServerError {
    
    .init(statusCode: 3100, errorMessage: "Error 3100")
}

private func serverResponseOK() -> ServerResponse<ProcessingSessionCode> {
    
    .response(anyProcessingSessionCode())
}

private func anyProcessingSessionCode(
) -> ProcessingSessionCode {
    
    .init(
        code: "22345200-abe8-4f60-90c8-0d43c5f6c0f6",
        phone: "71234567890"
    )
}

private func anyError(domain: String = "", code: Int = 0) -> Error {
    
    NSError(domain: domain, code: code)
}

private func anyRequest(
    _ urlString: String = "http://any.url"
) -> HTTPDomain.Request {
    
    .init(url: anyURL(urlString))
}

private func anyURL(
    _ urlString: String = "http://any.url"
) -> URL {
    
    .init(string: urlString)!
}
