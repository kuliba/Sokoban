//
//  ControlPanelReducerTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 04.07.2024.
//

@testable import ForaBank
import XCTest
import RxViewModel
import LandingUIComponent
import Combine

final class ControlPanelReducerTests: XCTestCase {
    
    func test_reduce_controlButtonEvent_delayAlert_shouldButtonsNotChangedAlertNilStatusNil() {
        
        let card = makeCardProduct(statusCard: .active)
        
        assertState(
            .controlButtonEvent(.delayAlert(card)),
            on: initialState(buttons: .buttons(card)))
    }
    
    func test_reduce_controlButtonEvent_showAlert_shouldButtonsNotChangedAlertNotNilStatusNil() {
        
        let card = makeCardProduct(statusCard: .active)
        
        assertState(
            .controlButtonEvent(.showAlert(.testAlert)),
            on: initialState(buttons: .buttons(card))) {
                
                $0.alert = .testAlert
            }
    }
    
    func test_reduce_controlButtonEvent_blockCard_shouldStatusInflightSpinnerNotNil() {
        
        let card = makeCardProduct(statusCard: .active)
        
        assertState(
            .controlButtonEvent(.blockCard(card)),
            on: initialState(buttons: .buttons(card))) {
                
                $0.status = .inflight(.block)
                $0.spinner = .init()
            }
    }
    
    func test_reduce_controlButtonEvent_unblockCard_shouldStatusInflightSpinnerNotNil() {
        
        let card = makeCardProduct(statusCard: .blockedUnlockAvailable)
        
        assertState(
            .controlButtonEvent(.unblockCard(card)),
            on: initialState(buttons: .buttons(card))) {
                
                $0.status = .inflight(.unblock)
                $0.spinner = .init()
            }
    }
    
    func test_reduce_controlButtonEvent_visibility_shouldStatusInflightSpinnerNotNil() {
        
        let card = makeCardProduct(statusCard: .blockedUnlockAvailable)
        
        assertState(
            .controlButtonEvent(.visibility(card)),
            on: initialState(buttons: .buttons(card))) {
                
                $0.status = .inflight(.visibility)
                $0.spinner = .init()
            }
    }
    
    func test_reduce_updateProducts_shouldStatusInflight() {
        
        let card = makeCardProduct(statusCard: .active)
        
        assertState(
            .updateProducts,
            on: initialState(buttons: .buttons(card))){
                
                $0.status = .inflight(.updateProducts)
            }
    }
    
    func test_reduce_update_shouldButtonsUpdatedAlertNilStatusNil() {
        
        let card = makeCardProduct(statusCard: .blockedUnlockAvailable)
        
        assertState(
            .updateState([]),
            on: initialState(buttons: .buttons(card))) {
                
                $0.buttons = []
            }
    }
    
    func test_reduce_controlButtonEvent_changePin_shouldNotChanged() {
        
        let card = makeCardProduct(statusCard: .active)
        
        assertState(
            .controlButtonEvent(.changePin(card)),
            on: initialState(buttons: .buttons(card)))
    }
    
    func test_reduce_updateTitle_shouldTitleChanged() {
        
        let card = makeCardProduct(statusCard: .active)
        
        assertState(
            .updateTitle("new title"),
            on: initialState(buttons: .buttons(card))){
                
                $0.navigationBarViewModel.title = "new title"
            }
    }
    
    func test_reduce_loadSVCardLanding_shouldNotChanged() {
        
        let card = makeCardProduct(statusCard: .active)
        
        assertState(
            .loadSVCardLanding(card),
            on: initialState(buttons: .buttons(card)))
    }
    
