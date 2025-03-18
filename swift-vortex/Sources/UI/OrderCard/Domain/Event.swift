//
//  Event.swift
//
//
//  Created by Дмитрий Савушкин on 09.12.2024.
//

import Foundation
import SelectorComponent

public enum Event<Confirmation> {
    
    case `continue`
    case dismissInformer
    case load
    case loaded(LoadFormResult<Confirmation>)
    case loadConfirmation(LoadConfirmationResult<Confirmation>)
    case setMessages(Bool)
    case orderCardResult(OrderCardResult)
    case otp(String)
    case setConsent(Bool)
    case selector(SelectorEvent<Product>)
    
    public typealias OrderCardResult = Result<OrderCardResponse, LoadFailure>
}
