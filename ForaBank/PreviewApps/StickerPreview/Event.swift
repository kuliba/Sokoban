//
//  Event.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation

enum Event {
    
    typealias ParameterProduct = Operation.Parameter.Product
    typealias ProductOption = ParameterProduct.Option
    typealias ParameterSelect = Operation.Parameter.Select
    typealias SelectOptionID = ParameterSelect.State.OptionsListViewModel.OptionViewModel.ID
    typealias ParameterInput = Operation.Parameter.Input

    
    case product(ProductEvent)
    case select(SelectEvent)
    case continueButtonTapped
    case input(InputEvent)
    
    enum InputEvent {
        
        case valueUpdate(ParameterInput)
        case getOtpCode
    }
    
    enum ProductEvent {
        
        case chevronTapped(ParameterProduct, ParameterProduct.State)
        case selectProduct(ProductOption, ParameterProduct)
    }
    
    enum SelectEvent {
        
        case selectOption(SelectOptionID, ParameterSelect)
        case openBranch
    }
}
