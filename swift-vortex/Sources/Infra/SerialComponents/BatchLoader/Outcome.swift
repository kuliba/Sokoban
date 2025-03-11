//
//  Outcome.swift
//
//
//  Created by Igor Malyarov on 10.03.2025.
//

import VortexTools

public struct Outcome<Payload, Response>
where Payload: Hashable {
    
    public let storage: [Payload: Response]
    public let failed: [Payload]
    
    public init(
        storage: [Payload: Response],
        failed: [Payload]
    ) {
        self.storage = storage
        self.failed = failed
    }
}

extension Outcome: Equatable where Response: Equatable {}
