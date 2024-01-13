//
//  Bank.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

import Tagged

struct Bank: Equatable, Identifiable {
    
    let id: BankID
    let name: String
    
    typealias BankID = Tagged<_BankID, String>
    enum _BankID {}
}
