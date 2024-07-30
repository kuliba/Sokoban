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
    let title: TextConfig
    let subtitle: TextConfig
    let logoHeight: CGFloat
    
    struct Icon: Equatable {
        
        let foregroundColor: Color
        let backgroundColor: Color
        let innerSize: CGSize
        let outerSize: CGSize
    }
}
