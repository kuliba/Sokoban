//
//  ObservingSelectorViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.06.2024.
//

import AnywayPaymentDomain
import OptionalSelectorComponent
import RxViewModel

typealias ObservingSelectorViewModel = RxObservingViewModel<OptionalSelectorState<AnywayElement.UIComponent.Parameter.ParameterType.Option>, OptionalSelectorEvent<AnywayElement.UIComponent.Parameter.ParameterType.Option>, OptionalSelectorEffect>
