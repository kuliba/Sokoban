//
//  anyHTTPURLResponse.swift
//
//
//  Created by Igor Malyarov on 16.10.2023.
//

import Foundation

func anyHTTPURLResponse(
    statusCode: Int = 200,
    url: URL = anyURL()
) -> HTTPURLResponse {
    
    .init(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}
