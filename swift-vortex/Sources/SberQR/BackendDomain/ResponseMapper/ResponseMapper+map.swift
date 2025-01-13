//
//  ResponseMapper+map.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

import Foundation
// TODO: use generic `map` from Utilities/RemoteServices
public extension ResponseMapper {
    
    /// Generic map.
    static func map<D: Decodable, T>(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse,
        map: (D) throws -> T
    ) -> Result<T, MappingError> {
        
        do {
            
            let response = try JSONDecoder().decode(_Response<D>.self, from: data)
            
            switch (httpURLResponse.statusCode, response.errorMessage, response.data) {
            case let (200, .none, .some(data)):
                return try .success(map(data))
                
            case let (_, .some(errorMessage), .none):
                return .failure(.server(
                    statusCode: response.statusCode,
                    errorMessage: errorMessage
                ))
                
            default:
                throw InvalidResponseError()
            }
            
        } catch {
            return .failure(.invalid(
                statusCode: httpURLResponse.statusCode, 
                data: data
            ))
        }
    }
    
    private struct InvalidResponseError: Error {}
    
    private struct _Response<T: Decodable>: Decodable {
        
        let statusCode: Int
        let errorMessage: String?
        let data: T?
    }
}
