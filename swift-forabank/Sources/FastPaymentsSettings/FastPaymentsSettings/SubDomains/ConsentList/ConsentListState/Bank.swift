//
//  Bank.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

import SwiftUI
import Tagged

public struct Bank: Equatable, Identifiable {
    
    public let id: BankID
    public let name: String
    public let image: Image
    
    public init(
        id: BankID, 
        name: String,
        image: Image
    ) {
        self.id = id
        self.name = name
        self.image = image
    }
    
    public typealias BankID = Tagged<_BankID, String>
    public enum _BankID {}
}
