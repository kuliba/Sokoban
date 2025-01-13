//
//  ModelToViewModelMapper.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation

public struct ModelToViewModelMapper {
    
    let action: (Event) -> Void
    
    public init(
        action: @escaping (Event) -> Void
    ) {
        self.action = action
    }
}

public extension ModelToViewModelMapper {
    
    func map(
        _ operation: Operation?,
        _ parameter: Operation.Parameter
    ) -> ParameterViewModel {
        
        switch parameter {
        case let .sticker(parameter):
            return .sticker(.init(parameter: parameter))
            
        case let .tip(parameter):
            return .tip(.init(parameter: parameter))
            
        case let .select(parameter):
            return .select(
                .init(
                    parameter: parameter,
                    tapAction: {
                        tapSelectAction(
                            operation: operation,
                            parameter: parameter
                        )
                    },
                    select: { option in
                        
                        action(.select(.selectOption(option, parameter)))
                    },
                    search: { text in
                        
                        action(.select(.search(text, parameter)))
                    }
                )
            )
            
        case let .productSelector(parameter):
            return .product(
                .init(
                    state: parameter.parameterState,
                    chevronTapped: {
                        
                        action(.product(.chevronTapped(parameter, parameter.state == .list ? .select : .list)))
                        
                    }, selectOption: { option in
                        
                        let option = parameter.allProducts.first(where: { $0.id == option.id })
                        action(.product(.selectProduct(option, parameter)))
                    }
                )
            )
            
        case let .amount(parameter):
            return .amount(
                .init(
                    parameter: parameter,
                    isCompleteOperation: operation?.isOperationComplete ?? false,
                    continueButtonTapped: {
                        action(.continueButtonTapped(.getCode))
                    }
                ))
            
        case let .input(input):
            return .input(
                value: input.value,
                title: input.title.rawValue,
                warning: input.warning
            )
        }
    }
}

extension ModelToViewModelMapper {
    
    func tapSelectAction(
        operation: Operation?,
        parameter: Operation.Parameter.Select
    ) -> Void {
        
        switch parameter.id {
        case .citySelector:
            return action(.select(.chevronTapped(parameter)))
            
        case .officeSelector:
            var location: Location = .init(id: "")
            let cityID = operation?.parameters.first(where: { $0.id == .city })
            switch cityID {
            case let .select(city):
                if let value = city.value {
                    
                    location = .init(id: value)
                }
                
            default:
                break
            }
            
            return action(.select(.openBranch(location)))
            
        default:
            return action(.select(.chevronTapped(parameter)))
        }
    }
}
