//
//  anyHTTPURLResponse.swift
//
//
//  Created by Valentin Ozerov on 23.10.2024.
//

import Foundation

func anyHTTPURLResponse(
    statusCode: Int = 200,
    url: URL = anyURL()
) -> HTTPURLResponse {
    
    .init(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}
