//
//  AnywayElementModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.06.2024.
//

import AnywayPaymentDomain
import Foundation
import PaymentComponents
import RxViewModel

enum AnywayElementModel {
    
    case field(AnywayElement.UIComponent.Field)
    case parameter(Parameter)
    case widget(Widget)
}

extension AnywayElementModel {
    
    enum Parameter {
        
        case hidden(AnywayElement.UIComponent.Parameter)
        case nonEditable(AnywayElement.UIComponent.Parameter)
        case numberInput(ObservingInputViewModel)
        case select(ObservingSelectorViewModel)
        case textInput(ObservingInputViewModel)
        case unknown(AnywayElement.UIComponent.Parameter)
        
        typealias Option = AnywayElement.UIComponent.Parameter.ParameterType.Option
    }
    
    enum Widget {
        
        case product(ObservingProductSelectViewModel)
        case otp(OTPViewModel)
        case simpleOTP(SimpleOTPViewModel)
    }
}

extension AnywayElementModel.Widget {
    
    typealias OTPViewModel = TimedOTPInputViewModel
    typealias SimpleOTPViewModel = RxObservingViewModel<OTPState, OTPEvent, OTPEffect>
    
    struct OTPState: Equatable {
        
        let value: Int?
    }
    
    enum OTPEvent: Equatable {
        
        case input(String)
    }
    
    enum OTPEffect: Equatable {}
}
