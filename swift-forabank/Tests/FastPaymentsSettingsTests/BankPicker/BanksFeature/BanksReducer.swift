//
//  BanksReducer.swift
//
//
//  Created by Igor Malyarov on 31.12.2023.
//

import FastPaymentsSettings

final class BanksReducer {
    
    private let applySelection: ApplySelection
    
    init(applySelection: @escaping ApplySelection) {
        
        self.applySelection = applySelection
    }
}

extension BanksReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> State {
        
        switch event {
        case let .applySelection(bankIDs):
            applySelection(bankIDs)
            return state
        }
    }
}

extension BanksReducer {
    
    typealias ApplySelection = (Set<Bank.ID>) -> Void
    
    typealias State = Banks
    typealias Event = BanksEvent
}
