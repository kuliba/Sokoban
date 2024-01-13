//
//  ConsentListReducer.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

import Foundation

final class ConsentListReducer {
    
    private let availableBanks: [Bank]
    
    init(availableBanks: [Bank]) {
        
        self.availableBanks = availableBanks
    }
}

extension ConsentListReducer {
    
    func reduce(
        _ state: State,
        _ event: Event,
        _ completion: @escaping (State) -> Void
    ) {
        switch event {
        case .toggle:
            toggle(state, completion)
            
        case let .search(text):
            search(text, state, completion)
            
        case let .tapBank(bankID):
            tapBank(bankID, state, completion)
            
        case .apply:
            apply(state, completion)
        }
    }
    
    private func toggle(
        _ state: State,
        _ completion: @escaping (State) -> Void
    ) {
        switch state {
        case .collapsed:
            fatalError()
            
        case let .expanded(expanded):
            completion(.collapsed(.init(
                bankNames: expanded.banks.filter(\.isSelected).map(\.name)
            )))
            
        case .collapsedError:
            completion(.expandedError)
            
        case .expandedError:
            completion(.collapsedError)
        }
    }
    
    private func search(
        _ text: String,
        _ state: State,
        _ completion: @escaping (State) -> Void
    ) {
        fatalError()
    }
    
    private func tapBank(
        _ bankID: Bank.ID,
        _ state: State,
        _ completion: @escaping (State) -> Void
    ) {
        switch state {
        case .collapsed:
            completion(state)
            
        case let .expanded(expanded):
#warning("extract to helper or subscript")
            guard let index = expanded.banks.firstIndex(where: { $0.id == bankID })
            else {
                completion(state)
                return
            }
            
            var expanded = expanded
            expanded.banks[index].isSelected.toggle()
            
#warning("add button `Apply`")
            
            completion(.expanded(expanded))
            
        case .collapsedError:
            completion(state)
            
        case .expandedError:
            completion(state)
        }
    }
    
    private func apply(
        _ state: State,
        _ completion: @escaping (State) -> Void
    ) {
        switch state {
        case .collapsed:
            completion(state)
            
        case .expanded:
            fatalError()
            
        case .collapsedError:
            completion(state)
            
        case .expandedError:
            completion(state)
        }
    }
}

extension ConsentListReducer {
    
    typealias State = ConsentListState
    typealias Event = ConsentListEvent
}
