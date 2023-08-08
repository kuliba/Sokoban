//
//  CvvPinFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2023.
//

import CvvPin
import Foundation
import GenericRemoteService

enum CvvPinFactory {}

extension CvvPinFactory {
    
    // TODO: Move to the Composition Root
    static func cvvPinService(
        httpClient: HTTPClient
    ) -> CvvPinService {
        
        let sessionCodeLoader = Services.getProcessingSessionCode(
            httpClient: httpClient
        )
        
        let symmetricKeyService = Services.symmetricKeyService(
            httpClient: httpClient
        )
        
        let bindPublicKeyService = Services.makeBindPublicKeyService()
        
        return .init(
            getProcessingSessionCode: sessionCodeLoader.load,
            symmetricKeyService: symmetricKeyService,
            bindPublicKey: bindPublicKeyService.get
        )
    }
}
