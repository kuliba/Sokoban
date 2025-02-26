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
    case load
    case loaded(LoadFormResult<Confirmation>)
    case loadConfirmation(LoadConfirmationResult<Confirmation>)
    case setMessages(Bool)
    case orderAccountResult(OrderAccountResult)
    case otp(String)
    case setConsent(Bool)
    case productSelect(ProductSelectEvent)

    public typealias OrderAccountResult = Result<OrderAccountResponse, LoadFailure>
}
