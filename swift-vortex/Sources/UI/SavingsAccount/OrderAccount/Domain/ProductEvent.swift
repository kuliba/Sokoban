//
//  ProductEvent.swift
//
//
//  Created by Andryusina Nataly on 20.02.2025.
//

import Foundation
import LoadableState
import PaymentComponents

public enum ProductEvent<Confirmation> {
    
    case `continue`
    case amount(AmountEvent)
    case dismissInformer
    case goToMain
    case cancel
    case load
    case loadConfirmation(LoadConfirmationResult<Confirmation>)
    case loaded(LoadFormResult<Confirmation>)
    case orderAccountResult(OrderAccountResult)
    case otp(String)
    case productSelect(ProductSelectEvent)
    case setConsent(Bool)
    case setMessages(Bool)
    
    public typealias OrderAccountResult = Result<OrderAccountResponse, LoadFailure>
}
