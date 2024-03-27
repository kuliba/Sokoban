//
//  NanoServices+makeMakeTransferTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 27.03.2024.
//

@testable import ForaBank
import XCTest

final class NanoServices_makeMakeTransferTests: XCTestCase {
    
    func test_shouldCallHTTPClientOnce() throws {
        
        _ = try checkRequest()
    }
    
    func test_shouldSetURL() throws {
        
        try assertURL("https://pl.forabank.ru/dbo/api/v3/rest/transfer/makeTransfer")
    }
    
    func test_shouldSetHTTPMethodToPOST() throws {
        
        try assertHTTPMethod("POST")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        try assertCachePolicy(.reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_shouldPassPayload() throws {
        
        try XCTAssertNotNil(checkRequest(with: makePayload()).httpBody)
    }
    
    func test_shouldDeliverNilOnFailure() {
        
        let (make, httpClient) = makeSUT()
        
        expect(make, toDeliver: nil) {
            
            httpClient.complete(with: .failure(anyError()))
        }
    }
    
    func test_shouldDeliverNilOnEmptyData() {
        
        let (make, httpClient) = makeSUT()
        
        expect(make, toDeliver: nil) {
            
            httpClient.complete(with: .empty)
        }
    }
    
    func test_shouldDeliverNilOnEmptyJSON() {
        
        let (make, httpClient) = makeSUT()
        
        expect(make, toDeliver: nil) {
            
            httpClient.complete(with: .emptyJSON)
        }
    }
    
    func test_shouldDeliverNilOnEmptyArrayJSON() {
        
        let (make, httpClient) = makeSUT()
        
        expect(make, toDeliver: nil) {
            
            httpClient.complete(with: .emptyArrayJSON)
        }
    }
    
    func test_shouldDeliverNilOnInvalidData() {
        
        let (make, httpClient) = makeSUT()
        
        expect(make, toDeliver: nil) {
            
            httpClient.complete(with: .invalid)
        }
    }
    
    func test_shouldDeliverNilOnNullServerResponse() {
        
        let (make, httpClient) = makeSUT()
        
        expect(make, toDeliver: nil) {
            
            httpClient.complete(with: .nullServerResponse)
        }
    }
    
    func test_shouldDeliverNilOnEmptyServerData() {
        
        let (make, httpClient) = makeSUT()
        
        expect(make, toDeliver: nil) {
            
            httpClient.complete(with: .emptyServerData)
        }
    }
    
    func test_shouldDeliverNilOnEmptyArrayServerData() {
        
        let (make, httpClient) = makeSUT()
        
        expect(make, toDeliver: nil) {
            
            httpClient.complete(with: .emptyArrayServerData)
        }
    }
    
    func test_shouldDeliverNilOnInvalidServerData() {
        
        let (make, httpClient) = makeSUT()
        
        expect(make, toDeliver: nil) {
            
            httpClient.complete(with: .invalidServerData)
        }
    }
    
    func test_shouldDeliverNilOnServerError() {
        
        let (make, httpClient) = makeSUT()
        
        expect(make, toDeliver: nil) {
            
            httpClient.complete(with: .serverError)
        }
    }
    
    func test_shouldDeliverNilOnValidDataNonOKStatusCode() {
        
        for nonOkStatusCode in [199, 201, 399, 400, 401, 404] {
            
            let (make, httpClient) = makeSUT()
            let nonOKResponse = anyHTTPURLResponse(with: nonOkStatusCode)
            
            expect(make, toDeliver: nil) {
                
                httpClient.complete(with: .success((.valid, nonOKResponse)))
            }
        }
    }
    
    func test_shouldDeliverResponseOnValidData() {
        
        let (make, httpClient) = makeSUT()

        expect(make, toDeliver: .init(
            operationDetailID: 18483,
            documentStatus: .complete
        )) {
            httpClient.complete(with: .valid)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = NanoServices.MakeTransfer
    private typealias Payload = NanoServices.MakeTransferPayload
    private typealias MakeTransferResult = NanoServices.MakeTransferResult
    private typealias Response = NanoServices.MakeTransferResponse
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClient: HTTPClientSpy
    ) {
        let httpClient = HTTPClientSpy()
        let sut = NanoServices.makeMakeTransfer(httpClient, { _,_,_ in })
        
        trackForMemoryLeaks(httpClient, file: file, line: line)
        
        return (sut, httpClient)
    }
    
    private func assertURL(
        with payload: Payload = makePayload(),
        _ urlString: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let request = try checkRequest(file: file, line: line)
        XCTAssertNoDiff(request.url?.absoluteString, urlString, file: file, line: line)
    }
    
    private func assertHTTPMethod(
        with payload: Payload = makePayload(),
        _ httpMethod: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let request = try checkRequest(file: file, line: line)
        XCTAssertNoDiff(request.httpMethod, httpMethod, file: file, line: line)
    }
    
    private func assertCachePolicy(
        with payload: Payload = makePayload(),
        _ cachePolicy: URLRequest.CachePolicy,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let request = try checkRequest(file: file, line: line)
        XCTAssertNoDiff(request.cachePolicy, cachePolicy, file: file, line: line)
    }
    
    private func checkRequest(
        with payload: Payload = makePayload(),
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> URLRequest {
        
        let (make, httpClient) = makeSUT()
        make(payload) { _ in }
        
        let count = httpClient.requests.count
        XCTAssertNoDiff(count, 1, "Expected to have one request, but got \(count) insted.")
        
        return try XCTUnwrap(httpClient.requests.first, file: file, line: line)
    }
    
    private func expect(
        with payload: Payload = makePayload(),
        toDeliver expectedResult: MakeTransferResult,
        onHTTPClientResult: HTTPClient.Result,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let (make, httpClient) = makeSUT()
        
        expect(
            make,
            with: payload,
            toDeliver: expectedResult,
            on: { httpClient.complete(with: onHTTPClientResult) },
            file: file, line: line
        )
    }
    
    private func expect(
        _ sut: @escaping SUT,
        with payload: Payload = makePayload(),
        toDeliver expectedResult: MakeTransferResult,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        var receivedResult: MakeTransferResult?
        
        sut(payload) {
            
            receivedResult = $0
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertNoDiff(receivedResult, expectedResult, "\nExpected \(String(describing: expectedResult)), got \(String(describing: receivedResult)) instead.", file: file, line: line)
    }
}

private func makePayload(
    _ rawValue: String = UUID().uuidString
) -> NanoServices.MakeTransferPayload {
    
    .init(rawValue)
}

private extension HTTPClientSpy {
    
    func complete(
        with data: Data,
        at index: Int = 0
    ) {
        
        complete(with: .success((data, okResponse)), at: index)
    }
}

private let okResponse = anyHTTPURLResponse(with: 200)

private extension Data {
    
    static let valid = String.valid.json
}

private extension String {
    
    static let valid = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "paymentOperationDetailId": 18483,
        "documentStatus": "COMPLETE"
    }
}
"""
}

// MARK: - reusable

extension Data {
    
    static let empty: Self = .init()
    static let emptyJSON: Self = "{}".json
    static let emptyArrayJSON: Self = "[]".json
    static let invalid: Self = "invalid data".json
    static let nullServerResponse: Self = String.nullServerResponse.json
    static let emptyServerData: Self = String.emptyServerData.json
    static let emptyArrayServerData: Self = String.emptyArrayServerData.json
    static let invalidServerData: Self = String.invalidServerData.json
    static let serverError: Self = String.serverError.json
}

private extension String {
    
    var json: Data { .init(self.utf8) }
    
    static let nullServerResponse = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": null
}
"""
    
    static let emptyServerData = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": {}
}
"""
    
    static let emptyArrayServerData = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": []
}
"""
    
    static let invalidServerData = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": { "a": "junk" }
}
"""
    
    static let serverError = """
{
    "statusCode": 102,
    "errorMessage": "Возникла техническая ошибка",
    "data": null
}
"""
}
