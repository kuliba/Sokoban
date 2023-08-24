//
//  Model+cvvPinService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2023.
//

import CvvPin

extension Model {
    
    // TODO: Move to the Composition Root
    func cvvPinService() -> CvvPinService {
        
        Services.cvvPinService(
            httpClient: authenticatedHTTPClient()
        )
    }
}
