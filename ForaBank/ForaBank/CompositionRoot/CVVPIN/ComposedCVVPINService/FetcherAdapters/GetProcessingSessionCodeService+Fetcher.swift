//
//  GetProcessingSessionCodeService+Fetcher.swift
//  ForaBank
//
//  Created by Igor Malyarov on 06.11.2023.
//

import CVVPIN_Services
import Fetcher
import Foundation

extension GetProcessingSessionCodeService: Fetcher {
        
    public typealias Payload = Void
    public typealias Success = Response
    public typealias Failure = Error
    
    public func fetch(
        _ payload: Void,
        completion: @escaping FetchCompletion
    ) {
        getCode(completion: completion)
    }
}
