//
//  AnywayElementModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 07.06.2024.
//

import AnywayPaymentDomain
import Combine
import Foundation
import PaymentComponents
import RxViewModel

enum AnywayElementModel {
    
    case field(AnywayElement.UIComponent.Field)
    case parameter(Parameter)
    case widget(Widget)
    case withContacts(WithContacts)
}

extension AnywayElementModel {
    
    typealias Origin = AnywayElement.UIComponent.Parameter
    
    struct Parameter {
        
        let origin: Origin
        let type: ParameterType
        
        enum ParameterType {
            
            case checkbox(Node<RxCheckboxViewModel>)
            case hidden
            case nonEditable(Node<RxInputViewModel>)
            case numberInput(Node<RxInputViewModel>)
            case select(ObservingSelectorViewModel)
            case textInput(Node<RxInputViewModel>)
            case unknown
        }
    }
    
    enum Widget {
        
        case info(Info)
        case product(ObservingProductSelectViewModel)
        case otp(OTPViewModel)
        case simpleOTP(SimpleOTPViewModel)
    }
    
    struct WithContacts {
        
        let origin: Origin
        let input: Node<RxInputViewModel>
        let contacts: ContactsViewModel
        private let bindings: Set<AnyCancellable>
        
        init(
            origin: Origin,
            input: Node<RxInputViewModel>,
            contacts: ContactsViewModel,
            bindings: Set<AnyCancellable>
        ) {
            self.origin = origin
            self.input = input
            self.contacts = contacts
            self.bindings = bindings
        }
    }
    
    typealias Contact = ContactsViewModel
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
