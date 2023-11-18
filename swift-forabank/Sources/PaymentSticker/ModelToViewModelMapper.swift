//
//  ModelToViewModelMapper.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation
import SwiftUI

public struct ModelToViewModelMapper {
    
    let action: (Event) -> Void
}

public extension ModelToViewModelMapper {
    
    func map(
        _ parameter: Operation.Parameter
    ) -> ParameterViewModel {
        
        switch parameter {
        case let .sticker(parameterSticker):
            
            return .sticker(
                .init(
                    header: .init(
                        title: parameterSticker.title,
                        detailTitle: parameterSticker.description
                    ),
                    options: parameterSticker.options.map {
                        
                        .init(
                            title: $0.title,
                            icon: .init("Arrow Circle"),
                            description: $0.description,
                            iconColor: .green
                        )
                    }
                )
            )
            
        case let .tip(parameterHint):
            return .tip(
                .init(
                    imageName: "message",
                    text: parameterHint.title
                )
            )
            
        case let .select(parameter):
            return .select(
                .init(
                    parameter: parameter,
                    chevronButtonTapped: {
                        
                        action(.select(.chevronTapped(parameter)))
                    },
                    select: { option in
                        
                        action(.select(.selectOption(option, parameter)))
                    }
                )
            )
            
        case let .product(parameterProduct):
            return .product(
                .init(
                    state: parameterProduct.parameterState,
                    chevronTapped: {
                        
                        action(.product(.chevronTapped(parameterProduct, .list)))
                    }, selectOption: { option in
                        
                        action(.product(.selectProduct(option, parameterProduct)))
                    }
                )
            )
            
        case let .amount(amountViewModel):
            return .amount(
                .init(
                    parameter: amountViewModel,
                    continueButtonTapped: {
                        action(.continueButtonTapped)
                    }
                ))
            
        case let .input(input):
            return .input(.init(parameter: input))
        }
    }
}
