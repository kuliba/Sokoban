//
//  SelectingReducer.swift
//  
//
//  Created by Andryusina Nataly on 11.06.2023.
//

import Foundation

struct SelectingReducer: Reducer {
        
    typealias Options = [SubscriptionType: [OptionWithMapImage]]
    
    let options: Options
        
    func reduce(
        _ state: ComponentState,
        action: ComponentAction
    ) -> ComponentState {
        
        switch action {
        case let .selectSubscriptionType(subscriptionType):
            
            switch (state, subscriptionType) {
                
            case (.monthly, .yearly):
                
                guard let options = options[.yearly],
                      let selection = options.first
                else { return state }
                
                return .yearly(.init(selection: selection, options: options))
                
            case (.yearly, .monthly):
                
                guard let options = options[.monthly],
                      let selection = options.first
                else { return state}
                
                return .monthly(.init(selection: selection, options: options))
                
            case (.monthly, .monthly), (.yearly, .yearly):
                return state
            }
            
        case let .selectOption(option):
            
            switch state {
            case let .monthly(selectionWithOptions):
                
                if selectionWithOptions.options.contains(option) {
                    
                    return .monthly(.init(selection: option, options: selectionWithOptions.options))
                } else {
                    
                    guard let firstOption = selectionWithOptions.options.first
                    else { return state }
                    
                    return .monthly(.init(selection: firstOption, options: selectionWithOptions.options))
                }
                
            case let .yearly(selectionWithOptions):
                
                if selectionWithOptions.options.contains(option) {
                    
                    return .yearly(.init(selection: option, options: selectionWithOptions.options))
                } else {
                    
                    guard let firstOption = selectionWithOptions.options.first
                    else { return state }
                    
                    return .yearly(.init(selection: firstOption, options: selectionWithOptions.options))
                }
            }
        }
    }
}
