//
//  SubscriptionEvent.swift
//
//
//  Created by Igor Malyarov on 25.01.2024.
//

import C2BSubscriptionUI

public typealias GetC2BSubResult = Result<GetC2BSubResponse, ServiceFailure>

public enum SubscriptionEvent: Equatable {
    
    case getC2BSubButtonTapped
    case loaded(GetC2BSubResult)
    
}
