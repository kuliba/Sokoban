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
                    //TODO: extract to extension Image
                    sticker: parameterSticker.image,
                    options: parameterSticker.options.map {
                        
                        .init(
                            title: $0.title,
                            icon: ImageData.named("Arrow Circle"),
                            description: "\($0.description.dropLast(2)) ₽",
                            iconColor: ""
                        )
                    }
                )
            )
            
        case let .tip(parameterHint):
            return .tip(
                .init(
                    text: parameterHint.title
                )
            )
            
        case let .select(parameter):
            
            let icon: Image
            let tapAction: () -> Void
            
            switch parameter.id {
            case .citySelector:
                tapAction = { action(.select(.chevronTapped(parameter))) }
                
                // TODO: extract name icons to configuration view
                icon = .init("ic24MapPin")
                
            case .officeSelector:
                tapAction = { action(.select(.openBranch(.init(id: "")))) }
                icon = .init("ic24Bank")
                
            default:
                tapAction = { action(.select(.chevronTapped(parameter))) }
                icon = .init("ic24ArrowDownCircle")
            }
            
            return .select(
                .init(
                    parameter: parameter,
                    icon: icon,
                    tapAction: tapAction,
                    select: { option in
                        
                        action(.select(.selectOption(option, parameter)))
                    }
                )
            )
            
        case let .productSelector(parameterProduct):
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
                        action(.continueButtonTapped(.getOTPCode))
                    }
                ))
            
        case let .input(input):
            return .input(.init(
                parameter: input,
                icon: .init("ic24SmsCode"),
                updateValue: { text in
                    
                    action(.input(.valueUpdate(.init(value: text, title: input.title))))
                    
                }
            ))
        }
    }
}
