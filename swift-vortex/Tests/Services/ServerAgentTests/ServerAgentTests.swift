//
//  ServerAgentTests.swift
//  
//
//  Created by Igor Malyarov on 02.09.2023.
//

import ServerAgent
import XCTest

final class ServerAgentTests: XCTestCase {
    
    func test_init() {
        
        _ = ServerAgent(
            baseURL: "",
            encoder: .init(),
            decoder: .init(),
            logError: { _ in },
            logMessage: { _ in },
            sendAction: { _ in }
        )
    }
    
    func test_requestCreationError() {
        let error = NSError(domain: "Request error", code: 1)
        let serverError = ServerAgentError.requestCreationError(error)
        
        XCTAssertEqual(serverError.errorDescription, "Server: request creation failed with error: \(error.localizedDescription)")
    }
    
    func test_sessionError() {
        let error = NSError(domain: "Session error", code: 2)
        let serverError = ServerAgentError.sessionError(error)
        
        XCTAssertEqual(serverError.errorDescription, "\(error.localizedDescription)")
    }
    
    func test_emptyResponse() {
        let serverError = ServerAgentError.emptyResponse
        
        XCTAssertEqual(serverError.errorDescription, "Server: unexpected empty response")
    }
    
    func test_emptyResponseData() {
        let serverError = ServerAgentError.emptyResponseData
        
        XCTAssertEqual(serverError.errorDescription, "Server: unexpected empty response data")
    }
    
    func test_unexpectedResponseStatus() {
        let statusCode = 404
        let serverError = ServerAgentError.unexpectedResponseStatus(statusCode)
        
        XCTAssertEqual(serverError.errorDescription, "Server: unexpected response status code: \(statusCode)")
    }
    
    func test_corruptedData() {
        let error = NSError(domain: "Data error", code: 3)
        let serverError = ServerAgentError.corruptedData(error)
        
        XCTAssertEqual(serverError.errorDescription, "Server: data corrupted: \(error.localizedDescription)")
    }
    
    func test_serverStatus_withMessage() {
        let statusCode: ServerStatusCode = .userNotAuthorized
        let message = "Session expired"
        let serverError = ServerAgentError.serverStatus(statusCode, errorMessage: message)
        
        XCTAssertEqual(serverError.errorDescription, "Server: status: \(statusCode) \(message)")
    }
    
    func test_serverStatus_withoutMessage() {
        let statusCode: ServerStatusCode = .serverError
        let serverError = ServerAgentError.serverStatus(statusCode, errorMessage: nil)
        
        XCTAssertEqual(serverError.errorDescription, "Server: status: \(statusCode)")
    }
    
    func test_notAuthorized() {
        let serverError = ServerAgentError.notAuthorized
        
        XCTAssertEqual(serverError.errorDescription, "Not Authorized")
    }
}
