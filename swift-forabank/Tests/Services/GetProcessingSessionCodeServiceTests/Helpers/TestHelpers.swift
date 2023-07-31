//
//  TestHelpers.swift
//  
//
//  Created by Igor Malyarov on 31.07.2023.
//

import Foundation

func anyHTTPURLResponse(
    with statusCode: Int
) -> HTTPURLResponse {
    
    .init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}

func anyURL(string: String = "any.url") -> URL {
    
    .init(string: string)!
}
