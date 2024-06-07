//
//  AnywayElementModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.06.2024.
//

import AnywayPaymentDomain
import Foundation
import RxViewModel

enum AnywayElementModel {
    
    case field(AnywayElement.UIComponent.Field)
    case parameter(AnywayElement.UIComponent.Parameter)
    case widget(Widget)
}

extension AnywayElementModel {
    
    enum Widget {
        
        case core(ObservingProductSelectViewModel, Decimal, String)
        case otp(OTPViewModel)
    }
}

extension AnywayElementModel.Widget {
    
    typealias OTPViewModel = RxObservingViewModel<OTPState, OTPEvent, OTPEffect>
    
    struct OTPState: Equatable {
        
        let value: Int?
    }
    
    enum OTPEvent: Equatable {
        
        case input(String)
    }
    
    enum OTPEffect: Equatable {}
}
