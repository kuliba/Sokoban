//
//  ConsentListRxReducer.swift
//  FastPaymentsSettingsPreviewTests
//
//  Created by Igor Malyarov on 15.01.2024.
//

public final class ConsentListRxReducer {
    
    public init() {}
}

public extension ConsentListRxReducer {
    
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

public extension ConsentListRxReducer {
    
    typealias State = ConsentListState
    typealias Event = ConsentListEvent
    typealias Effect = ConsentListEffect
}

#warning("add tests!!")
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
        
        consentList.status = .inflight
        let consent = consentList.banks.filter(\.isSelected).map(\.id)
        
        return (.success(consentList), .apply(.init(consent)))
    }
    
    func handleConsentChange(
        _ consent: Consent,
        in state: State
    ) -> State {
        
        guard var consentList = state.expandedConsentList
        else { return state }
        
        consentList.banks.apply(consent: consent)
        consentList.mode = .collapsed
        consentList.searchText = ""
        consentList.status = nil
        
        return .success(consentList)
    }
    
    func handleConsentChangeFailure(
        _ failure: ServiceFailure,
        in state: State
    ) -> State {
        
        guard var consentList = state.expandedConsentList
        else { return state }

        #warning("looks similar to toggle")
        consentList.banks.resetToConsented()
        consentList.mode = .collapsed
        consentList.searchText = ""

        consentList.status = .failure(failure)
        return .success(consentList)
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
        consentList.banks.resetToConsented()
        consentList.mode.toggle()
        consentList.searchText = ""
        
        return consentList
    }
}

private extension Array where Element == ConsentList.SelectableBank {
    
    func resetedToConsented() -> Self {
        
        let consented = filter(\.isConsented).map(\.id)
        let consent: Consent = .init(consented)
        
        return applied(consent: consent)
    }
    
    mutating func resetToConsented() {
        
        self = resetedToConsented()
    }
    
    func applied(consent: Consent) -> Self {
        
        .init(banks: map(\.bank), consent: consent).sorted()
    }
    
    mutating func apply(consent: Consent) {
        
        self = applied(consent: consent)
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
