//
//  RootViewDomain.ContentWitnesses+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 18.11.2024.
//

import Combine

extension RootViewDomain.ContentWitnesses {
    
    init(isFlagActive: Bool) {
        
        self.init(
            emitting: {
            
                if isFlagActive {
                    $0.rootEventPublisher
                } else {
                    Empty().eraseToAnyPublisher()
                }
            },
            receiving: { _ in {}}
        )
    }
}
