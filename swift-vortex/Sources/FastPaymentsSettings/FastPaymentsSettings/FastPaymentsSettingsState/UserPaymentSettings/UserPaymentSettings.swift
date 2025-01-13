//
//  UserPaymentSettings.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import Tagged

public enum UserPaymentSettings: Equatable {
    
    case contracted(Details)
    case missingContract(ConsentListState)
}
