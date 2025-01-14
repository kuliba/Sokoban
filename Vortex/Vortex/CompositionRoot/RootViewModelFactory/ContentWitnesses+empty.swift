//
//  ContentWitnesses+empty.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.01.2025.
//

import Combine

extension ContentWitnesses {
    
    static var empty: Self {
        
        return .init(
            emitting: { _ in Empty() },
            dismissing: { _ in {}}
        )
    }
}
