//
//  ChangePINService+Fetcher.swift
//  Vortex
//
//  Created by Igor Malyarov on 06.11.2023.
//

import CVVPIN_Services
import Fetcher
import Foundation

extension ChangePINService: Fetcher {
    
    public typealias Payload = Void
    public typealias Success = ConfirmResponse
    public typealias Failure = GetPINConfirmationCodeError
    
    public func fetch(
        _ payload: Void,
        completion: @escaping FetchCompletion
    ) {
        getPINConfirmationCode(completion: completion)
    }
}
