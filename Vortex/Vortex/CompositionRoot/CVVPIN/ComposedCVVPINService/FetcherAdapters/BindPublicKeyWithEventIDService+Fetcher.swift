//
//  BindPublicKeyWithEventIDService+Fetcher.swift
//  ForaBank
//
//  Created by Igor Malyarov on 06.11.2023.
//

import CVVPIN_Services
import Fetcher
import Foundation

extension CVVPIN_Services.BindPublicKeyWithEventIDService: Fetcher {
    
    public typealias Payload = CVVPIN_Services.BindPublicKeyWithEventIDService.OTP
    public typealias Success = Void
    public typealias Failure = Error
    
    public func fetch(
        _ payload: Payload,
        completion: @escaping FetchCompletion
    ) {
        bind(with: payload, completion: completion)
    }
}
