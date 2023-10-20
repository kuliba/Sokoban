//
//  Event.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation

enum Event {
    
    typealias ParameterProduct = Operation.Parameter.Product
    typealias ParameterSelect = Operation.Parameter.Select
    typealias SelectOptionID = ParameterSelect.State.OptionsListViewModel.OptionViewModel.ID
    
    case product(ParameterProduct)
    case select(SelectEvent)
    case continueButtonTapped
    
    enum SelectEvent {
        
        case chevronTapped(ParameterSelect)
        case selectOption(SelectOptionID, ParameterSelect)
    }
}
