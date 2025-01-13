//
//  anyHTTPURLResponse.swift
//  
//
//  Created by Andryusina Nataly on 05.03.2024.
//

import Foundation

func anyHTTPURLResponse(
    statusCode: Int = 200,
    url: URL = anyURL()
) -> HTTPURLResponse {
    
    .init(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}
