//
//  Details.swift
//  
//
//  Created by Andryusina Nataly on 05.03.2024.
//

import Foundation

public enum Details: Equatable {
    
    case accountDetails(AccountDetails)
    case cardDetails(CardDetails)
    case depositDetails(DepositDetails)
}
