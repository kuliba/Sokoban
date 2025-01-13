//
//  anyPhoneNumber.swift
//  
//
//  Created by Igor Malyarov on 30.12.2023.
//

import FastPaymentsSettings
import Foundation

func anyPhoneNumber(
    _ value: String = UUID().uuidString
) -> PhoneNumber {
    
    .init(value)
}
