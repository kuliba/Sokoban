//
//  URLRequestFactory+Service.swift
//  
//
//  Created by Igor Malyarov on 12.10.2023.
//

import Foundation

public extension URLRequestFactory {
    
    enum Service {
        
#warning("instead of BindPublicKeyWithEventIDPayload use typealias to `SessionIDWithDataPayload` as in `ChangePINPayload` and `ShowCVVPayload`")
        case bindPublicKeyWithEventID(BindPublicKeyWithEventIDPayload)
        case changePIN(ChangePINPayload)
        case formSessionKey(FormSessionKeyPayload)
        case getPINConfirmationCode(SessionIDWithDataPayload.SessionID)
        case getProcessingSessionCode
        case processPublicKeyAuthenticationRequest(Data)
        case showCVV(ShowCVVPayload)
    }
}
