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
    let icons: Icons
    let message: String
    let messageConfig: TextConfig
    let logoHeight: CGFloat

    struct Icons: Equatable {
        
        let completed: Icon
        let inflight: Icon
        let rejected: Icon
        let fraud: Icon
        
        struct Icon: Equatable {
            
            let image: Image
            let color: Color
        }
    }
}
