//
//  Bank+ext.swift
//
//
//  Created by Igor Malyarov on 31.12.2023.
//

import FastPaymentsSettings

extension Bank {
    
    static let a: Self = .init(id: "a", name: "A")
    static let b: Self = .init(id: "b", name: "B")
    static let c: Self = .init(id: "c", name: "C")
    static let d: Self = .init(id: "d", name: "D")
    
    private init(id: Bank.BankID, name: String) {
        
        self.init(id: id, name: name, image: .init(""))
    }
}

