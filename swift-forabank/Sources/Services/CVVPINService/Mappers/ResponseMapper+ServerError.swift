//
//  ResponseMapper+ServerError.swift
//  
//
//  Created by Igor Malyarov on 15.10.2023.
//

extension ResponseMapper {
    
    public struct ServerError: Decodable {
        
        public let statusCode: Int
        public let errorMessage: String
        
        public init(
            statusCode: Int,
            errorMessage: String
        ) {
            self.statusCode = statusCode
            self.errorMessage = errorMessage
        }
    }
}
