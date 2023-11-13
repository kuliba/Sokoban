//
//  AuthenticateWithPublicKeyService+Fetcher.swift
//  ForaBank
//
//  Created by Igor Malyarov on 06.11.2023.
//

import CVVPIN_Services
import Fetcher

extension AuthenticateWithPublicKeyService: Fetcher {
    
    public typealias Payload = Void
    public typealias Failure = AuthenticateWithPublicKeyService.Error
    
    public func fetch(
        _ payload: Void,
        completion: @escaping FetchCompletion
    ) {
        authenticateWithPublicKey(completion: completion)
    }
}
