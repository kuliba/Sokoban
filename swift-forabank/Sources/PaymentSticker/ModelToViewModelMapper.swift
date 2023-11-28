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
        case let .sticker(parameterSticker):
            
            return .sticker(
                .init(
                    header: .init(
                        title: parameterSticker.title,
                        detailTitle: parameterSticker.description
                    ),
                    sticker: .named("StickerPreview"),
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
            
            let icon: ImageData
            let tapAction: () -> Void
            
            switch parameter.id {
            case .citySelector:
                tapAction = { action(.select(.chevronTapped(parameter))) }
                icon = .named("ic24MapPin")
                
            case .officeSelector:
                var location: Event.Location = .init(id: "")
                
                let cityID = operation?.parameters.first(where: { $0.id == .city })
                switch cityID {
                case let .select(city):
                    if let value = city.value {
                        
                        location = .init(id: value)
                    }
                    
                default:
                    break
                }
                
                tapAction = { action(.select(.openBranch(location))) }
                icon = .named("ic24Bank")
                
            default:
                tapAction = { action(.select(.chevronTapped(parameter))) }
                icon = .named("ic24ArrowDownCircle")
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
                        
                        let option = parameterProduct.allProducts.first(where: { $0.id == option.id })
                        action(.product(.selectProduct(option, parameterProduct)))
                    }
                )
            )
            
        case let .amount(parameter):
            return .amount(
                .init(
                    parameter: parameter,
                    continueButtonTapped: {
                        action(.continueButtonTapped(.getOTPCode))
                    }
                ))
            
        case let .input(input):
            return .input(
                value: input.value,
                title: input.title,
                warning: input.warning
            )
        }
    }
}
