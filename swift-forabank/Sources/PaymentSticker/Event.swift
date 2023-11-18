//
//  Event.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation

public enum Event {
    
    public typealias ParameterProduct = Operation.Parameter.Product
    public typealias ProductOption = ParameterProduct.Option
    public typealias ParameterSelect = Operation.Parameter.Select
    public typealias SelectOptionID = ParameterSelect.State.OptionsListViewModel.OptionViewModel.ID
    public typealias ParameterInput = Operation.Parameter.Input

    
    case product(ProductEvent)
    case select(SelectEvent)
    case continueButtonTapped
    case input(InputEvent)
    
    public enum InputEvent {
        
        case valueUpdate(ParameterInput)
        case getOtpCode
    }
    
    public enum ProductEvent {
        
        case chevronTapped(ParameterProduct, ParameterProduct.State)
        case selectProduct(ProductOption, ParameterProduct)
    }
    
    public enum SelectEvent {
        
        case selectOption(SelectOptionID, ParameterSelect)
        case chevronTapped(ParameterSelect)
        case openBranch
    }
}
