//
//  anyHTTPURLResponse.swift
//  swift-forabank
//
//  Created by Valentin Ozerov on 08.10.2024.
//

import Foundation

func anyHTTPURLResponse(
    statusCode: Int = 200,
    url: URL = anyURL()
) -> HTTPURLResponse {
    
    .init(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}
