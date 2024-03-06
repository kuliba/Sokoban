//
//  ProductDetails.swift
//
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import Foundation

public enum ProductDetails: Equatable {
    
    case accountDetails(AccountDetails)
    case cardDetails(CardDetails)
    case depositDetails(DepositDetails)
}
