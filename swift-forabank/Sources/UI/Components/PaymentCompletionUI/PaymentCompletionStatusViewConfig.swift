//
//  PaymentCompletionStatusViewConfig.swift
//
//
//  Created by Igor Malyarov on 30.07.2024.
//

import SharedConfigs
import SwiftUI

struct PaymentCompletionStatusViewConfig: Equatable {
    
    let amount: TextConfig
    let icon: Icon
    let logoHeight: CGFloat
    let title: TextConfig
    let subtitle: TextConfig
    
    struct Icon: Equatable {
        
        let foregroundColor: Color
        let backgroundColor: Color
        let innerSize: CGSize
        let outerSize: CGSize
    }
}
