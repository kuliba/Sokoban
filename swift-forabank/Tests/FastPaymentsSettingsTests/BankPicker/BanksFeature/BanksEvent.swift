//
//  BanksEvent.swift
//
//
//  Created by Igor Malyarov on 31.12.2023.
//

import FastPaymentsSettings

enum BanksEvent: Equatable {
    
    case applySelection(Set<Bank.ID>)
}
