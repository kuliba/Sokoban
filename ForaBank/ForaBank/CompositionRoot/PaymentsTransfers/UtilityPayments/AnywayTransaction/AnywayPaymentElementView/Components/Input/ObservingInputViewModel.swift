//
//  ObservingInputViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.06.2024.
//

import PaymentComponents
import RxViewModel

typealias ObservingInputViewModel = RxObservingViewModel<InputState<String>, InputEvent, Never>
