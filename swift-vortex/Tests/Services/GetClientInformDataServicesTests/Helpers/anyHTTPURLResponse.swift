//
//  anyHTTPURLResponse.swift
//  Vortex
//
//  Created by Nikolay Pochekuev on 30.09.2024.
//

import Foundation

func anyHTTPURLResponse(
    statusCode: Int = 200,
    url: URL = anyURL()
) -> HTTPURLResponse {
    
    .init(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}
