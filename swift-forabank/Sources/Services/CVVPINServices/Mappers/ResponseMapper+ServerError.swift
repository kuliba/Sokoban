//
//  ResponseMapper+ServerError.swift
//  
//
//  Created by Igor Malyarov on 15.10.2023.
//

extension ResponseMapper {
    
    struct ServerError: Decodable {
        
        let statusCode: Int
        let errorMessage: String
        
        init(
            statusCode: Int,
            errorMessage: String
        ) {
            self.statusCode = statusCode
            self.errorMessage = errorMessage
        }
    }
}
