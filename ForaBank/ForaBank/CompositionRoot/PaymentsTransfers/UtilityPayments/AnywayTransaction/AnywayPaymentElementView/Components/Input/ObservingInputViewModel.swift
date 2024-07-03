//
//  ObservingInputViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.06.2024.
//

import AnywayPaymentDomain
import PaymentComponents
import RxViewModel

typealias ObservingInputViewModel = RxObservingViewModel<InputState<AnywayElement.UIComponent.Icon?>, InputEvent, Never>
