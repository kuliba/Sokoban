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
            if var consentList = state.expandedConsentList {
                consentList.searchText = text
                state = .success(consentList)
            }
            
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
    
    var expandedConsentList: ConsentList? {
        
        guard case let .success(consentList) = self,
              consentList.mode == .expanded
        else { return nil }
        
        return consentList
    }
    
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
            reduce(sut, collapsed, .search(UUID().uuidString)).state,
            collapsed
        )
    }
    
    func test_search_shouldNotDeliverEffectOnCollapsedError() {
        
        let collapsed: State = .failure(.collapsedError)
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, collapsed, .search(UUID().uuidString)).effect)
    }
    
    func test_search_shouldNotChangeStateOnExpandedError() {
        
        let expanded: State = .failure(.expandedError)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .search(UUID().uuidString)).state,
            expanded
        )
    }
    
    func test_search_shouldNotDeliverEffectOnExpandedError() {
        
        let expanded: State = .failure(.expandedError)
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, expanded, .search(UUID().uuidString)).effect)
    }
    
    func test_search_shouldNotChangeStateOnCollapsedConsentList() {
        
        let collapsed: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, collapsed, .search(UUID().uuidString)).state,
            collapsed
        )
    }
    
    func test_search_shouldNotDeliverEffectOnCollapsedConsentList() {
        
        let collapsed: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        XCTAssertNil(reduce(sut, collapsed, .search(UUID().uuidString)).effect)
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
        
        XCTAssertNil(reduce(sut, expanded, .search(UUID().uuidString)).effect)
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
