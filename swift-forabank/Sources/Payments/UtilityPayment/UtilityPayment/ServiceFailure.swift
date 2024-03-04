//
//  ServiceFailure.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

public enum ServiceFailure: Error, Equatable {
    
    case connectivityError
    case serverError(String)
}
