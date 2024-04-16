//
//  ConsentListRxReducerTests.swift
//  FastPaymentsSettingsPreviewTests
//
//  Created by Igor Malyarov on 14.01.2024.
//

import FastPaymentsSettings
import RxViewModel
import XCTest

extension ConsentListRxReducer: Reducer {}

final class ConsentListRxReducerTests: XCTestCase {
    
    // MARK: - toggle
    
    func test_toggle_shouldDeliverExpandedErrorOnCollapsedError() {
        
        let collapsed: State = .failure(.collapsedError)
        
        assert(.toggle, on: collapsed) {
            $0 = .failure(.expandedError)
        }
    }
    
    func test_toggle_shouldNotDeliverEffectOnCollapsedError() {
        
        let collapsed: State = .failure(.collapsedError)
        
        assert(.toggle, on: collapsed, effect: nil)
    }
    
    func test_toggle_shouldDeliverCollapsedErrorOnExpandedError() {
        
        let expanded: State = .failure(.expandedError)
        let sut = makeSUT()
        
        assert(.toggle, on: expanded) {
            $0 = .failure(.collapsedError)
        }
    }
    
    func test_toggle_shouldNotDeliverEffectOnExpandedError() {
        
        let expanded: State = .failure(.expandedError)
        
        assert(.toggle, on: expanded, effect: nil)
    }
    
    func test_toggle_shouldDeliverConsentListInExpandedModeOnCollapsedMode() {
        
        let collapsed: State = .success(collapsedConsentList())
        let sut = makeSUT()
        
        assertExpanded(sut.reduce(collapsed, .toggle))
    }
    
    func test_toggle_shouldResetSelectableBanksOnCollapsedMode() {
        
        let collapsed: State = .success(collapsedConsentList(
            select: ["втб", "открытие"]
        ))
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
        
        assert(.toggle, on: collapsed, effect: nil)
    }
    
    func test_toggle_shouldDeliverConsentListInCollapsedModeOnExpandedMode() {
        
        let expanded: State = .success(expandedConsentList())
        let sut = makeSUT()
        
        assertCollapsed(reduce(sut, expanded, .toggle))
    }
    
    func test_toggle_shouldNotDeliverEffectOnConsentListInExpandedMode() {
        
        let expanded: State = .success(expandedConsentList())
        
        assert(.toggle, on: expanded, effect: nil)
    }
    