    func test_reduce_loadedSVCardLanding_shouldLandingWrapperViewModelChanged() {
        
        let card = makeCardProduct(statusCard: .active)
        let viewModel = createLandingWrapperViewModel()
        
        assertState(
            .loadedSVCardLanding(viewModel),
            on: initialState(buttons: .buttons(card))){
                
                $0.landingWrapperViewModel = viewModel
            }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ControlPanelReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    
    private typealias MakeAlert = ControlPanelReducer.MakeAlert
    typealias MakeActions = ControlPanelReducer.MakeActions
    
    
    let makeIconView: LandingView.MakeIconView = { _ in .init(
        image: .cardPlaceholder,
        publisher: Just(.cardPlaceholder).eraseToAnyPublisher()
    )}
    
    private func createLandingWrapperViewModel() -> LandingWrapperViewModel {
        .init(initialState: .success(.preview),
              imagePublisher: .imagePublisher,
              imageLoader: { _ in },
              makeIconView: makeIconView,
              config: .default,
              landingActions: { _ in
            return {}()
        }
        )
    }
    
    private func makeSUT(
        makeAlert: @escaping MakeAlert = { _ in .testAlert },
        makeActions: MakeActions = .emptyActions,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            controlPanelLifespan: .never,
            makeAlert: makeAlert,
            makeActions: makeActions
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private typealias UpdateStateToExpected<State> = (_ state: inout State) -> Void
    
    private func assertState(
        _ event: Event,
        on state: State,
        updateStateToExpected: UpdateStateToExpected<State>? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = makeSUT()
        
        var expectedState = state
        updateStateToExpected?(&expectedState)
        
        let (receivedState, _) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedState.buttons,
            expectedState.buttons,
            "\nExpected \(expectedState.buttons), but got \(receivedState.buttons) instead.",
            file: file, line: line
        )
        
        XCTAssertNoDiff(
            receivedState.alert?.id,
            expectedState.alert?.id,
            "\nExpected \(String(describing: expectedState.alert)), but got \(String(describing: receivedState.alert)) instead.",
            file: file, line: line
        )
        
        XCTAssertNoDiff(
            receivedState.spinner?.icon,
            expectedState.spinner?.icon,
            "\nExpected \(String(describing: expectedState.spinner)), but got \(String(describing: receivedState.spinner)) instead.",
            file: file, line: line
        )
        
        XCTAssertNoDiff(
            receivedState.status,
            expectedState.status,
            "\nExpected \(String(describing: expectedState.status)), but got \(String(describing: receivedState.status)) instead.",
            file: file, line: line
        )
        
        XCTAssertNoDiff(
            receivedState.navigationBarViewModel.title,
            expectedState.navigationBarViewModel.title,
            "\nExpected \(expectedState.navigationBarViewModel.title), but got \(receivedState.navigationBarViewModel.title) instead.",
            file: file, line: line
        )
    }
    
    private func initialState(
        buttons: [ControlPanelButtonDetails],
        navBarViewModel: NavigationBarView.ViewModel = .sample
    ) -> State {
        
        .init(buttons: buttons, navigationBarViewModel: navBarViewModel)
    }
    
    private func makeCardProduct(
        statusCard: ProductCardData.StatusCard = .active
    ) -> ProductCardData {
        
        .init(
            id: 1,
            productType: .card,
            number: "1111",
            numberMasked: "****",
            accountNumber: nil,
            balance: nil,
            balanceRub: nil,
            currency: "currency",
            mainField: "Card",
            additionalField: nil,
            customName: nil,
            productName: "Card",
            openDate: nil,
            ownerId: 0,
            branchId: 0,
            allowCredit: true,
            allowDebit: true,
            extraLargeDesign: .test,
            largeDesign: .test,
            mediumDesign: .test,
            smallDesign: .test,
            fontDesignColor: .init(description: ""),
            background: [],
            accountId: nil,
            cardId: 0,
            name: "CARD",
            validThru: Date(),
            status: .active,
            expireDate: "01/01/01",
            holderName: "Иванов",
            product: nil,
            branch: "",
            miniStatement: nil,
            paymentSystemName: nil,
            paymentSystemImage: nil,
            loanBaseParam: nil,
            statusPc: nil,
            isMain: nil,
            externalId: nil,
            order: 0,
            visibility: true,
            smallDesignMd5hash: "",
            smallBackgroundDesignHash: "",
            statusCard: statusCard
        )
    }
}

private extension Array where Element == ControlPanelButtonDetails {
    
    static func buttons(_ card: ProductCardData) -> Self {
        .cardGuardian(card, .init(.active))
    }
}

private extension LandingWrapperViewModel.ImagePublisher {
    
    static let imagePublisher: Self = {
        
        return Just(["1": .ic16Tv])
            .eraseToAnyPublisher()
    }()
}
