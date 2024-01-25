//
//  Bank.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

import Tagged

public struct Bank: Equatable, Identifiable {
    
    public let id: BankID
    public let name: String
    
    public init(id: BankID, name: String) {
        
        self.id = id
        self.name = name
    }
    
    public typealias BankID = Tagged<_BankID, String>
    public enum _BankID {}
}
