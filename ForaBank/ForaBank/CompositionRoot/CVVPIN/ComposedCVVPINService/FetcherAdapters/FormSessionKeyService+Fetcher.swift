//
//  FormSessionKeyService+Fetcher.swift
//  Vortex
//
//  Created by Igor Malyarov on 06.11.2023.
//

import CVVPIN_Services
import Fetcher
import Foundation

extension FormSessionKeyService: Fetcher {

    public typealias Payload = Code
    public typealias Failure = Error
    
    public func fetch(
        _ payload: Payload,
        completion: @escaping FetchCompletion
    ) {
        formSessionKey(payload, completion: completion)
    }
}
