//
//  ConsentListRxReducerTests.swift
//  FastPaymentsSettingsPreviewTests
//
//  Created by Igor Malyarov on 14.01.2024.
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
        
        guard let consentList = state.expandedConsentList
        else { return state }
        
        switch failure {
        case .connectivityError:
            return .success(.init(
                banks: consentList.banks,
                consent: consentList.consent,
                mode: .collapsed,
                searchText: consentList.searchText,
                status: .failure(.connectivityError)
            ))
            
        case let .serverError(message):
            return .success(.init(
                banks: consentList.banks,
                consent: consentList.consent,
                mode: .collapsed,
                searchText: consentList.searchText,
                status: .failure(.serverError(message))
            ))
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

@testable import FastPaymentsSettingsPreview
import XCTest

final class ConsentListRxReducerTests: XCTestCase {
    
    // MARK: - toggle
    
    func test_toggle_shouldDeliverExpandedErrorOnCollapsedError() {
        
        let collapsed: State = .failure(.collapsedError)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            sut.reduce(collapsed, .toggle).0,
            .failure(.expandedError)
        )
    }
    
    func test_toggle_shouldNotDeliverEffectOnCollapsedError() {
        
        let collapsed: State = .failure(.collapsedError)
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, collapsed, .toggle).effect)
    }
    
    func test_toggle_shouldDeliverCollapsedErrorOnExpandedError() {
        
        let expanded: State = .failure(.expandedError)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .toggle).state,
            .failure(.collapsedError)
        )
    }
    
    func test_toggle_shouldNotDeliverEffectOnExpandedError() {
        
        let expanded: State = .failure(.expandedError)
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, expanded, .toggle).effect)
    }
    
    func test_toggle_shouldDeliverConsentListInExpandedModeOnCollapsedMode() {
        
        let collapsed: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        assertExpanded(sut.reduce(collapsed, .toggle))
    }
    
    func test_toggle_shouldResetSelectableBanksOnCollapsedMode() {
        
        let collapsed: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        XCTAssertNotEqual(
            collapsed.selectedBankIDs,
            collapsed.consent
        )
        
        XCTAssertNoDiff(
            sut.reduce(collapsed, .toggle).0.selectedBankIDs,
            collapsed.consent
        )
    }
    
    func test_toggle_shouldNotChangeConsentOnCollapsedMode() {
        
        let collapsed: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, collapsed, .toggle).state.consent,
            collapsed.consent
        )
    }
    
    func test_toggle_shouldResetSearchTextOnCollapsedMode() {
        
        let collapsed: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            sut.reduce(collapsed, .toggle).0.searchText,
            ""
        )
    }
    
    func test_toggle_shouldNotDeliverEffectOnConsentListInCollapsedMode() {
        
        let collapsed: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, collapsed, .toggle).effect)
    }
    
    func test_toggle_shouldDeliverConsentListInCollapsedModeOnExpandedMode() {
        
        let expanded: State = .success(expandedConsentList())
        let sut = makeSUT()
        
        assertCollapsed(reduce(sut, expanded, .toggle))
    }
    
    func test_toggle_shouldNotDeliverEffectOnConsentListInExpandedMode() {
        
        let expanded: State = .success(expandedConsentList())
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, expanded, .toggle).effect)
    }
    
    func test_toggle_shouldResetSelectableBanksOnExpandedMode() {
        
        let expanded: State = .success(expandedConsentList())
        let sut = makeSUT()
        
        XCTAssertNotEqual(
            expanded.selectedBankIDs,
            expanded.consent
        )
        
        XCTAssertNoDiff(
            sut.reduce(expanded, .toggle).0.selectedBankIDs,
            expanded.consent
        )
    }
    
    func test_toggle_shouldNotChangeConsentOnExpandedMode() {
        
        let expanded: State = .success(expandedConsentList())
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .toggle).state.consent,
            expanded.consent
        )
    }
    
    func test_toggle_shouldResetSearchTextOnExpandedMode() {
        
        let expanded: State = .success(expandedConsentList())
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .toggle).state.searchText,
            ""
        )
    }
    
    // MARK: - search
    
    func test_search_shouldNotChangeStateOnCollapsedError() {
        
        let collapsed: State = .failure(.collapsedError)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, collapsed, .search(anyString())).state,
            collapsed
        )
    }
    
    func test_search_shouldNotDeliverEffectOnCollapsedError() {
        
        let collapsed: State = .failure(.collapsedError)
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, collapsed, .search(anyString())).effect)
    }
    
    func test_search_shouldNotChangeStateOnExpandedError() {
        
        let expanded: State = .failure(.expandedError)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .search(anyString())).state,
            expanded
        )
    }
    
    func test_search_shouldNotDeliverEffectOnExpandedError() {
        
        let expanded: State = .failure(.expandedError)
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, expanded, .search(anyString())).effect)
    }
    
    func test_search_shouldNotChangeStateOnCollapsedConsentList() {
        
        let collapsed: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, collapsed, .search(anyString())).state,
            collapsed
        )
    }
    
    func test_search_shouldNotDeliverEffectOnCollapsedConsentList() {
        
        let collapsed: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, collapsed, .search(anyString())).effect)
    }
    
    func test_search_shouldChangeSearchTextOnExpandedConsentList() {
        
        let text = UUID().uuidString
        let consentList = expandedConsentList()
        let expanded: State = .success(consentList)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .search(text)).state,
            .success(.init(
                banks: consentList.banks,
                consent: consentList.consent,
                mode: consentList.mode,
                searchText: text
            ))
        )
    }
    
    func test_search_shouldNotDeliverEffectOnExpandedConsentList() {
        
        let expanded: State = .success(expandedConsentList())
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, expanded, .search(anyString())).effect)
    }
    
    // MARK: - tapBank
    
    func test_tapBank_shouldNotChangeStateOnCollapsedError() {
        
        let collapsed: State = .failure(.collapsedError)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, collapsed, .tapBank(anyBankID())).state,
            collapsed
        )
    }
    
    func test_tapBank_shouldNotDeliverEffectOnCollapsedError() {
        
        let collapsed: State = .failure(.collapsedError)
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, collapsed, .tapBank(anyBankID())).effect)
    }
    
    func test_tapBank_shouldNotChangeStateOnExpandedError() {
        
        let expanded: State = .failure(.expandedError)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .tapBank(anyBankID())).state,
            expanded
        )
    }
    
    func test_tapBank_shouldNotDeliverEffectOnExpandedError() {
        
        let expanded: State = .failure(.expandedError)
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, expanded, .tapBank(anyBankID())).effect)
    }
    
    func test_tapBank_shouldNotChangeStateOnCollapsedConsentList() {
        
        let collapsed: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, collapsed, .tapBank(anyBankID())).state,
            collapsed
        )
    }
    
    func test_tapBank_shouldNotDeliverEffectOnCollapsedConsentList() {
        
        let collapsed: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, collapsed, .tapBank(anyBankID())).effect)
    }
    
    func test_tapBank_shouldChangeBanksOnExpandedConsentListWithExistingBankID() throws {
        
        let existingBankID: Bank.ID = try XCTUnwrap([Bank].preview.last?.id)
        let consentList = expandedConsentList()
        let expanded: State = .success(consentList)
        let sut = makeSUT()
        
        XCTAssertNotEqual(
            reduce(sut, expanded, .tapBank(existingBankID)).state.banks,
            consentList.banks
        )
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .tapBank(existingBankID)).state.selectedBankIDs,
            ["сургутнефтегазбанк"]
        )
    }
    
    func test_tapBank_shouldNotChangeBanksOnExpandedConsentListWithMissingBankID() throws {
        
        let id = anyBankID()
        let consentList = expandedConsentList()
        let expanded: State = .success(consentList)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .tapBank(id)).state.banks,
            consentList.banks
        )
    }
    
    func test_tapBank_shouldNotChangeConsentOnExpandedConsentList() throws {
        
        let id: Bank.ID = try XCTUnwrap([Bank].preview.last?.id)
        let consentList = expandedConsentList()
        let expanded: State = .success(consentList)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .tapBank(id)).state.consent,
            consentList.consent
        )
    }
    
    func test_tapBank_shouldNotChangeModeOnExpandedConsentList() throws {
        
        let id: Bank.ID = try XCTUnwrap([Bank].preview.last?.id)
        let consentList = expandedConsentList()
        let expanded: State = .success(consentList)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .tapBank(id)).state.mode,
            consentList.mode
        )
    }
    
    func test_tapBank_shouldNotChangeSearchTextOnExpandedConsentList() throws {
        
        let id: Bank.ID = try XCTUnwrap([Bank].preview.last?.id)
        let consentList = expandedConsentList()
        let expanded: State = .success(consentList)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .tapBank(id)).state.searchText,
            consentList.searchText
        )
    }
    
    func test_tapBank_shouldNotDeliverEffectOnExpandedConsentList() {
        
        let expanded: State = .success(expandedConsentList())
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, expanded, .tapBank(anyBankID())).effect)
    }
    
    // MARK: - applyConsent
    
    func test_applyConsent_shouldNotChangeStateOnCollapsedError() {
        
        let collapsed: State = .failure(.collapsedError)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, collapsed, .applyConsent).state,
            collapsed
        )
    }
    
    func test_applyConsent_shouldNotDeliverEffectOnCollapsedError() {
        
        let collapsed: State = .failure(.collapsedError)
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, collapsed, .applyConsent).effect)
    }
    
    func test_applyConsent_shouldNotChangeStateOnExpandedError() {
        
        let expanded: State = .failure(.expandedError)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .applyConsent).state,
            expanded
        )
    }
    
    func test_applyConsent_shouldNotDeliverEffectOnExpandedError() {
        
        let expanded: State = .failure(.expandedError)
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, expanded, .applyConsent).effect)
    }
    
    func test_applyConsent_shouldNotChangeStateOnCollapsedConsentList() {
        
        let collapsed: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, collapsed, .applyConsent).state,
            collapsed
        )
    }
    
    func test_applyConsent_shouldNotDeliverEffectOnCollapsedConsentList() {
        
        let collapsed: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, collapsed, .applyConsent).effect)
    }
    
    func test_applyConsent_shouldChangeStateToCollapsedModeAnsStatusInflightOnExpandedConsentList() {
        
        let expanded = expandedConsentList()
        let state: State = .success(expanded)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, state, .applyConsent).state,
            .success(.init(
                banks: expanded.banks,
                consent: expanded.consent,
                mode: .collapsed,
                searchText: expanded.searchText,
                status: .inflight
            ))
        )
    }
    
    func test_applyConsent_shouldDeliverApplyEffectWithConsentOnExpandedConsentList() {
        
        let consent: Consent = ["открытие", "сургутнефтегазбанк"]
        let expanded: State = .success(expandedConsentList(
            consent: consent
        ))
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .applyConsent).effect,
            .apply(.init(consent))
        )
    }
    
    // MARK: - changeConsent
    
    func test_changeConsent_shouldNotChangeStateOnCollapsedError() {
        
        let collapsed: State = .failure(.collapsedError)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, collapsed, .changeConsent(anyConsent())).state,
            collapsed
        )
    }
    
    func test_changeConsent_shouldNotDeliverEffectOnCollapsedError() {
        
        let collapsed: State = .failure(.collapsedError)
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, collapsed, .changeConsent(anyConsent())).effect)
    }
    
    func test_changeConsent_shouldNotChangeStateOnExpandedError() {
        
        let expanded: State = .failure(.expandedError)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .changeConsent(anyConsent())).state,
            expanded
        )
    }
    
    func test_changeConsent_shouldNotDeliverEffectOnExpandedError() {
        
        let expanded: State = .failure(.expandedError)
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, expanded, .changeConsent(anyConsent())).effect)
    }
    
    func test_changeConsent_shouldNotChangeStateOnCollapsedConsentList() {
        
        let collapsed: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, collapsed, .changeConsent(anyConsent())).state,
            collapsed
        )
    }
    
    func test_changeConsent_shouldNotDeliverEffectOnCollapsedConsentList() {
        
        let collapsed: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, collapsed, .changeConsent(anyConsent())).effect)
    }
    
    func test_changeConsent_shouldChangeConsentAndModeOnExpandedConsentList() {
        
        let consent = anyConsent()
        let consentList = expandedConsentList()
        let expanded: State = .success(consentList)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .changeConsent(consent)).state,
            .success(.init(
                banks: consentList.banks,
                consent: consent,
                mode: .collapsed,
                searchText: consentList.searchText,
                status: nil
            ))
        )
    }
    
    func test_changeConsent_shouldChangeConsentAndModeOnExpandedConsentListInFlight() {
        
        let consent = anyConsent()
        let consentList = expandedConsentList(status: .inflight)
        let expanded: State = .success(consentList)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .changeConsent(consent)).state,
            .success(.init(
                banks: consentList.banks,
                consent: consent,
                mode: .collapsed,
                searchText: consentList.searchText,
                status: nil
            ))
        )
    }
    
    func test_changeConsent_shouldNotDeliverEffectOnExpandedConsentList() {
        
        let expanded: State = .success(expandedConsentList())
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, expanded, .changeConsent(anyConsent())).effect)
    }
    
    // MARK: - changeConsentFailure
    
    func test_changeConsentFailure_shouldNotChangeStateOnCollapsedError_connectivity() {
        
        let collapsed: State = .failure(.collapsedError)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, collapsed, .changeConsentFailure(.connectivityError)).state,
            collapsed
        )
    }
    
    func test_changeConsentFailure_shouldNotDeliverEffectOnCollapsedError_connectivity() {
        
        let collapsed: State = .failure(.collapsedError)
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, collapsed, .changeConsentFailure(.connectivityError)).effect)
    }
    
    func test_changeConsentFailure_shouldNotChangeStateOnCollapsedError_serverError() {
        
        let message = "Change Consent Server Error"
        let collapsed: State = .failure(.collapsedError)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, collapsed, .changeConsentFailure(.serverError(message))).state,
            collapsed
        )
    }
    
    func test_changeConsentFailure_shouldNotDeliverEffectOnCollapsedError_serverError() {
        
        let message = "Change Consent Server Error"
        let collapsed: State = .failure(.collapsedError)
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, collapsed, .changeConsentFailure(.serverError(message))).effect)
    }
    
    func test_changeConsentFailure_shouldNotChangeStateOnExpandedError_connectivityError() {
        
        let expanded: State = .failure(.expandedError)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .changeConsentFailure(.connectivityError)).state,
            expanded
        )
    }
    
    func test_changeConsentFailure_shouldNotDeliverEffectOnExpandedError_connectivityError() {
        
        let expanded: State = .failure(.expandedError)
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, expanded, .changeConsentFailure(.connectivityError)).effect)
    }
    func test_changeConsentFailure_shouldNotChangeStateOnExpandedError() {
        
        let message = "Change Consent Server Error"
        let expanded: State = .failure(.expandedError)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .changeConsentFailure(.serverError(message))).state,
            expanded
        )
    }
    
    func test_changeConsentFailure_shouldNotDeliverEffectOnExpandedError() {
        
        let message = "Change Consent Server Error"
        let expanded: State = .failure(.expandedError)
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, expanded, .changeConsentFailure(.serverError(message))).effect)
    }
    
    func test_changeConsentFailure_shouldNotChangeStateOnCollapsedConsentList_connectivityError() {
        
        let collapsed: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, collapsed, .changeConsentFailure(.connectivityError)).state,
            collapsed
        )
    }
    
    func test_changeConsentFailure_shouldNotDeliverEffectOnCollapsedConsentList_connectivityError() {
        
        let collapsed: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, collapsed, .changeConsentFailure(.connectivityError)).effect)
    }
    
    func test_changeConsentFailure_shouldNotChangeStateOnCollapsedConsentList_serverError() {
        
        let message = "Change Consent Server Error"
        let collapsed: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, collapsed, .changeConsentFailure(.serverError(message))).state,
            collapsed
        )
    }
    
    func test_changeConsentFailure_shouldNotDeliverEffectOnCollapsedConsentList_serverError() {
        
        let message = "Change Consent Server Error"
        let collapsed: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, collapsed, .changeConsentFailure(.serverError(message))).effect)
    }
    
    func test_changeConsentFailure_shouldChangeStateToCollapsedModeAndStatusFailureOnExpandedConsentList_connectivityError() {
        
        let consentList = expandedConsentList()
        let expanded: State = .success(consentList)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .changeConsentFailure(.connectivityError)).state,
            .success(.init(
                banks: consentList.banks,
                consent: consentList.consent,
                mode: .collapsed,
                searchText: consentList.searchText,
                status: .failure(.connectivityError)
            ))
        )
    }
    
    func test_changeConsentFailure_shouldChangeStateToCollapsedModeAndStatusFailureOnExpandedConsentList_serverError() {
        
        let message = "Change Consent Server Error"
        let consentList = expandedConsentList()
        let expanded: State = .success(consentList)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .changeConsentFailure(.serverError(message))).state,
            .success(.init(
                banks: consentList.banks,
                consent: consentList.consent,
                mode: .collapsed,
                searchText: consentList.searchText,
                status: .failure(.serverError(message))
            ))
        )
    }
    
    func test_changeConsentFailure_shouldNotDeliverEffectOnExpandedConsentList_connectivityError() {
        
        let expanded: State = .success(expandedConsentList())
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, expanded, .changeConsentFailure(.connectivityError)).effect)
    }
    
    func test_changeConsentFailure_shouldNotDeliverEffectOnExpandedConsentList_serverError() {
        
        let message = "Change Consent Server Error"
        let expanded: State = .success(expandedConsentList())
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, expanded, .changeConsentFailure(.serverError(message))).effect)
    }
    
    // MARK: - resetStatus
    
    func test_resetStatus_shouldNotChangeStateOnCollapsedError() {
        
        let collapsed: State = .failure(.collapsedError)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, collapsed, .resetStatus).state,
            collapsed
        )
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnCollapsedError() {
        
        let collapsed: State = .failure(.collapsedError)
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, collapsed, .resetStatus).effect)
    }
    
    func test_resetStatus_shouldNotChangeStateOnExpandedError() {
        
        let expanded: State = .failure(.expandedError)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .resetStatus).state,
            expanded
        )
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnExpandedError() {
        
        let expanded: State = .failure(.expandedError)
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, expanded, .resetStatus).effect)
    }
    
    func test_resetStatus_shouldResetStatusOnCollapsedConsentList() {
        
        let collapsed = collapsedConsentList()
        let state: State = .success(collapsed)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, state, .resetStatus).state,
            .success(.init(
                banks: collapsed.banks,
                consent: collapsed.consent,
                mode: collapsed.mode,
                searchText: collapsed.searchText,
                status: nil
            ))
        )
    }
    
    func test_resetStatus_shouldResetStatusOnCollapsedConsentList_inflight() {
        
        let collapsed = collapsedConsentList(status: .inflight)
        let state: State = .success(collapsed)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, state, .resetStatus).state,
            .success(.init(
                banks: collapsed.banks,
                consent: collapsed.consent,
                mode: collapsed.mode,
                searchText: collapsed.searchText,
                status: nil
            ))
        )
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnCollapsedConsentList() {
        
        let collapsed: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, collapsed, .resetStatus).effect)
    }
    
    func test_resetStatus_shouldResetStatusOnExpandedConsentList() {
        
        let expanded = expandedConsentList()
        let state: State = .success(expanded)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, state, .resetStatus).state,
            .success(.init(
                banks: expanded.banks,
                consent: expanded.consent,
                mode: expanded.mode,
                searchText: expanded.searchText,
                status: nil
            ))
        )
    }
    
    func test_resetStatus_shouldResetStatusOnExpandedConsentList_inflight() {
        
        let expanded = expandedConsentList(status: .inflight)
        let state: State = .success(expanded)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, state, .resetStatus).state,
            .success(.init(
                banks: expanded.banks,
                consent: expanded.consent,
                mode: expanded.mode,
                searchText: expanded.searchText,
                status: nil
            ))
        )
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnExpandedConsentList() {
        
        let expanded: State = .success(expandedConsentList())
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, expanded, .resetStatus).effect)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ConsentListRxReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func reduce(
        _ sut: SUT,
        _ state: State,
        _ event: Event
    ) -> (state: State, effect: Effect?) {
        
        sut.reduce(state, event)
    }
    
    private func collapsedConsentList(
        banks: [ConsentList.SelectableBank] = .preview,
        consent: Consent = .preview,
        searchText: String = "",
        status: ConsentList.Status? = nil
    ) -> ConsentList {
        
        .init(
            banks: banks,
            consent: consent,
            mode: .collapsed,
            searchText: searchText,
            status: status
        )
    }
    
    private func expandedConsentList(
        banks: [ConsentList.SelectableBank] = .preview,
        consent: Consent = .preview,
        searchText: String = "",
        status: ConsentList.Status? = nil
    ) -> ConsentList {
        
        .init(
            banks: banks,
            consent: consent,
            mode: .expanded,
            searchText: searchText,
            status: status
        )
    }
    
    private func assertExpanded(
        _ result: (state: State, Effect?),
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch result.state {
        case .failure(.expandedError):
            break
            
        case let .success(consentList):
            XCTAssertNoDiff(consentList.mode, .expanded, file: file, line: line)
            
        default:
            XCTFail("Expected expanded state, got \(result.state) instead.", file: file, line: line)
        }
    }
    
    private func assertCollapsed(
        _ result: (state: State, Effect?),
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch result.state {
        case .failure(.collapsedError):
            break
            
        case let .success(consentList):
            XCTAssertNoDiff(consentList.mode, .collapsed, file: file, line: line)
            
        default:
            XCTFail("Expected collapsed state, got \(result.state) instead.", file: file, line: line)
        }
    }
}

extension Set where Element == Bank.ID {
    
    static let preview: Self = .init(
        [ConsentList.SelectableBank].preview.prefix(2).map(\.id)
    )
}

// MARK: DSL

private extension ConsentListState {
    
    var banks: [ConsentList.SelectableBank]? {
        
        switch self {
        case .failure:
            return nil
            
        case let .success(consentList):
            return consentList.banks
        }
    }
    
    var selectedBanks: [Bank] {
        
        switch self {
        case .failure:
            return []
            
        case let .success(consentList):
            return consentList.banks.filter(\.isSelected).map(\.bank)
        }
    }
    
    var selectedBankIDs: Set<Bank.ID> {
        
        .init(selectedBanks.map(\.id))
    }
    
    var consent: Consent? {
        
        switch self {
        case .failure:
            return nil
            
        case let .success(consentList):
            return consentList.consent
        }
    }
    
    var mode: ConsentList.Mode? {
        
        switch self {
        case .failure:
            return nil
            
        case let .success(consentList):
            return consentList.mode
        }
    }
    
    var searchText: String? {
        
        switch self {
        case .failure:
            return nil
            
        case let .success(consentList):
            return consentList.searchText
        }
    }
}
