//
//  ResponseMapper+mapGetProductDynamicParamsList.swift
//
//
//  Created by Andryusina Nataly on 24.01.2024.
//

import Foundation

public extension ResponseMapper {
    
    typealias GetProductDynamicParamsListResult = Result<DynamicParamsList, MappingError>

    static func mapGetProductDynamicParamsList(
        _ data: Data,
        _ response: HTTPURLResponse
    ) -> GetProductDynamicParamsListResult {
        
        map(data, response, mapOrThrow: map)
    }
    
    private static func map(
        _ data: _Data
    ) throws -> DynamicParamsList {
        
        .init(data: data)
    }
}

private extension ResponseMapper._Data {
    
    
}

private extension ResponseMapper {
    
    typealias _Data = _DTO
}

private extension ResponseMapper {
    
    struct _DTO: Decodable {
        
    }
}

private extension DynamicParamsList {
    
    init(
        data: ResponseMapper._Data
    ) {
        fatalError("unimplemented")
    }
}
