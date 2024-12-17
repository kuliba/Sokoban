//
//  FraudPaymentCompleteViewConfig.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.06.2024.
//

import SharedConfigs
import SwiftUI

struct FraudPaymentCompleteViewConfig: Equatable {
    
    let amountConfig: TextConfig
    let iconColor: Color
    let message: String
    let messageConfig: TextConfig
    let reason: String
    let reasonConfig: TextConfig
}
