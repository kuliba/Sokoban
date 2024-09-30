//
//  ResponseMapper+mapGetNotAuthorizedZoneClientInformData.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 27.09.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapGetNotAuthorizedZoneClientInformDataResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<GetNotAuthorizedZoneClientInformDataResponse> {
        
        map(data, httpURLResponse, mapOrThrow: GetNotAuthorizedZoneClientInformDataResponse.init)
    }
}

private extension ResponseMapper.GetNotAuthorizedZoneClientInformDataResponse {
    
    init(_ data: ResponseMapper._Data) throws {
        
        self.init(
            list: data.notAuthorized.map(ResponseMapper.NotAuthorized.init),
            serial: data.serial
        )
    }
}

private extension ResponseMapper.NotAuthorized {
    
    init(_ notAuthorizedData: ResponseMapper._Data._NotAuthorized) {
        
        self.init(
            authBlocking: notAuthorizedData.authBlocking,
            title: notAuthorizedData.title,
            text: notAuthorizedData.text,
            update: .init(notAuthorizedData.update)
        )
    }

}

private extension ResponseMapper.NotAuthorized.Update {
    
    init(_ updateData: ResponseMapper._Data._Update) {
        
        self.init(
            action: updateData.action,
            platform: updateData.platform,
            version: updateData.version,
            link: updateData.link
        )
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let serial: String
        let notAuthorized: [_NotAuthorized]
        
        public struct _NotAuthorized: Decodable {

            let authBlocking: Bool
            let title: String
            let text: String
            let update: _Update
        }
        
        public struct _Update: Decodable {
            let action: String
            let platform: String
            let version: String
            let link: String
        }
    }
}
