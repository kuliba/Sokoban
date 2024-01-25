//
//  SubscriptionEvent.swift
//
//
//  Created by Igor Malyarov on 25.01.2024.
//

public extension FastPaymentsSettingsEvent {
    
    typealias GetC2BSubResult = Result<GetC2BSubResponse, ServiceFailure>

    enum SubscriptionEvent: Equatable {
        
        case getC2BSubButtonTapped
        case loaded(GetC2BSubResult)
    }
}
