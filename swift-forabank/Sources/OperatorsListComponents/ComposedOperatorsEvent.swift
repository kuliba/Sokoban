//
//  ComposedOperatorsEvent.swift
//
//
//  Created by Дмитрий Савушкин on 19.02.2024.
//

import Foundation
import PrePaymentPicker

public enum ComposedOperatorsEvent<LastPayment, Operator>
where LastPayment: Identifiable,
      Operator: Identifiable {
    
    case selectLastOperation(LastPayment)
    case selectOperator(Operator)
    
    case utility(PrePaymentOptionsEvent<LastPayment, Operator>)
}

extension ComposedOperatorsEvent: Equatable where LastPayment: Equatable, Operator: Equatable {}
