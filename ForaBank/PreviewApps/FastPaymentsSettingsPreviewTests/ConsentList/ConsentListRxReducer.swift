//
//  ConsentListRxReducerTests.swift
//  FastPaymentsSettingsPreviewTests
//
//  Created by Igor Malyarov on 14.01.2024.
//

final class ConsentListRxReducer {
    
}

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
            break
            // search(text, state, completion)
            
        case let .tapBank(bankID):
            fatalError()
            // tapBank(bankID, state, completion)
            
        case .apply:
            fatalError()
            // apply(state, completion)
        }
        
        return (state, effect)
    }
}

extension ConsentListRxReducer {
    
    typealias State = ConsentListState
    typealias Event = ConsentListEvent
    typealias Effect = ConsentListEffect
}

private extension ConsentListState {
    
    mutating func toggle() {
        
        switch self {
        case var .failure(failure):
            self = .failure(failure.toggled())
            
        case var .success(success):
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
        
        let state: State = .failure(.collapsedError)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            sut.reduce(state, .toggle).0,
            .failure(.expandedError)
        )
    }
    
    func test_toggle_shouldNotDeliverEffectOnCollapsedError() {
        
        let state: State = .failure(.collapsedError)
        let sut = makeSUT()
        
        XCTAssertNil(sut.reduce(state, .toggle).1)
    }
    
    func test_toggle_shouldDeliverCollapsedErrorOnExpandedError() {
        
        let state: State = .failure(.expandedError)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            sut.reduce(state, .toggle).0,
            .failure(.collapsedError)
        )
    }
    
    func test_toggle_shouldNotDeliverEffectOnExpandedError() {
        
        let state: State = .failure(.expandedError)
        let sut = makeSUT()
        
        XCTAssertNil(sut.reduce(state, .toggle).1)
    }
    
    func test_toggle_shouldDeliverConsentListInExpandedModeOnCollapsedMode() {
        
        let state: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        assertExpanded(sut.reduce(state, .toggle).0)
    }
    
    func test_toggle_shouldResetSelectableBanksOnCollapsedMode() {
        
        let state: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        XCTAssertNotEqual(state.selectedBankIDs, state.consent)
        
        XCTAssertNoDiff(
            sut.reduce(state, .toggle).0.selectedBankIDs,
            state.consent
        )
    }
    
    func test_toggle_shouldNotChangeConsentOnCollapsedMode() {
        
        let state: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            sut.reduce(state, .toggle).0.consent,
            state.consent
        )
    }
    
    func test_toggle_shouldResetSearchTextOnCollapsedMode() {
        
        let state: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            sut.reduce(state, .toggle).0.searchText,
            ""
        )
    }
    
    func test_toggle_shouldNotDeliverEffectOnConsentListInCollapsedMode() {
        
        let state: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        XCTAssertNil(sut.reduce(state, .toggle).1)
    }
    
    func test_toggle_shouldDeliverConsentListInCollapsedModeOnExpandedMode() {
        
        let state: State = .success(expandedConsentList())
        let sut = makeSUT()
        
        assertCollapsed(sut.reduce(state, .toggle).0)
    }
    
    func test_toggle_shouldNotDeliverEffectOnConsentListInExpandedMode() {
        
        let state: State = .success(expandedConsentList())
        let sut = makeSUT()
        
        XCTAssertNil(sut.reduce(state, .toggle).1)
    }
    
    func test_toggle_shouldResetSelectableBanksOnExpandedMode() {
        
        let state: State = .success(expandedConsentList())
        let sut = makeSUT()
        
        XCTAssertNotEqual(state.selectedBankIDs, state.consent)
        
        XCTAssertNoDiff(
            sut.reduce(state, .toggle).0.selectedBankIDs,
            state.consent
        )
    }
    
    func test_toggle_shouldNotChangeConsentOnExpandedMode() {
        
        let state: State = .success(expandedConsentList())
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            sut.reduce(state, .toggle).0.consent,
            state.consent
        )
    }
    
    func test_toggle_shouldResetSearchTextOnExpandedMode() {
        
        let state: State = .success(expandedConsentList())
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            sut.reduce(state, .toggle).0.searchText,
            ""
        )
    }
    
    // MARK: - search
    
    func test_search_shouldNotChangeStateOnCollapsedError() {
        
        let state: State = .failure(.collapsedError)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            sut.reduce(state, .search(UUID().uuidString)).0,
            state
        )
    }
    
    func test_search_shouldNotDeliverEffectOnCollapsedError() {
        
        let state: State = .failure(.collapsedError)
        let sut = makeSUT()
        
        XCTAssertNil(sut.reduce(state, .toggle).1)
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
    
    private func collapsedConsentList(
        banks: [ConsentList.SelectableBank] = .preview,
        consent: Set<Bank.ID> = .preview,
        searchText: String = ""
    ) -> ConsentList {
        
        .init(
            banks: banks,
            consent: consent,
            mode: .collapsed,
            searchText: searchText
        )
    }
    
    private func expandedConsentList(
        banks: [ConsentList.SelectableBank] = .preview,
        consent: Set<Bank.ID> = .preview,
        searchText: String = ""
    ) -> ConsentList {
        
        .init(
            banks: banks,
            consent: consent,
            mode: .expanded,
            searchText: searchText
        )
    }
    
    private func assertExpanded(
        _ state: ConsentListState,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch state {
        case .failure(.expandedError):
            break
            
        case let .success(consentList):
            XCTAssertNoDiff(consentList.mode, .expanded, file: file, line: line)
            
        default:
            XCTFail("Expected expanded state, git \(state) instead.", file: file, line: line)
        }
    }
    
    private func assertCollapsed(
        _ state: ConsentListState,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch state {
        case .failure(.collapsedError):
            break
            
        case let .success(consentList):
            XCTAssertNoDiff(consentList.mode, .collapsed, file: file, line: line)
            
        default:
            XCTFail("Expected collapsed state, git \(state) instead.", file: file, line: line)
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
    
    var consent: ConsentList.Consent? {
        
        switch self {
        case .failure:
            return nil
            
        case let .success(consentList):
            return consentList.consent
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