    func test_toggle_shouldResetSelectableBanksOnExpandedMode() {
        
        let expanded: State = .success(expandedConsentList(
            select: ["втб", "открытие"]
        ))
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
        
        assert(.search(anyString()), on: collapsed, effect: nil)
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
        
        assert(.search(anyString()), on: expanded, effect: nil)
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
        
        assert(.search(anyString()), on: collapsed, effect: nil)
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
                mode: consentList.mode,
                searchText: text
            ))
        )
    }
    
    func test_search_shouldNotDeliverEffectOnExpandedConsentList() {
        
        let expanded: State = .success(expandedConsentList())
        
        assert(.search(anyString()), on: expanded, effect: nil)
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
        
        assert(.tapBank(anyBankID()), on: collapsed, effect: nil)
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
        
        assert(.tapBank(anyBankID()), on: expanded, effect: nil)
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
        
        assert(.tapBank(anyBankID()), on: collapsed, effect: nil)
    }
    
    func test_tapBank_shouldChangeBanksOnExpandedConsentListWithExistingBankID() throws {
        
        let existingBankID: Bank.ID = try XCTUnwrap([Bank].preview.last?.id)
        let consentList = expandedConsentList(select: [])
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
        
        assert(.tapBank(anyBankID()), on: expanded, effect: nil)
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
        
        assert(.applyConsent, on: collapsed, effect: nil)
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
        
        assert(.applyConsent, on: expanded, effect: nil)
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
        
        assert(.applyConsent, on: collapsed, effect: nil)
    }
    
    func test_applyConsent_shouldChangeStatusToInflightOnExpandedConsentList() {
        
        let expanded = expandedConsentList()
        let state: State = .success(expanded)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, state, .applyConsent).state,
            .success(.init(
                banks: expanded.banks,
                mode: expanded.mode,
                searchText: expanded.searchText,
                status: .inflight
            ))
        )
    }
    
    func test_applyConsent_shouldDeliverApplyEffectWithConsentOnExpandedConsentList() {
        
        let consent: Consent = ["открытие", "сургутнефтегазбанк"]
        let select: Consent = ["втб", "тинькофф банк"]
        let expanded: State = .success(expandedConsentList(
            banks: .preview,
            consent: consent,
            select: select
        ))
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .applyConsent).effect,
            .apply(.init(select))
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
        
        assert(.changeConsent(anyConsent()), on: collapsed, effect: nil)
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
        
        assert(.changeConsent(anyConsent()), on: expanded, effect: nil)
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
        
        assert(.changeConsent(anyConsent()), on: collapsed, effect: nil)
    }
    
    func test_changeConsent_shouldChangeConsentOnExpandedConsentList() {
        
        let consent: Consent = ["втб"]
        let consentList = expandedConsentList()
        let expanded: State = .success(consentList)
        let sut = makeSUT()
        
        XCTAssertNotEqual(consentList.consent, consent)
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .changeConsent(consent)).state.consent,
            consent
        )
    }
    
    func test_changeConsent_shouldSortBanksOnExpandedConsentList() {
        
        let consent = anyConsent()
        let consentList = expandedConsentList(consent: [], select: [])
        let expanded: State = .success(consentList)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .changeConsent(consent)).state.banks,
            consentList.banks.sorted()
        )
    }
    
    func test_changeConsent_shouldChangeModeToCollapseOnExpandedConsentList() {
        
        let consent = anyConsent()
        let consentList = expandedConsentList()
        let expanded: State = .success(consentList)
        let sut = makeSUT()
        
        XCTAssertNoDiff(consentList.mode, .expanded)
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .changeConsent(consent)).state.mode,
            .collapsed
        )
    }
    
    func test_changeConsent_shouldResetSearchTextOnExpandedConsentList() {
        
        let consent = anyConsent()
        let consentList = expandedConsentList(searchText: "abc")
        let expanded: State = .success(consentList)
        let sut = makeSUT()
        
        XCTAssertNoDiff(consentList.searchText, "abc")
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .changeConsent(consent)).state.searchText,
            ""
        )
    }
    
    func test_changeConsent_shouldResetStatusOnExpandedConsentList() {
        
        let consent = anyConsent()
        let consentList = expandedConsentList(status: .inflight)
        let expanded: State = .success(consentList)
        let sut = makeSUT()
        
        XCTAssertNoDiff(consentList.status, .inflight)
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .changeConsent(consent)).state.status,
            nil
        )
    }
    
    func test_changeConsent_shouldChangeModeOnExpandedConsentList() {
        
        let consent = anyConsent()
        let consentList = expandedConsentList()
        let expanded: State = .success(consentList)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .changeConsent(consent)).state.mode,
            .collapsed
        )
    }
    
    func test_changeConsent_shouldChangeModeOnExpandedConsentListInFlight() {
        
        let consent = anyConsent()
        let consentList = expandedConsentList(status: .inflight)
        let expanded: State = .success(consentList)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .changeConsent(consent)).state.mode,
            .collapsed
        )
    }
    
    func test_changeConsent_shouldChangeConsentOnExpandedConsentListInFlight() {
        
        let consent: Consent = ["втб"]
        let consentList = expandedConsentList(status: .inflight)
        let expanded: State = .success(consentList)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .changeConsent(consent)).state.consent,
            consent
        )
    }
    
    func test_changeConsent_shouldNotDeliverEffectOnExpandedConsentList() {
        
        let expanded: State = .success(expandedConsentList())
        
        assert(.changeConsent(anyConsent()), on: expanded, effect: nil)
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
        
        assert(.changeConsentFailure(.connectivityError), on: collapsed, effect: nil)
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
        
        assert(.changeConsentFailure(.serverError(message)), on: collapsed, effect: nil)
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
        
        assert(.changeConsentFailure(.connectivityError), on: expanded, effect: nil)
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
        
        assert(.changeConsentFailure(.serverError(message)), on: expanded, effect: nil)
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
        
        assert(.changeConsentFailure(.connectivityError), on: collapsed, effect: nil)
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
        
        assert(.changeConsentFailure(.serverError(message)), on: collapsed, effect: nil)
    }
    
    func test_changeConsentFailure_shouldChangeStateOnExpandedConsentList_connectivityError_emptySearchText() {
        
        let consentList = expandedConsentList(
            searchText: ""
        )
        let expanded: State = .success(consentList)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .changeConsentFailure(.connectivityError)).state,
            .success(.init(
                banks: .consented(),
                mode: .collapsed,
                searchText: "",
                status: .failure(.connectivityError)
            ))
        )
    }
    
    func test_changeConsentFailure_shouldChangeStateOnExpandedConsentList_serverError_emptySearchText() {
        
        let message = "Change Consent Server Error"
        let consentList = expandedConsentList(
            searchText: ""
        )
        let expanded: State = .success(consentList)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .changeConsentFailure(.serverError(message))).state,
            .success(.init(
                banks: .consented(),
                mode: .collapsed,
                searchText: "",
                status: .failure(.serverError(message))
            ))
        )
    }
    
    func test_changeConsentFailure_shouldChangeStateOnExpandedConsentList_connectivityError_nonEmptySearchText() {
        
        let consentList = expandedConsentList(
            searchText: UUID().uuidString
        )
        let expanded: State = .success(consentList)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .changeConsentFailure(.connectivityError)).state,
            .success(.init(
                banks: .consented(),
                mode: .collapsed,
                searchText: "",
                status: .failure(.connectivityError)
            ))
        )
    }
    
    func test_changeConsentFailure_shouldChangeStateOnExpandedConsentList_serverError_nonEmptySearchText() {
        
        let message = "Change Consent Server Error"
        let consentList = expandedConsentList(
            searchText: UUID().uuidString
        )
        let expanded: State = .success(consentList)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, expanded, .changeConsentFailure(.serverError(message))).state,
            .success(.init(
                banks: .consented(),
                mode: .collapsed,
                searchText: "",
                status: .failure(.serverError(message))
            ))
        )
    }
    
    func test_changeConsentFailure_shouldNotDeliverEffectOnExpandedConsentList_connectivityError() {
        
        let expanded: State = .success(expandedConsentList())
        
        assert(.changeConsentFailure(.connectivityError), on: expanded, effect: nil)
    }
    
    func test_changeConsentFailure_shouldNotDeliverEffectOnExpandedConsentList_serverError() {
        
        let message = "Change Consent Server Error"
        let expanded: State = .success(expandedConsentList())
        
        assert(.changeConsentFailure(.serverError(message)), on: expanded, effect: nil)
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
        
        assert(.resetStatus, on: collapsed, effect: nil)
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
        
        assert(.resetStatus, on: expanded, effect: nil)
    }
    
    func test_resetStatus_shouldResetStatusOnCollapsedConsentList() {
        
        let collapsed = collapsedConsentList()
        let state: State = .success(collapsed)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, state, .resetStatus).state,
            .success(.init(
                banks: collapsed.banks,
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
                mode: collapsed.mode,
                searchText: collapsed.searchText,
                status: nil
            ))
        )
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnCollapsedConsentList() {
        
        let collapsed: State = .success(collapsedConsentList())
        
        assert(.resetStatus, on: collapsed, effect: nil)
    }
    
    func test_resetStatus_shouldResetStatusOnExpandedConsentList() {
        
        let expanded = expandedConsentList()
        let state: State = .success(expanded)
        let sut = makeSUT()
        
        XCTAssertNoDiff(
            reduce(sut, state, .resetStatus).state,
            .success(.init(
                banks: expanded.banks,
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
                mode: expanded.mode,
                searchText: expanded.searchText,
                status: nil
            ))
        )
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnExpandedConsentList() {
        
        let expanded: State = .success(expandedConsentList())
        
        assert(.resetStatus, on: expanded, effect: nil)
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
        banks: [Bank] = .preview,
        consent: Consent = .preview,
        select: Consent = .preview,
        searchText: String = "",
        status: ConsentList.Status? = nil
    ) -> ConsentList {
        
        .init(
            banks: .init(banks: banks, consent: consent, select: select),
            mode: .collapsed,
            searchText: searchText,
            status: status
        )
    }
    
    private func expandedConsentList(
        banks: [Bank] = .preview,
        consent: Consent = .preview,
        select: Consent = .preview,
        searchText: String = "",
        status: ConsentList.Status? = nil
    ) -> ConsentList {
        
        .init(
            banks: .init(banks: banks, consent: consent, select: select),
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
    
    private func assert(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        updateStateToExpected: UpdateStateToExpected<State>? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT()
        
        _assertState(
            sut,
            event,
            on: state,
            updateStateToExpected: updateStateToExpected,
            file: file, line: line
        )
    }
    
    private func assert(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        effect expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let receivedEffect = reduce(sut ?? makeSUT(), state, event).effect
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)) state, but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
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
            return .init(consentList.consent)
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
    
    var status: ConsentList.Status? {
        
        switch self {
        case .failure:
            return nil
            
        case let .success(consentList):
            return consentList.status
        }
    }
}

extension ConsentList {
    
    var consent: Consent {
        
        .init(banks.filter(\.isConsented).map(\.id))
    }
}
