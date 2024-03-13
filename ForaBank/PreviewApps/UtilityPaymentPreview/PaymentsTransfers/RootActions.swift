//
//  RootActions.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 13.03.2024.
//

struct RootActions {
    #warning("add tab switching")
    let spinner: Spinner
    
    struct Spinner {
        
        let hide: () -> Void
        let show: () -> Void
    }
}
