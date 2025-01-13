//
//  RxInputViewModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 07.06.2024.
//

import AnywayPaymentDomain
import PaymentComponents
import RxViewModel

typealias RxInputViewModel = RxViewModel<TextInputState, TextInputEvent, TextInputEffect>

typealias RxCheckboxViewModel = RxViewModel<CheckboxState, CheckboxEvent, CheckboxEffect>

struct CheckboxState: Equatable {
    
    var isChecked: Bool
    let text: String
}

enum CheckboxEvent: Equatable {

    case toggle
}

enum CheckboxEffect: Equatable {}
