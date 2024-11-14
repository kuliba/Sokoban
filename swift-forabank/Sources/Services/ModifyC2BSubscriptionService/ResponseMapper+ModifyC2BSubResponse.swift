//
//  ResponseMapper+ModifyC2BSubResponse.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 07.11.2024.
//

import Foundation
import RemoteServices

extension ResponseMapper {
    
    static func mapModifyC2BSubscriptionResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> RemoteServices.ResponseMapper.MappingResult<C2BSubscriptionData?> {
        
        map(data, httpURLResponse, mapOrThrow: mapModifyC2B)
    }
    
    private static func mapModifyC2B(
        _ data: _Data
    ) throws -> C2BSubscriptionData? {
        
        .init(data: data.data)
    }
}

private extension ResponseMapper {
    
    typealias _Data = _DTO
}

private extension ResponseMapper {
    
    struct _DTO: Decodable {
        
        let statusCode: Int
        let errorMessage: String?
        let data: C2BSubscriptionCodable
    }
    
    struct C2BSubscriptionCodable: Decodable {
        
        let operationStatus: Status
        let title: String
        let brandIcon: String
        let brandName: String
        let legalName: String?
        let redirectUrl: URL?
    }
}

private extension C2BSubscriptionData {
    
    init(data: ResponseMapper.C2BSubscriptionCodable) {
        
        self.operationStatus = .init(rawValue: data.operationStatus.rawValue) ?? .unknown
        self.title = data.title
        self.brandIcon = data.brandIcon
        self.brandName = data.brandName
        self.legalName = data.legalName
        self.redirectUrl = data.redirectUrl
    }
}
