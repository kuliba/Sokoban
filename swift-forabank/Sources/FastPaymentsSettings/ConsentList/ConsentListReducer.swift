//
//  ConsentListReducer.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

import Foundation

public final class ConsentListReducer {
    
    private let availableBanks: [Bank]
    private let changeConsentList: ChangeConsentList
    
    public init(
        availableBanks: [Bank],
        changeConsentList: @escaping ChangeConsentList
    ) {
        self.availableBanks = availableBanks
        self.changeConsentList = changeConsentList
    }
}

public extension ConsentListReducer {
    
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
            
        case .applyConsent:
            apply(state, completion)
            
        case let .changeConsent(consent):
            fatalError("unimplemented")
            
        case let .changeConsentFailure(failure):
            fatalError("unimplemented")
            
        case .resetStatus:
            fatalError("unimplemented")
        }
    }
}

public extension ConsentListReducer {
    
    typealias ChangeConsentListPayload = [Bank.ID]
    // (h) changeClientConsentMe2MePull
    typealias ChangeConsentList = (ChangeConsentListPayload, @escaping (ChangeConsentListResponse) -> Void) -> Void
    
    enum ChangeConsentListResponse {
        
        case success
        case serverError(String)
        case connectivityError
    }
}

public extension ConsentListReducer {
    
    typealias State = ConsentListState
    typealias Event = ConsentListEvent
}

private extension ConsentListReducer {
    
    func toggle(
        _ state: State,
        _ completion: @escaping (State) -> Void
    ) {
        completion(state.toggled())
    }
    
    func search(
        _ text: String,
        _ state: State,
        _ completion: @escaping (State) -> Void
    ) {
        guard var consentList = state.expandedConsentList
        else {
            completion(state)
            return
        }
        
        consentList.searchText = text
        completion(.success(consentList))
    }
    
    func tapBank(
        _ bankID: Bank.ID,
        _ state: State,
        _ completion: @escaping (State) -> Void
    ) {
        guard var consentList = state.expandedConsentList
        else {
            completion(state)
            return
        }
        
        consentList.banks[bankID]?.isSelected.toggle()
        completion(.success(consentList))
    }
    
    func apply(
        _ state: State,
        _ completion: @escaping (State) -> Void
    ) {
        guard let consentList = state.expandedConsentList
        else {
            completion(state)
            return
        }
        
#warning("FINISH THIS")
        // 1. set isInflight = true (spinner)
        // 2. send async request
        // 3. parse response
        // 4. update state
        // or, 1-3. could be performed by decorated `changeConsentList` closure for error cases (alert and informer)
        let payload = consentList.selectedBanks.map(\.id)
        
        changeConsentList(payload) { result in
            
            switch result {
            case .success:
                completion(.success(.init(
                    banks: consentList.banks,
                    consent: .init(payload),
                    mode: .collapsed,
                    searchText: ""
                )))
                
            case let .serverError(message):
                // state should collapse!! plus error - add field if decoration is not possible
                completion(state.toggled())
                
            case .connectivityError:
                // state should collapse!! plus error - add field if decoration is not possible
                completion(state.toggled())
            }
        }
    }
}

private extension ConsentListState {
    
    var expandedConsentList: ConsentList? {
        
        guard case let .success(consentList) = self,
              consentList.mode == .expanded
        else { return nil }
        
        return consentList
    }
    
    func toggled() -> Self {
        
        switch self {
        case let .failure(failure):
            return .failure(failure.toggled())
            
        case let .success(success):
            return .success(success.toggled())
        }
    }
}

private extension ConsentList {
    
    func toggled() -> Self {
        
        var consentList = self
        consentList.banks.resetSelection(to: consent)
        consentList.mode.toggle()
        consentList.searchText = ""
        
        return consentList
    }
}

private extension ConsentList.Mode {
    
    mutating func toggle() {
        
        self = (self == .collapsed) ? .expanded : .collapsed
    }
}

private extension Array where Element == ConsentList.SelectableBank {
    
    mutating func resetSelection(to selected: Set<Bank.ID>) {
        
        for index in indices {
            
            let isSelected = selected.contains(self[index].id)
            self[index].isSelected = isSelected
        }
    }
}

private extension ConsentListFailure {
    
    func toggled() -> Self {
        
        switch self {
        case .collapsedError:
            return .expandedError
            
        case .expandedError:
            return .collapsedError
        }
    }
}
