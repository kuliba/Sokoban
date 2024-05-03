//
//  RootActions.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

struct RootActions {
    
    let spinner: Spinner
    
    struct Spinner {
        
        let hide: () -> Void
        let show: () -> Void
    }
}

