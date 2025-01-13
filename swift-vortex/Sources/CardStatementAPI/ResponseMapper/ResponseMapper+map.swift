//
//  ResponseMapper+map.swift
//
//
//  Created by Andryusina Nataly on 24.01.2024.
//

import Foundation
// TODO: use generic `map` from Utilities/RemoteServices
internal extension ResponseMapper {
    
    /// Generic map.
    static func map<D: Decodable, T>(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse,
        mapOrThrow: (D) throws -> T
    ) -> Result<T, MappingError> {
        
        map(data, httpURLResponse) { (data: D?) in
            
            guard let data else { throw InvalidResponse() }
            
            return try mapOrThrow(data)
        }
    }
    
    /// Generic map.
    static func map<D: Decodable, T>(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse,
        mapOrThrow: (D?) throws -> T
    ) -> Result<T, MappingError> {
        
        do {
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.iso8601)
            let response = try decoder.decode(_Response<D>.self, from: data)
            
            switch (httpURLResponse.statusCode, response.errorMessage, response.data) {
            case let (200, .none, data):
                return try .success(mapOrThrow(data))
                
            case let (_, .some(errorMessage), .none):
                return .failure(.not200Status(errorMessage))
                
            default:
                throw InvalidResponse()
            }
            
        } catch {
            print("error \(error)")
            return .failure(.mappingFailure(.defaultErrorMessage))
        }
    }
    
    private struct InvalidResponse: Error {}
    
    private struct _Response<T: Decodable>: Decodable {
        
        let statusCode: Int
        let errorMessage: String?
        let data: T?
    }
}
