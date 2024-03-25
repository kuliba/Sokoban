//
//  ResponseMapper+mapToVoid.swift
//
//
//  Created by Andryusina Nataly on 13.02.2024.
//

import Foundation

public extension ResponseMapper {
    
    typealias VoidMappingResult = MappingResult<Void>
    
    static func mapToVoid(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> VoidMappingResult {
        
        map(data, httpURLResponse, mapOrThrow: map)
    }
    
    private static func map(
        _ data: _Data
    ) throws -> Void {
        
        if data != nil { throw InvalidResponse() }
    }
    
    private struct InvalidResponse: Error {}
    
    private typealias _Data = Data?
}
