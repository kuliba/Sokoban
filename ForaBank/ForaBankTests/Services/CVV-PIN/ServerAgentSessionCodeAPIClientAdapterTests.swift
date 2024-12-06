//
//  ServerAgentSessionCodeAPIClientAdapterTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 21.07.2023.
//

import Combine
import CvvPin
@testable import ForaBank
import ServerAgent
import XCTest

final class ServerAgentSessionCodeAPIClientAdapterTests: XCTestCase {
    
    func test_get_shouldDeliverErrorOnServerError() {
        
        let sut = makeSUT(serverStub: .failure(.notAuthorized))
        
        expect(sut: sut, toDeliver: [
            .failure(ServerAgentError.notAuthorized)
        ])
    }
    
    func test_get_shouldDeliverConcreteErrorOnServerError() {
        
        let sut = makeSUT(serverStub: .failure(.emptyResponseData))
        
        expect(sut: sut, toDeliver: [
            .failure(ServerAgentError.emptyResponseData)
        ])
    }
    
    func test_get_shouldDeliverNonOkResponse() {
        
        let sut = makeSUT(serverStub: .success(.nonOKResponse))
        
        expect(sut: sut, toDeliver: [
            .success(.nonOKResponse)
        ])
    }
    
    func test_get_shouldDeliverOkResponseWithNilData() {
        
        let sut = makeSUT(serverStub: .success(.okResponseWithNilData))
        
        expect(sut: sut, toDeliver: [
            .success(.okResponseWithNilData)
        ])
    }
    
    func test_get_shouldDeliverSuccessfulResponse() {
        
        let sut = makeSUT(serverStub: .success(.successfulResponse(code: "ABC123")))
        
        expect(sut: sut, toDeliver: [
            .success(.successfulResponse(code: "ABC123"))
        ])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        serverStub: APIServerAgentStub.GetResult,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ServerAgentSessionCodeAPIClientAdapter {
        
        let agent = APIServerAgentStub(stub: serverStub)
        let sut = ServerAgentSessionCodeAPIClientAdapter(
            token: "any token",
            serverAgent: agent
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(agent, file: file, line: line)
        
        return sut
    }
    
    final class APIServerAgentStub: ServerAgentProtocol {
        
        typealias GetSessionCode = ServerCommands.CvvPin.GetProcessingSessionCode
        typealias GetResult = Swift.Result<GetSessionCode.Response, ServerAgentError>
        
        private let stub: GetResult
        
        init(stub: GetResult) {
            
            self.stub = stub
        }
        
        func executeCommand<Command>(
            command: Command,
            completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void
        ) where Command: ServerCommand {
            
            if let stub = stub as? Result<Command.Response, ServerAgentError> {
                completion(stub)
            } else {
                XCTFail("Unexpected completion result type.")
            }
        }
        
        // MARK: - not used
        
        func executeDownloadCommand<Command>(command: Command, completion: @escaping (Swift.Result<Command.Response, ServerAgentError>) -> Void) where Command: ServerDownloadCommand {
            
            fatalError("unimplemented")
        }
        
        func executeUploadCommand<Command>(command: Command, completion: @escaping (Swift.Result<Command.Response, ServerAgentError>) -> Void) where Command: ServerUploadCommand {
            
            fatalError("unimplemented")
        }
    }
    
    typealias APIResult = Result<API.ServerResponse<APISessionCode, Int>, any Error>
    
    private func expect(
        sut: ServerAgentSessionCodeAPIClientAdapter,
        toDeliver expectedResults: [APIResult],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [Result<API.ServerResponse<APISessionCode, Int>, any Error>]()
        let exp = expectation(description: "wait for server response")
        sut.data {
            receivedResults.append($0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedResults.count, expectedResults.count, "Expected \(expectedResults.count), got \(receivedResults.count) instead.", file: file, line: line)
        
        zip(receivedResults, expectedResults).enumerated()
            .forEach { index, element in
                
                switch element {
                case let (.success(received), .success(expected)):
                    XCTAssertNoDiff(received, expected, file: file, line: line)
                    
                case let (.failure(received as NSError), .failure(expected as NSError)):
                    XCTAssertNoDiff(received, expected, file: file, line: line)
                    
                default:
                    XCTFail("Expected \(element.1), got \(element.0) instead.", file: file, line: line)
                }
            }
    }
}

private extension ServerCommands.CvvPin.GetProcessingSessionCode.Response {
    
    static let nonOKResponse: Self = .init(
        statusCode: .incorrectRequest,
        errorMessage: "Some Error",
        data: nil
    )
    
    static let okResponseWithNilData: Self = .init(
        statusCode: .ok,
        errorMessage: nil,
        data: nil
    )
    
    static func successfulResponse(
        code: String = "code123",
        phone: String = "phoneABC"
    ) -> Self {
        
        .init(
            statusCode: .ok,
            errorMessage: nil,
            data: .init(code: code, phone: phone)
        )
    }
}

private extension API.ServerResponse where Payload == APISessionCode, ServerStatusCode == Int {
    
    static let nonOKResponse: Self = .init(
        statusCode: .other(0),
        errorMessage: "Some Error",
        payload: nil
    )
    
    static let okResponseWithNilData: Self = .init(
        statusCode: .ok,
        errorMessage: nil,
        payload: nil
    )
    
    static func successfulResponse(
        code: String = "code123"
    ) -> Self {
        
        .init(
            statusCode: .ok,
            errorMessage: nil,
            payload: .init(value: code)
        )
    }
}
