//
//  TestHelpers.swift
//
//
//  Created by Igor Malyarov on 16.05.2024.
//

import Foundation

struct Output: Equatable {
    
    let value: String
    
    init(_ value: String = UUID().uuidString) {
        
        self.value = value
    }
}

struct CreateRequestError: Error {
    
    let message: String
    
    init(_ message: String = UUID().uuidString) {
        
        self.message = message
    }
}

struct PerformRequestError: Error {
    
    let message: String
    
    init(_ message: String = UUID().uuidString) {
        
        self.message = message
    }
}

struct MapResponseError: Error {
    
    let message: String
    
    init(_ message: String = UUID().uuidString) {
        
        self.message = message
    }
}

enum ServerResponse<Response: Equatable>: Equatable {
    
    case response(Response)
    case error(ServerError)
    
    struct ServerError: Equatable {
        
        let statusCode: Int
        let errorMessage: String
    }
}

func anyRequest(
    _ url: URL = anyURL()
) -> URLRequest {
    
    .init(url: url)
}

func anyURL(
    _ urlString: String = UUID().uuidString
) -> URL {
    
    .init(string: urlString)!
}

func successResponse(
    _ string: String = UUID().uuidString
) -> (Data, HTTPURLResponse) {
    
    return (
        makeSuccessResponseData(string),
        makeHTTPURLResponse(statusCode: statusCodeOK)
    )
}

func makeSuccessResponseData(
    _ string: String = UUID().uuidString
) -> Data {
    
    .init(string.utf8)
}

func makeHTTPURLResponse(
    statusCode: Int
) -> HTTPURLResponse {
    
    .init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}

let statusCodeOK = 200
let statusCode500 = 500
