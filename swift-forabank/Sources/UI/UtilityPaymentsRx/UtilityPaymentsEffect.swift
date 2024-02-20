//
//  UtilityPaymentsEffect.swift
//
//
//  Created by Igor Malyarov on 19.02.2024.
//

public enum UtilityPaymentsEffect: Equatable {
    
    case initiate
    case paginate
    case search(String)
}
