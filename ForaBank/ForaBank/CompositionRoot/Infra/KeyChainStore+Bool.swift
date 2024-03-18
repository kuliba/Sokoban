//
//  KeyChainStore+Bool.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.02.2024.
//

import Foundation
import KeyChainStore

extension KeyChainStore
where Key == Bool {
    
    convenience init(keyTag: KeyTag) {
        
        self.init(
            keyTag: keyTag,
            data: {
                
                try JSONEncoder().encode(Wrapper(value: $0))
            },
            key: {
                
                let activation = try JSONDecoder().decode(Wrapper.self, from: $0)
                
                return activation.value
            }
        )
    }
    
    private struct Wrapper: Codable {
        
        let value: Bool
    }
}
