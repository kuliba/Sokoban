//
//  ResponseMapper+mapCreateCardApplicationResponse.swift
//
//
//  Created by Дмитрий Савушкин on 27.01.2025.
//

import Foundation
import RemoteServices

public typealias ResponseMapper = RemoteServices.ResponseMapper

public extension ResponseMapper {
    
    static func mapCreateCardApplicationResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<CreateCardApplicationResponse> {
        
        map(
            data, httpURLResponse,
            mapOrThrow: map
        )
    }
    
    private static func map(
        _ data: _Data
    ) throws -> CreateCardApplicationResponse {
        
        try data.getOrderCardLanding()
    }
    
    private struct InvalidResponse: Error {}
}

private extension ResponseMapper._Data {
    
    func getOrderCardLanding() throws
    -> CreateCardApplicationResponse {
        
        guard let requestId,
              let status else {
            throw ResponseMapper.InvalidResponse()
        }
        
        return .init(
            requestId: requestId,
            status: status
        )
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let requestId: String?
        let status: String?
    }
}
