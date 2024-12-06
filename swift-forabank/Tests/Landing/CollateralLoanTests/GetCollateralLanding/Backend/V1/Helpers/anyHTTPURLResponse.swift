//
//  anyHTTPURLResponse.swift
//  
//
//  Created by Valentin Ozerov on 29.11.2024.
//

import Foundation

func anyHTTPURLResponse(
    statusCode: Int = 200,
    url: URL = anyURL()
) -> HTTPURLResponse {
    
    .init(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}
