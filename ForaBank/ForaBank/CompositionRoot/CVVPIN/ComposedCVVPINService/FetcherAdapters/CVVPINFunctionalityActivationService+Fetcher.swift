//
//  CVVPINFunctionalityActivationService+Fetcher.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.11.2023.
//

import CVVPIN_Services
import Fetcher

extension CVVPINFunctionalityActivationService: Fetcher {
    
    public typealias Payload = OTP
    public typealias Success = Void
    public typealias Failure = ConfirmError
    
    public func fetch(
        _ payload: OTP,
        completion: @escaping FetchCompletion
    ) {
        confirmActivation(withOTP: payload, completion: completion)
    }
    
    
}
