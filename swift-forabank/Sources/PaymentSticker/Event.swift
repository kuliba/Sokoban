//
//  Event.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation

public enum Event: Equatable {
    
    public typealias ParameterProduct = Operation.Parameter.ProductSelector
    public typealias ProductOption = ParameterProduct.Product
    public typealias ParameterSelect = Operation.Parameter.Select
    public typealias SelectOptionID = ParameterSelect.State.OptionsListViewModel.OptionViewModel
    public typealias ParameterInput = Operation.Parameter.Input

    case product(ProductEvent)
    case select(SelectEvent)
    case continueButtonTapped(ContinueEvent)
    case input(InputEvent)
    
    public enum ContinueEvent: Hashable {
    
        case `continue`
        case getCode
        case makeTransfer
    }
    
    public enum InputEvent: Hashable {
        
        case valueUpdate(String)
        case getCode
    }
    
    public enum ProductEvent: Hashable {
        
        case chevronTapped(ParameterProduct, ParameterProduct.State)
        case selectProduct(ProductOption?, ParameterProduct)
    }
    
    public enum SelectEvent: Hashable {
        
        case selectOption(SelectOptionID, ParameterSelect)
        case chevronTapped(ParameterSelect)
        case openBranch(Location)
        case search(String, ParameterSelect)
    }
}
