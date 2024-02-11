//
//  C2BSubscriptionState.swift
//
//
//  Created by Igor Malyarov on 11.02.2024.
//

import TextFieldDomain
import UIPrimitives

public struct C2BSubscriptionState {
    
    public let getC2BSubResponse: GetC2BSubResponse
    public var textFieldState: TextFieldState
    public var status: Status?
    
    public init(
        getC2BSubResponse: GetC2BSubResponse,
        textFieldState: TextFieldState = .placeholder("Поиск"),
        status: Status? = nil
    ) {
        self.getC2BSubResponse = getC2BSubResponse
        self.textFieldState = textFieldState
        self.status = status
    }
}

public extension C2BSubscriptionState {
    
    enum Status: Equatable {
        
        case failure(ServiceFailure)
        case inflight
        case tapAlert(TapAlert)
        case cancelled(CancelC2BSubscriptionConfirmation)
        case detail(C2BSubscriptionDetail)
    }
    
    typealias TapAlert = AlertModelOf<C2BSubscriptionEvent.AlertEvent>
}
