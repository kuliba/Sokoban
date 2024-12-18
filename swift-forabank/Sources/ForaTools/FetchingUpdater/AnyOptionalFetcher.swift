//
//  AnyOptionalFetcher.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

import Combine

public struct AnyOptionalFetcher<Payload, T> {
    
    private let _fetch: Fetch
    
    public init(fetch: @escaping Fetch) {
        
        self._fetch = fetch
    }
    
    public typealias Fetch = (Payload, @escaping (T?) -> Void) -> Void
}

extension AnyOptionalFetcher: OptionalFetcher {
    
    public func fetch(
        _ payload: Payload,
        completion: @escaping (T?) -> Void
    ) {
        _fetch(payload, completion)
    }
}
