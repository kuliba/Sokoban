//
//  PaymentsTransfersFlowManager+preview.swift
//  Vortex
//
//  Created by Igor Malyarov on 09.05.2024.
//

import OperatorsListComponents

extension PaymentsTransfersFlowManager {
    
    static var preview: Self {
        
        return .init(
            handleEffect: { _,_ in },
            makeReduce: { _,_ in  { state,_ in (state, nil) }}
        )
    }
}
