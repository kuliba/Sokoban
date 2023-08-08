//
//  TestHelpers.swift
//  
//
//  Created by Igor Malyarov on 07.08.2023.
//

import Foundation

func anyError(
    _ domain: String = "any error",
    _ code: Int = 0
) -> Error {
    
    NSError(domain: domain, code: code)
}

func anyData() -> Data {
    
    .init()
}

func anyHTTPURLResponse(
    with statusCode: Int
) -> HTTPURLResponse {
    
    .init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}

func anyURL(string: String = "any.url") -> URL {
    
    .init(string: string)!
}
