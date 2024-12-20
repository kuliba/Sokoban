//
//  ResponseMapper+mapBlockCardResponse.swift
//
//
//  Created by Andryusina Nataly on 12.02.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapBlockCardResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<BlockUnblockData?> {
        
        map(data, httpURLResponse, mapOrThrow: map)
    }
    
    private static func map(
        _ data: _DTO
    ) throws -> BlockUnblockData? {
        
        data.data
    }
}

private extension ResponseMapper._DTO {
    
    var data: BlockUnblockData? {
                
        return .init(
            statusBrief: statusBrief ?? "",
            statusDescription: statusDescription ?? "")
    }
}

private extension ResponseMapper {
    
    struct _DTO: Decodable {
        
        let statusDescription: String?
        let statusBrief: String?
    }
}
