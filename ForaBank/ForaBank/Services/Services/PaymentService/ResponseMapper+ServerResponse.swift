//
//  ResponseMapper+ServerResponse.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2023.
//

import Foundation

extension ResponseMapper {
 
    struct ServerResponse<T: Decodable>: Decodable {
        
        let statusCode: Int
        let errorMessage: String?
        let data: T?
    }
}
