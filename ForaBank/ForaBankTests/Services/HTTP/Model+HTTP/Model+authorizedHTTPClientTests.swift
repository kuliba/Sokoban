//
//  Model+authorizedHTTPClientTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 05.08.2023.
//

@testable import ForaBank
import ServerAgent
import XCTest

final class Model_authorizedHTTPClientTests: XCTestCase {
    
    func test_authorizedHTTPClient_shouldDeliverNotAuthorizedErrorOnInactiveSessionState() {
        
        let (_, sessionAgent, _, sut) = makeSUT()
        
        XCTAssertFalse(sessionAgent.isSessionStateActive)
        expect(sut, toDeliver: .failure(ServerAgentError.notAuthorized), on: {})
    }
    
    func test_authorizedHTTPClient_shouldDeliver_ResultOnActiveSessionState() {
        
        let result = (Data(), anyHTTPURLResponse())
        let (spy, sessionAgent, _, sut) = makeSUT()
        sessionAgent.activate()
        
        XCTAssertTrue(sessionAgent.isSessionStateActive)
        expect(sut, toDeliver: .success(result), on: {
            
            spy.complete(with: .success(result))
        })
    }
    
    func test_authorizedHTTPClient_shouldDeliverNotAuthorizedErrorAfterDeactivation() {
        
        let result = (Data(), anyHTTPURLResponse())
        let (spy, sessionAgent, _, sut) = makeSUT()
        sessionAgent.activate()
        
        XCTAssertTrue(sessionAgent.isSessionStateActive)
        expect(sut, toDeliver: .success(result), on: {
            
            spy.complete(with: .success(result))
        })
        
        sessionAgent.deactivate()
        XCTAssertFalse(sessionAgent.isSessionStateActive)
        expect(sut, toDeliver: .failure(ServerAgentError.notAuthorized), on: {})
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        spy: HTTPClientSpy,
        sessionAgent: ActiveInactiveSessionAgent,
        model: Model,
        sut: HTTPClient
    ) {
        let spy = HTTPClientSpy()
        let sessionAgent = ActiveInactiveSessionAgent()
        let model: Model = .mockWithEmptyExcept(
            sessionAgent: sessionAgent
        )
        let sut = model.authenticatedHTTPClient(
            httpClient: spy
        )
        
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(sessionAgent, file: file, line: line)
        trackForMemoryLeaks(model, file: file, line: line)
        
        return (spy, sessionAgent, model, sut)
    }
    
    private typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    private func expect(
        _ sut: HTTPClient,
        toDeliver expectedResult: Result,
        with request: URLRequest = anyURLRequest(),
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for performRequest")
        
        sut.performRequest(request) { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case let (
                .failure(receivedError as NSError),
                .failure(expectedError as NSError)
            ):
                XCTAssertNoDiff(
                    receivedError,
                    expectedError,
                    "Expected \(expectedError), got \(receivedError) instead.",
                    file: file, line: line
                )
                
            case let (
                .success((receivedData, receivedResponse)),
                .success((expectedData, expectedResponse))
            ):
                XCTAssertNoDiff(
                    receivedData,
                    expectedData,
                    "Expected \(expectedData), got \(receivedData) instead.",
                    file: file, line: line
                )
                XCTAssertNoDiff(
                    receivedResponse,
                    expectedResponse,
                    "Expected \(expectedResponse), got \(receivedResponse) instead."
                )
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}

// MARK: DSL

extension SessionAgentProtocol {
    
    var isSessionStateActive: Bool {
        
        if case .active = sessionState.value {
            return true
        } else {
            return false
        }
    }
}
