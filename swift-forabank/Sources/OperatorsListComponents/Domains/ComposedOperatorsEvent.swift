//
//  ComposedOperatorsEvent.swift
//
//
//  Created by Дмитрий Савушкин on 19.02.2024.
//

import Foundation

public enum ComposedOperatorsEvent {

    case selectLastOperation(LatestPayment.ID)
    case selectOperator(Operator.ID)
    case didScroll(Operator)
}
