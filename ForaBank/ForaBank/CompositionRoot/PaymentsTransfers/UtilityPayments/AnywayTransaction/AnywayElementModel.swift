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
    
    struct Parameter {
        
        let origin: Origin
        let type: ParameterType
        
        typealias Origin = AnywayElement.UIComponent.Parameter

        enum ParameterType {
         
            case hidden
            case nonEditable
            case numberInput(ObservingInputViewModel)
            case select(ObservingSelectorViewModel)
            case textInput(ObservingInputViewModel)
            case unknown
        }
    }
    
    enum Widget {
        
        case info(Info)
        case product(ObservingProductSelectViewModel)
        case otp(OTPViewModel)
        case simpleOTP(SimpleOTPViewModel)
    }
}

extension AnywayElementModel.Widget {
    
    struct Info: Equatable {
        
        let fields: [Field]
        
        enum Field: Equatable {
            
            case amount(String)
            case fee(String)
            case total(String)
        }
    }
    
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
