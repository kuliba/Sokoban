//
//  Event.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation

public enum Event {
    
    public typealias ParameterProduct = Operation.Parameter.ProductSelector
    public typealias ProductOption = ParameterProduct.Product
    public typealias ParameterSelect = Operation.Parameter.Select
    public typealias SelectOptionID = ParameterSelect.State.OptionsListViewModel.OptionViewModel
    public typealias ParameterInput = Operation.Parameter.Input

    case product(ProductEvent)
    case select(SelectEvent)
    case continueButtonTapped(ContinueEvent)
    case input(InputEvent)
    
    public enum ContinueEvent {
    
        case `continue`
        case getOTPCode
        case makeTransfer
    }
    
    public enum InputEvent {
        
        case valueUpdate(String)
        case getOtpCode
    }
    
    public enum ProductEvent {
        
        case chevronTapped(ParameterProduct, ParameterProduct.State)
        case selectProduct(ProductOption, ParameterProduct)
    }
    
    public enum SelectEvent {
        
        case selectOption(SelectOptionID, ParameterSelect)
        case chevronTapped(ParameterSelect)
        case openBranch(Location)
    }
    
    public struct Location {
        
        public let id: String
    }
}
