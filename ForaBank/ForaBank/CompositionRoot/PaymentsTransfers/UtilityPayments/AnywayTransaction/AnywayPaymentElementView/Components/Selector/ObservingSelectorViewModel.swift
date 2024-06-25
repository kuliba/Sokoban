//
//  ObservingSelectorViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.06.2024.
//

import AnywayPaymentDomain
import RxViewModel

typealias ObservingSelectorViewModel = RxObservingViewModel<SelectingParameter, SelectorEvent<SelectingParameter.Option>, Never>

struct SelectingParameter {
 
    let title: String
    let image: AnywayElement.UIComponent.Image?
    let selector: Selector<Option>
    
    typealias Option = AnywayElement.UIComponent.Parameter.ParameterType.Option
}
