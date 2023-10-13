//
//  URLRequestFactory+Service.swift
//  
//
//  Created by Igor Malyarov on 12.10.2023.
//

public extension URLRequestFactory {
    
    enum Service {
        
        case bindPublicKeyWithEventID(BindPublicKeyWithEventIDPayload)
        case changePIN(ChangePINPayload)
        case formSessionKey(FormSessionKeyPayload)
        case getPINConfirmationCode(SessionIDWithDataPayload.SessionID)
        case getProcessingSessionCode
        case processPublicKeyAuthenticationRequest(ProcessPublicKeyAuthenticationRequestPayload)
        case showCVV(ShowCVVPayload)
    }
}
