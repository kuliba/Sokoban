//
//  TestHelpers.swift
//  VortexTests
//
//  Created by Igor Malyarov on 05.08.2023.
//

import Foundation

func anyURLRequest(url: URL = anyURL()) -> URLRequest {
    
    .init(url: url)
}

func anyError(
    _ domain: String = "any error",
    _ code: Int = 0
) -> Error {
    
    NSError(domain: domain, code: code)
}

func anyHTTPURLResponse(
    with statusCode: Int = 200
) -> HTTPURLResponse {
    
    .init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}

func anyURL(string: String = UUID().uuidString) -> URL {
    
    .init(string: string)!
}
