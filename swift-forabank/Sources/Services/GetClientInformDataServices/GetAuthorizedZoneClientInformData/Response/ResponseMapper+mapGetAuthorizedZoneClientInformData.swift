//
//  ResponseMapper+mapGetAuthorizedZoneClientInformData.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 27.09.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapGetAuthorizedZoneClientInformDataResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<GetAuthorizedZoneClientInformDataResponse> {
        
        map(data, httpURLResponse, mapOrThrow: GetAuthorizedZoneClientInformDataResponse.init)
    }

}

private extension ResponseMapper.GetAuthorizedZoneClientInformDataResponse {
    
    init(_ data: ResponseMapper._Data) throws {
        
        self.init(
            list: data.authorized.map(ResponseMapper.Authorized.init),
            serial: data.serial
        )
    }
}

private extension ResponseMapper.Authorized {
    
    init(_ authorizedData: ResponseMapper._Data._Authorized) {
        
        self.init(
            category: authorizedData.category,
            title: authorizedData.title,
            svg_image: authorizedData.svg_image,
            text: authorizedData.text
        )
           
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let serial: String
        let authorized: [_Authorized]

        struct _Authorized: Decodable {
            let category: String
            let title: String
            let svg_image: String
            let text: String
        }
    }
}
