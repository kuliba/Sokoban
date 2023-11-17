//
//  RemoteSessionCodeLoaderTests.swift
//  
//
//  Created by Igor Malyarov on 13.07.2023.
//

import CvvPin
import XCTest

private typealias RemoteLoader = RemoteSessionCodeLoader<DecodableSessionCode>

final class RemoteSessionCodeLoaderTests: XCTestCase {
    
    func test_init_shouldNotRequestData() {
        
        let (_, api) = makeSUT()
        
        XCTAssertEqual(api.requests, [])
    }
    
    func test_load_shouldRequestData() {
        
        let (sut, api) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(api.requests, [.empty])
    }
    
    func test_loadTwice_shouldRequestDataTwice() {
        
        let (sut, api) = makeSUT()
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(api.requests, [.empty, .empty])
    }
    
    func test_load_shouldDeliverErrorOnAPIClientError() {
        
        let (sut, api) = makeSUT()
        
        expect(sut, toLoad: .connectivityError) {
            
            let apiError = anyNSError()
            api.complete(with: apiError)
        }
    }
    
    func test_load_shouldDeliverErrorOnNonOKServerResponse() {
        
        let (sut, api) = makeSUT()
        let codes = [1, 199, 201, 400, 401, 500]
        
        codes.enumerated().forEach { index, code in
            
            expect(sut, toLoad: .invalidData) {
                
                api.complete(withServerStatusCode: .other(code), at: index)
            }
        }
    }
    
    func test_load_shouldDeliverErrorOnOKServerResponseAndNilPayload() {
        
        let (sut, api) = makeSUT()
        
        expect(sut, toLoad: .invalidData) {
            
            api.complete(withServerStatusCode: .ok, payload: nil)
        }
    }
    
    func test_load_shouldDeliverSessionCodeOnOKServerResponseAndNonNilPayload() {
        
        let (sut, api) = makeSUT()
        let code = "session code"
        
        expect(sut, toLoad: .sessionCode(code)) {
            
            api.complete(withServerStatusCode: .ok, payload: .init(value: code))
        }
    }
    
    func test_load_shouldDeliverErrorOnOKServerResponseAndEmptyPayload() {
        
        let (sut, api) = makeSUT()
        let code = ""
        
        expect(sut, toLoad: .invalidData) {
            
            api.complete(withServerStatusCode: .ok, payload: .init(value: code))
        }
    }
    
    func test_load_shouldNotDeliverResultAfterSUTHasBeenDeallocated() {
        
        let api = APIClientSpy()
        var sut: RemoteLoader? = .init(api: api) {
            .init(value: $0.value)
        }
        var receivedResults = [LoadResult]()
        sut?.load { receivedResults.append($0) }
        
        sut = nil
        api.complete(withServerStatusCode: .ok, payload: .init(value: "any"))
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SessionCodeLoader,
        api: APIClientSpy
    ) {
        let api = APIClientSpy()
        let sut = RemoteLoader(api: api) {
            .init(value: $0.value)
        }
        
        trackForMemoryLeaks(api, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, api)
    }
    
    private final class APIClientSpy: APIClient {
        
        typealias Payload = DecodableSessionCode
        typealias ServerStatusCode = Int
        
        private var messages = [(request: APIRequest, completion: Completion)]()
        
        var requests: [APIRequest] { messages.map(\.request) }
        
        func data(
            _ request: APIRequest,
            completion: @escaping Completion
        ) {
            messages.append((request, completion))
        }
        
        func complete(
            with error: Error,
            at index: Int = 0
        ) {
            messages[index].completion(.failure(error))
        }
        
        func complete(
            withServerStatusCode statusCode: StatusCode,
            payload: DecodableSessionCode? = nil,
            at index: Int = 0
        ) {
            let response = makeServerResponse(
                statusCode: statusCode,
                payload: payload
            )
            messages[index].completion(.success(response))
        }
    }
}

private struct DecodableSessionCode: Decodable {
    
    let value: String
}

private extension SessionCodeLoader.Result {
    
    static let connectivityError: Self = .failure(RemoteLoader.LoadError.connectivity)
    static let invalidData: Self = .failure(RemoteLoader.LoadError.invalidData)
    
    static func sessionCode(_ value: String) -> Self {
        
        return .success(.init(value: value))
    }
}

private typealias ServerResponse = API.ServerResponse<DecodableSessionCode, Int>
private typealias StatusCode = ServerResponse.StatusCode

private func makeServerResponse(
    statusCode: StatusCode,
    errorMessage: String? = nil,
    payload: DecodableSessionCode? = nil
) -> ServerResponse {
    
    .init(
        statusCode: statusCode,
        errorMessage: errorMessage,
        payload: payload
    )
}
