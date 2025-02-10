//
//  GetCardOrderFormRequest.swift
//
//
//  Created by Дмитрий Савушкин on 11.12.2024.
//

import Foundation
import RemoteServices
import VortexTools

public extension RequestFactory {
    
    static func createGetCardOrderFormRequest(
        url: URL
    ) throws -> URLRequest {
        
        return createEmptyRequest(.get, with: url)
    }
}
