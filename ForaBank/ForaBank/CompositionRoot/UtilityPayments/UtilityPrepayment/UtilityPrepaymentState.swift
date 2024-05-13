//
//  UtilityPrepaymentState.swift
//  
//
//  Created by Igor Malyarov on 09.05.2024.
//

import OperatorsListComponents

typealias UtilityPrepaymentState = ComposedOperatorsState<OperatorsListComponents.LastPayment, OperatorsListComponents.Operator<String>>
