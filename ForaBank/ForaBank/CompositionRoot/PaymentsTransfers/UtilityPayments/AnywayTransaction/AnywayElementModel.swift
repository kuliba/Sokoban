//
//  AnywayElementModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.06.2024.
//

import AnywayPaymentDomain

enum AnywayElementModel {
    
    case field(AnywayElement.UIComponent.Field)
    case parameter(AnywayElement.UIComponent.Parameter)
    case widget(Widget)
}

extension AnywayElementModel {
    
    enum Widget: Equatable {
        
        case core(AnywayElement.Widget.PaymentCore)
        case otp(Int?)
    }
}
