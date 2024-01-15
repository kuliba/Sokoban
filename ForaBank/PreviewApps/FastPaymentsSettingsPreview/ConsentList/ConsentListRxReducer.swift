//
//  ConsentListRxReducer.swift
//  FastPaymentsSettingsPreviewTests
//
//  Created by Igor Malyarov on 15.01.2024.
//

final class ConsentListRxReducer {}

extension ConsentListRxReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .toggle:
            state.toggle()
            
        case let .search(text):
            state = updateStateForSearch(with: text, in: state)
            
        case let .tapBank(bankID):
            state = updateStateForTapBank(with: bankID, in: state)
            
        case .applyConsent:
            (state, effect) = applyConsent(to: state)
            
        case let .changeConsent(consent):
            state = handleConsentChange(consent, in: state)
            
        case let .changeConsentFailure(failure):
            state = handleConsentChangeFailure(failure, in: state)
            
        case .resetStatus:
            state = handleResetState(state)
        }
        
        return (state, effect)
    }
}

extension ConsentListRxReducer {
    
    typealias State = ConsentListState
    typealias Event = ConsentListEvent
    typealias Effect = ConsentListEffect
}

private extension ConsentListRxReducer {
    
    func updateStateForSearch(
        with text: String,
        in state: State
    ) -> State {
        
        guard var consentList = state.expandedConsentList
        else { return state }
        
        consentList.searchText = text
        
        return .success(consentList)
    }
    
    func updateStateForTapBank(
        with bankID: Bank.ID,
        in state: State
    ) -> State {
        
        guard var consentList = state.expandedConsentList
        else { return state }
        
        consentList.banks[bankID]?.isSelected.toggle()
        
        return .success(consentList)
    }
    
    func applyConsent(
        to state: State
    ) -> (State, Effect?) {
        
        guard var consentList = state.expandedConsentList
        else { return (state, nil) }
        
        consentList.mode = .collapsed
        consentList.status = .inflight
        
        return (.success(consentList), .apply(.init(consentList.consent)))
    }
    
    func handleConsentChange(
        _ consent: Consent,
        in state: State
    ) -> State {
        
        guard var consentList = state.expandedConsentList
        else { return state }
        
        consentList.consent = consent
        consentList.mode = .collapsed
        consentList.status = nil
        
        return .success(consentList)
    }
    
    func handleConsentChangeFailure(
        _ failure: ConsentListEvent.ConsentFailure,
        in state: State
    ) -> State {
        
        guard var consentList = state.expandedConsentList
        else { return state }
        
        consentList.mode = .collapsed
        
        switch failure {
        case .connectivityError:
            consentList.status = .failure(.connectivityError)
            return .success(consentList)
            
        case let .serverError(message):
            consentList.status = .failure(.serverError(message))
            return .success(consentList)
        }
    }
    
    func handleResetState(
        _ state: State
    ) -> State {
        
        guard case var .success(consentList) = state
        else { return state }
        
        consentList.status = nil
        
        return .success(consentList)
    }
}

private extension ConsentListState {
    
    var expandedConsentList: ConsentList? {
        
        guard case let .success(consentList) = self,
              consentList.mode == .expanded
        else { return nil }
        
        return consentList
    }
    
    mutating func toggle() {
        
        switch self {
        case let .failure(failure):
            self = .failure(failure.toggled())
            
        case let .success(success):
            self = .success(success.toggled())
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

private extension Array where Element == ConsentList.SelectableBank {
    
    mutating func resetSelection(to selected: Set<Bank.ID>) {
        
        for index in indices {
            
            let isSelected = selected.contains(self[index].id)
            self[index].isSelected = isSelected
        }
    }
}

private extension ConsentList.Mode {
    
    mutating func toggle() {
        
        self = (self == .collapsed) ? .expanded : .collapsed
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
