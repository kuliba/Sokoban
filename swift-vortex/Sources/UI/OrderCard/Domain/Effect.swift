//
//  Effect.swift
//  
//
//  Created by Дмитрий Савушкин on 09.12.2024.
//

import Foundation

public enum Effect: Equatable {
    
    case load
    case loadConfirmation
    case orderCard(OrderCardPayload)
}
