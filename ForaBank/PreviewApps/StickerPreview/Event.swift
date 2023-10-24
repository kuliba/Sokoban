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
        
        case chevronTapped(ParameterProduct)
        case selectProduct(ProductOption, ParameterProduct)
    }
    
    enum SelectEvent {
        
        case chevronTapped(ParameterSelect)
        case filterOptions(ParameterSelect, [ParameterSelect.Option])
        case selectOption(SelectOptionID, ParameterSelect)
        case openBranch
    }
}

// (разбить на методы) (синхронизация инпута) (реализовать makeTransfer, makeOTP)
// 2.
