//
//  TransactionCompleteViewConfig.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.06.2024.
//

import SharedConfigs
import SwiftUI

struct TransactionCompleteViewConfig: Equatable {
    
    let amountConfig: TextConfig
    let statuses: Statuses
    let logoHeight: CGFloat
    
    struct Statuses: Equatable {
        
        let completed: Status
        let inflight: Status
        let rejected: Status
        let fraud: Status
        
        struct Status: Equatable {
            
            let icon: Icon
            let message: String
            let messageConfig: TextConfig
            
            struct Icon: Equatable {
                
                let image: Image
                let color: Color
            }
        }
    }
}
