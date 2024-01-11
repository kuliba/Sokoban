//
//  anyDefaultBank.swift
//
//
//  Created by Igor Malyarov on 30.12.2023.
//

import FastPaymentsSettings
import Foundation

func anyDefaultBank(
    _ value: Bool = .random()
) -> DefaultBank {
    
    .init(value)
}
