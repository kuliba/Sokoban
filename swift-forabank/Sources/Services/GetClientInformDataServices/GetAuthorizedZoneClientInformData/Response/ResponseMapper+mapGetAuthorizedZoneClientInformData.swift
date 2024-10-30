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
        
        guard let authorized = data.authorized,
              let serial = data.serial
        else { throw ResponseFailure() }

        self.init(
            list: authorized.compactMap(ResponseMapper.GetAuthorizedZoneClientInformData.init),
            serial: serial
        )
    }
    
    struct ResponseFailure: Error {}
}

private extension ResponseMapper.GetAuthorizedZoneClientInformData {
    
    init?(_ authorizedData: ResponseMapper._Data._Authorized) {
        
        guard let category = authorizedData.category,
              let title = authorizedData.title,
              let svgImage = authorizedData.svgImage,
              let text = authorizedData.text
        else { return nil }
        
        self.init(
            category: category,
            title: title,
            svgImage: svgImage,
            text: text
        )
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {

        let serial: String?
        let authorized: [_Authorized]?

        struct _Authorized: Decodable {

            let category: String?
            let title: String?
            let svgImage: String?
            let text: String?
        }
    }
}
