//
//  RemoteService+Fetcher.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.11.2023.
//

import Fetcher
import GenericRemoteService

extension RemoteService: Fetcher {
    
    public typealias Payload = Input
    public typealias Success = Output
    public typealias Failure = RemoteServiceError<CreateRequestError, PerformRequestError, MapResponseError>
    
    public func fetch(
        _ payload: Input,
        completion: @escaping FetchCompletion
    ) {
        process(payload, completion: completion)
    }
}
