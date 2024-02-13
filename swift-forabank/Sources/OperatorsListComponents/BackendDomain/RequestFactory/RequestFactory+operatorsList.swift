//
//  File.swift
//  
//
//  Created by Дмитрий Савушкин on 13.02.2024.
//

import Foundation

public extension RequestFactory {
        
    static func getAnywayOperatorsListRequest(
        url: URL
    ) throws -> URLRequest {
        
        var request = createEmptyRequest(.get, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
}
