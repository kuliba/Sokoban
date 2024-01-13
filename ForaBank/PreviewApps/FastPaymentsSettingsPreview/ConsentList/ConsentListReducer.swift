//
//  ConsentListReducer.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

import Foundation

final class ConsentListReducer {
    
    private let availableBanks: [Bank]
    private let changeConsentList: ChangeConsentList
    
    init(
        availableBanks: [Bank],
        changeConsentList: @escaping ChangeConsentList
    ) {
        self.availableBanks = availableBanks
        self.changeConsentList = changeConsentList
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
#warning("this is super-simplified logic for showing `Apply`button")
            expanded.canApply = true
            
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
            
        case let .expanded(expanded):
            #warning("FINISH THIS")
            // 1. set isInflight = true (spinner)
            // 2. send async request
            // 3. parse response
            // 4. update state
            // or, 1-3. could be performed by decorated `changeConsentList` closure for error cases (alert and informer)
            let selected = expanded.banks.filter(\.isSelected)
            let payload = selected.map(\.bank.id)

            changeConsentList(payload) { result in
                
                switch result {
                case .success:
                    completion(.collapsed(.init(
                        bankNames: selected.map(\.name)
                    )))
                    
                case let .serverError(message):
                    // state is the same except error - add field if decoration is not possible
                    completion(state)
                    
                case .connectivityError:
                    // state is the same except error - add field if decoration is not possible
                    completion(state)
                }
            }
            
        case .collapsedError:
            completion(state)
            
        case .expandedError:
            completion(state)
        }
    }
}

extension ConsentListReducer {
    
    typealias ConsentList = [Bank.ID]
    // (h) changeClientConsentMe2MePull
    typealias ChangeConsentList = (ConsentList, @escaping (ChangeConsentListResponse) -> Void) -> Void
    
    enum ChangeConsentListResponse {
        
        case success
        case serverError(String)
        case connectivityError
    }
}

extension ConsentListReducer {
    
    typealias State = ConsentListState
    typealias Event = ConsentListEvent
}
