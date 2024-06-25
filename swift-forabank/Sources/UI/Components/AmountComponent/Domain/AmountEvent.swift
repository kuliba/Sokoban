//
//  AmountEvent.swift
//  
//
//  Created by Igor Malyarov on 08.06.2024.
//

import Foundation

public enum AmountEvent: Equatable {
    
    case edit(Decimal)
    case pay
}
