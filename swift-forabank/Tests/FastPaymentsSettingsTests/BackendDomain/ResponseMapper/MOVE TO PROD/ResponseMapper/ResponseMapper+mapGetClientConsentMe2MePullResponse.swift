//
//  ResponseMapper+mapGetClientConsentMe2MePullResponse.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import FastPaymentsSettings
import Foundation

extension ResponseMapper {
    
    typealias GetClientConsentMe2MePullResult = Result<[ConsentMe2MePull], MappingError>
    
    static func mapGetClientConsentMe2MePullResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> GetClientConsentMe2MePullResult {
        
        map(data, httpURLResponse, mapOrThrow: map)
    }
    
    private static func map(
        _ data: _Data
    ) throws -> [ConsentMe2MePull] {
        
        data.consentList.map(\.consent)
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let consentList: [_DTO]
    }
}

private extension ResponseMapper._DTO {
    
    var consent: ConsentMe2MePull {
        
        .init(
            consentID: consentId,
            bankID: bankId,
            beginDate: beginDate,
            endDate: endDate,
            active: active,
            oneTimeConsent: oneTimeConsent
        )
    }
}

private extension ResponseMapper {
    
    struct _DTO: Decodable {
        
        let consentId: Int
        let bankId: String
        let beginDate: String
        let endDate: String
        let active: Bool?
        let oneTimeConsent: Bool?
    }
}
