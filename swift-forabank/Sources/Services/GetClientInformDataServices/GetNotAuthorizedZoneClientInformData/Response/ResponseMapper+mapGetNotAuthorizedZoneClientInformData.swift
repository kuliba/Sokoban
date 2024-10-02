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
        
        map(data, httpURLResponse, mapOrThrow: ResponseMapper.GetNotAuthorizedZoneClientInformDataResponse.init(data:))
    }
}

private extension ResponseMapper.GetNotAuthorizedZoneClientInformDataResponse {
    
    init(data: ResponseMapper._Data) throws {
        
        guard let notAuthorized = data.notAuthorized,
              let serial = data.serial 
        else { throw ResponseFailure() }

        self.init(
            list: notAuthorized.compactMap(ResponseMapper.NotAuthorized.init),
            serial: serial
        )
    }
    
    struct ResponseFailure: Error {}
}

private extension ResponseMapper.NotAuthorized {
    
    init?(_ data: ResponseMapper._Data._NotAuthorized) {
        
        guard let authBlocking = data.authBlocking,
              let title = data.title,
              let text = data.text 
        else { return nil }
        
        self.init(
            authBlocking: authBlocking,
            title: title,
            text: text,
            update: data.update.flatMap { .init($0) }
        )
    }
}

private extension ResponseMapper.NotAuthorized.Update {
    
    init?(_ updateData: ResponseMapper._Data._Update) {

        guard let action = updateData.action,
              let platform = updateData.platform,
              platform == "iOS",
              let version = updateData.version,
              let link = updateData.link
        else {
            return nil
        }
        
        self.init(
            action: action,
            platform: platform,
            version: version,
            link: link
        )
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let serial: String?
        let notAuthorized: [_NotAuthorized]?
        
        struct _NotAuthorized: Decodable {

            let authBlocking: Bool?
            let title: String?
            let text: String?
            let update: _Update?
        }
        
        struct _Update: Decodable {
            
            let action: String?
            let platform: String?
            let version: String?
            let link: String?
        }
    }
}
