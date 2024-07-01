//
//  ResponseMapper+map.swift
//
//
//  Created by Andryusina Nataly on 13.02.2024.
//

import Foundation

public extension ResponseMapper {
    
    typealias MappingResult<T> = Result<T, MappingError>
    
    /// Generic map.
    static func map<D: Decodable, T>(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil,
        file: StaticString = #file,
        line: Int = #line,
        mapOrThrow: (D) throws -> T
    ) -> MappingResult<T> {
        
        map(data, httpURLResponse, dateDecodingStrategy: dateDecodingStrategy, file: file, line: line) { (data: D?) in
            
            guard let data else { throw InvalidResponse() }
            
            return try mapOrThrow(data)
        }
    }
    
    /// Generic map.
    static func map<D: Decodable, T>(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil,
        file: StaticString = #file,
        line: Int = #line,
        mapOrThrow: (D?) throws -> T
    ) -> MappingResult<T> {
        
        do {
            
            let decoder = JSONDecoder()
            
            if let dateDecodingStrategy {
                
                decoder.dateDecodingStrategy = dateDecodingStrategy
            }
            
            let response = try decoder.decode(_Response<D>.self, from: data)
            
            switch (httpURLResponse.statusCode, response.errorMessage, response.data) {
            case let (200, .none, data):
                return try .success(mapOrThrow(data))
                
            case let (_, .some(errorMessage), .none):
                return .failure(.server(
                    statusCode: response.statusCode,
                    errorMessage: errorMessage
                ))
                
            default:
                throw InvalidResponse()
            }
            
        } catch {
            #if DEBUG
            customDump(error, file: file, line: line)
            #endif
            return .failure(.invalid(
                statusCode: httpURLResponse.statusCode,
                data: data
            ))
        }
    }
    
    private struct InvalidResponse: Error {}
    
    private struct _Response<T: Decodable>: Decodable {
        
        let statusCode: Int
        let errorMessage: String?
        let data: T?
    }
}

#if DEBUG
private func customDump<T>(
    _ value: T,
    file: StaticString = #file,
    line: Int = #line
) {
    print("Dump from \(file):\(line)")
    dump(value)
}
#endif
