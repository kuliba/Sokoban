//
//  ComposedOperatorsEvent.swift
//
//
//  Created by Дмитрий Савушкин on 19.02.2024.
//

import Foundation
import PrePaymentPicker

public enum ComposedOperatorsEvent {

    case selectLastOperation(LatestPayment.ID)
    case selectOperator(Operator.ID)
    
    case utility(PrePaymentOptionsEvent<LatestPayment, Operator>)
}
