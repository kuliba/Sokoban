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
    
    struct GetCardOrderPayload {
        
        let name: String
        
        public init(name: String) {
            self.name = name
        }
    }
    
    static func createGetCardOrderFormRequest(
        url: URL,
        payload: GetCardOrderPayload
    ) throws -> URLRequest {
        
        //        let url = try url.appendingQueryItems(parameters: payload.parameters)
        return createEmptyRequest(.get, with: url)
    }
}

extension RequestFactory.GetCardOrderPayload {
    
    var parameters: [String: String] {
        
        get throws {
            
            [
                "name": String(name)
            ]
        }
    }
}
