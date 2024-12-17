//
//  Store+deleteCacheIgnoringResult.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.11.2023.
//

extension Store {
    
    func deleteCacheIgnoringResult() {
        
        self.deleteCache { _ in }
    }
}
