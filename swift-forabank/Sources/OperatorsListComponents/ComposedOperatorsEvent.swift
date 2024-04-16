//
//  ComposedOperatorsEvent.swift
//
//
//  Created by Дмитрий Савушкин on 19.02.2024.
//

import Foundation
import PrePaymentPicker

public enum ComposedOperatorsEvent: Equatable {

    case selectLastOperation(LatestPayment)
    case selectOperator(Operator)
    
    case utility(PrePaymentOptionsEvent<LatestPayment, Operator>)
}
