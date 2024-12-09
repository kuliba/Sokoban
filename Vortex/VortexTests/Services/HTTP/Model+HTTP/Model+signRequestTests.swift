//
//  Model+signRequestTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 01.08.2023.
//

@testable import Vortex
import ServerAgent
import XCTest

final class Model_signRequestTests: XCTestCase {
    
    func test_signRequest_shouldSignRequestWithToken() {
        
        let (sut, request, token) = makeSUT()
        
        let signRequest = sut.signRequest(request, withToken: token)
        
        XCTAssertNoDiff(signRequest.allHTTPHeaderFields, [
            "X-XSRF-TOKEN": token,
            "Content-Type": "application/json"
        ])
    }
    
    func test_signRequest_shouldSetCookies() throws {
        
        let serverAgent = ServerAgent(
            baseURL: "abc",
            encoder: .init(),
            decoder: .init(),
            logError: { _ in },
            logMessage: { _ in },
            sendAction: { _ in }
        )
        serverAgent.cookies = [try anyHTTPCookie()]
        let (sut, request, token) = makeSUT(serverAgent: serverAgent)
        
        let signRequest = sut.signRequest(request, withToken: token)
        
        XCTAssertNoDiff(signRequest.allHTTPHeaderFields, [
            "X-XSRF-TOKEN": token,
            "Cookie": "name=some cookie",
            "Content-Type": "application/json"
        ])
    }
    
    func test_signRequest_shouldNotChangeRequestMethod() {
        
        let (request, signRequest) = requests()
        
        XCTAssertNoDiff(signRequest.httpMethod, request.httpMethod)
    }
    
    func test_signRequest_shouldNotChangeRequestHTTPBody() {
        
        let (request, signRequest) = requests()
        
        XCTAssertNoDiff(signRequest.httpBody, request.httpBody)
    }
    
    func test_signRequest_shouldSetHTTPHeaderFields() {
        
        let (sut, request, token) = makeSUT()
        
        let signRequest = sut.signRequest(request, withToken: token)
        
        XCTAssertNoDiff(signRequest.allHTTPHeaderFields, [
            "X-XSRF-TOKEN": token,
            "Content-Type": "application/json"
        ])
    }
    
    func test_signRequest_shouldSetCookiesHandling() {
        
        let (request, signRequest) = requests()
        
        XCTAssertNoDiff(signRequest.httpShouldHandleCookies, false)
        XCTAssertNotEqual(signRequest.httpShouldHandleCookies, request.httpShouldHandleCookies)
    }
    
    func test_signRequest_shouldSignRequest() {
        
        let (_, signRequest) = requests()
        
        XCTAssertNoDiff(signRequest.cachePolicy, .useProtocolCachePolicy)
        XCTAssertNoDiff(signRequest.timeoutInterval, 60)
        XCTAssertNoDiff(signRequest.mainDocumentURL, nil)
        XCTAssertNoDiff(signRequest.networkServiceType, .default)
        XCTAssertNoDiff(signRequest.allowsCellularAccess, true)
        XCTAssertNoDiff(signRequest.httpShouldHandleCookies, false)
        XCTAssertNoDiff(signRequest.httpShouldUsePipelining, false)
    }
    
    func test_signRequest_shouldNotChangeRequestFields() {
        
        let (request, signRequest) = requests()
        
        XCTAssertNoDiff(signRequest.cachePolicy, request.cachePolicy)
        XCTAssertNoDiff(signRequest.timeoutInterval, request.timeoutInterval)
        XCTAssertNoDiff(signRequest.mainDocumentURL, request.mainDocumentURL)
        XCTAssertNoDiff(signRequest.networkServiceType, request.networkServiceType)
        XCTAssertNoDiff(signRequest.allowsCellularAccess, request.allowsCellularAccess)
        XCTAssertNoDiff(signRequest.httpShouldUsePipelining, request.httpShouldUsePipelining)
    }
    
    // MARK: - Helpers
    
    private func requests() -> (
        request: URLRequest,
        signedReuest: URLRequest
    ) {
        let (sut, request, token) = makeSUT()
        let signRequest = sut.signRequest(request, withToken: token)
        
        return (request, signRequest)
    }
    
    private func makeSUT(
        serverAgent: ServerAgentProtocol = ServerAgentEmptyMock(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: Model,
        request: URLRequest,
        token: TokenProvider.Token
    ) {
        let sut: Model = .mockWithEmptyExcept(serverAgent: serverAgent)
        let request = anyURLRequest()
        let token = anyToken()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, request, token)
    }
    
    private func anyToken() -> TokenProvider.Token {
        
        "any token"
    }
    
    private func anyHTTPCookie() throws -> HTTPCookie {
        
        try XCTUnwrap(HTTPCookie(properties: [
            .path: "/",
            .domain: ".example.com",
            .name: "name",
            .value: "some cookie",
        ]))
    }
}
