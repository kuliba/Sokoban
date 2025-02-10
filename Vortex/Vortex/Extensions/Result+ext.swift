//
//  Result+ext.swift
//  Vortex
//
//  Created by Igor Malyarov on 08.02.2025.
//

extension Result {
    
    var failure: Failure? {
        
        guard case let .failure(failure) = self else { return nil }
        
        return failure
    }
    
    var success: Success? {
        
        guard case let .success(success) = self else { return nil }
        
        return success
    }
}
