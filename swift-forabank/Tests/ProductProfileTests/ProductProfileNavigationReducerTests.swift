//
//  ProductProfileNavigationReducerTests.swift
//
//
//  Created by Andryusina Nataly on 15.02.2024.
//

@testable import ProductProfile
import ForaTools
import ProductProfileComponents
import RxViewModel
import UIPrimitives
import XCTest

final class ProductProfileNavigationReducerTests: XCTestCase {
    
    // MARK: test create
    
    func test_createCardGuardian_shouldDeliverEffectCreateCardGuardian() {
        
        assert(
            .create(.cardGuardian),
            on: productProfileState(),
            effect: .create(.cardGuardian))
    }
    
    func test_createCardGuardian_shouldSetStatusOnModalNilAlertNil() {
        
        assert(.create(.cardGuardian), on: productProfileState()) {
            
            $0.modal = nil
            $0.alert = nil
        }
    }
    
    func test_createTopUpCard_shouldDeliverEffectCreateTopUpCard() {
        
        assert(
            .create(.topUpCard),
            on: productProfileState(),
            effect: .create(.topUpCard))
    }
    
    func test_createTopUpCard_shouldSetStatusOnModalNilAlertNil() {
        
        assert(.create(.topUpCard), on: productProfileState()) {
            
            $0.modal = nil
            $0.alert = nil
        }
    }
    
    func test_createAccountInfo_shouldDeliverEffectCreateAccountInfoPanel() {
        
        assert(
            .create(.accountInfo),
            on: productProfileState(),
            effect: .create(.accountInfo))
    }
    
    func test_createAccountInfo_shouldSetStatusOnModalNilAlertNil() {
        
        assert(.create(.accountInfo), on: productProfileState()) {
            
            $0.modal = nil
            $0.alert = nil
        }
    }
    
    func test_createProductDetails_shouldDeliverEffectCreateDetails() {
        
        assert(
            .create(.productDetails),
            on: productProfileState(),
            effect: .create(.productDetails))
    }
    
    func test_createProductDetails_shouldSetStatusOnModalNilAlertNil() {
        
        assert(.create(.productDetails), on: productProfileState()) {
            
            $0.modal = nil
            $0.alert = nil
        }
    }
    
    // MARK: test open
    
    func test_openCardGuardian_shouldNotDeliverEffect() {
        
        assert(
            .open(.cardGuardianRoute(createCardGuardianRoute())),
            on: productProfileState(),
            effect: nil)
    }
    
    func test_openTopUpCard_shouldNotDeliverEffect() {
        
        assert(
            .open(.topUpCardRoute(createTopUpCardRoute())),
            on: productProfileState(),
            effect: nil)
    }
    
    func test_openAccountInfo_shouldNotDeliverEffect() {
        
        assert(
            .open(.accountInfoPanelRoute(createAccountInfoRoute())),
            on: productProfileState(),
            effect: nil)
    }
    
    func test_openDetails_shouldNotDeliverEffect() {
        
        assert(
            .open(.productDetailsRoute(createProductDetailsRoute())),
            on: productProfileState(),
            effect: nil)
    }
    
    // MARK: test closeAlert
    
    func test_closeAlert_shouldNotDeliverEffect() {
        
        assert(
            .closeAlert,
            on: productProfileState(),
            effect: nil)
    }
    
    func test_closeAlert_shouldSetStatusOnModalNilAlertNil() {
        
        assert(.closeAlert, on: productProfileState(.none, .alertCVV())) {
            
            $0.modal = nil
            $0.alert = nil
        }
    }
    
    // MARK: test dismissDestination
    
    func test_dismissDestination_shouldNotDeliverEffect() {
        
        assert(
            .dismissModal,
            on: productProfileState(),
            effect: nil)
    }
    
    // MARK: test cardGuardianInput
    
    func test_cardGuardianInput_shouldNotDeliverEffect() {
        
        assert(
            .cardGuardianInput(.appear),
            on: productProfileState(),
            effect: nil)
    }
    
    func test_appear_shouldSetStatusOnModalNilAlertNil() {
        
        assert(.cardGuardianInput(.appear), on: productProfileState()) {
            
            $0.modal = nil
            $0.alert = nil
        }
    }
    
    // MARK: test showAlert
    
    func test_showAlert_shouldNotDeliverEffect() {
        
        assert(
            .showAlert(AlertModelOf.alertBlockCard(.newCard(status: .active))),
            on: productProfileState(),
            effect: nil)
    }
    
    func test_showAlert_shouldSetStatusOnModalNilAlertNotNil() {
        
        let alert = AlertModelOf.alertBlockCard(.newCard(status: .active))

        assert(.showAlert(alert), on: productProfileState()) {
            
            $0.modal = nil
            $0.alert = alert
        }
    }

    // MARK: test alertInput
    
    func test_alertInput_showContacts_shouldDeliverEffectShowContacts() {
        
        assert(
            .productProfile(.showContacts),
            on: productProfileState(),
            effect: .productProfile(.showContacts))
    }
    
    // MARK: - test productDetailsInput
    
    // MARK: test apear

    func test_appear_shouldNotDeliverEffect() {
        
        assert(
            .productDetailsInput(.appear),
            on: productProfileState(),
            effect: nil)
    }
    
    // MARK: test itemTapped
    
    func test_iconTap_shouldDeliverEffectOnProductProfile() {
        
        assert(
            .productDetailsInput(.itemTapped(.iconTap(.accountNumber))),
            on: productProfileState(),
            effect: .productProfile(.productDetailsIconTap(.accountNumber)))
    }
    
    func test_longPress_shouldDeliverEffectOnProductProfile() {
        
        assert(
            .productDetailsInput(.itemTapped(.longPress("text", "informer"))),
            on: productProfileState(),
            effect: .productProfile(.productDetailsItemlongPress("text", "informer")))
    }
    
    func test_share_shouldDeliverEffectOnCreate() {
        
        assert(
            .productDetailsInput(.itemTapped(.share)),
            on: productProfileState(),
            effect: .create(.share))
    }
    
    func test_selectAccountValueFalse_shouldDeliverEffectNil() {
        
        assert(
            .productDetailsInput(.itemTapped(.selectAccountValue(false))),
            on: productProfileState(),
            effect: nil)
    }

    func test_selectAccountValueTrue_shouldDeliverEffectNil() {
        
        assert(
            .productDetailsInput(.itemTapped(.selectAccountValue(true))),
            on: productProfileState(),
            effect: nil)
    }

    func test_selectCardValueFalse_shouldDeliverEffectNil() {
        
        assert(
            .productDetailsInput(.itemTapped(.selectCardValue(false))),
            on: productProfileState(),
            effect: nil)
    }

    func test_selectCardValueTrue_shouldDeliverEffectNil() {
        
        assert(
            .productDetailsInput(.itemTapped(.selectCardValue(true))),
            on: productProfileState(),
            effect: nil)
    }

    // MARK: test close
    
    func test_close_shouldDeliverEffectOnProductProfile() {
        
        assert(
            .productDetailsInput(.close),
            on: productProfileState(),
            effect: nil)
    }
    
    // MARK: test closeModal
    
    func test_closeModal_shouldDeliverEffectNil() {
        
        assert(
            .productDetailsInput(.closeModal),
            on: productProfileState(),
            effect: nil)
    }
    
    // MARK: test sendAll
    
    func test_sendAll_shouldDeliverEffectNil() {
        
        assert(
            .productDetailsInput(.sendAll),
            on: productProfileState(),
            effect: nil)
    }

    // MARK: test sendSelect
    
    func test_sendSelect_shouldDeliverEffectNil() {
        
        assert(
            .productDetailsInput(.sendSelect),
            on: productProfileState(),
            effect: nil)
    }

    private typealias SUT = ProductProfileNavigationReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    private typealias MakeCardGuardianViewModel = (AnySchedulerOfDispatchQueue) -> CardGuardianViewModel
    private typealias MakeTopUpCardViewModel = (AnySchedulerOfDispatchQueue) -> TopUpCardViewModel
    private typealias MakeAccountInfoPanelViewModel = (AnySchedulerOfDispatchQueue) -> AccountInfoPanelViewModel
    private typealias MakeProductDetailsViewModel = (AnySchedulerOfDispatchQueue) -> ProductDetailsViewModel

    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func productProfileState(
        _ modal: SUT.State.ProductProfileRoute? = nil,
        _ alert: AlertModelOf<ProductProfileNavigation.Event>? = nil
    ) -> SUT.State {
        
        .init(
            modal: modal,
            alert: alert
        )
    }
    
    private func reduce(
        _ sut: SUT,
        _ state: State,
        _ event: Event
    ) -> (state: State, effect: Effect?) {
        
        sut.reduce(state, event)
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
    
    private func createCardGuardianRoute(
    ) -> ProductProfileNavigation.CardGuardianRoute {
        
        let cardGuardianReduce = CardGuardianReducer().reduce(_:_:)
        
        let makeCardGuardianViewModel: MakeCardGuardianViewModel =  {
            .init(
                initialState: .init(buttons: .preview),
                reduce: cardGuardianReduce,
                handleEffect: { _,_ in },
                scheduler: $0
            )
        }
        
        let cardGuardianViewModel = makeCardGuardianViewModel(.immediate)
        let cancellable = cardGuardianViewModel.$state
            .sink { _ in }
        
        return .init(cardGuardianViewModel, cancellable)
    }
    
    private func createTopUpCardRoute(
    ) -> ProductProfileNavigation.TopUpCardRoute {
        
        let topUpCardReduce = TopUpCardReducer().reduce(_:_:)
        
        let makeTopUpCardViewModel: MakeTopUpCardViewModel =  {
            .init(
                initialState: .init(buttons: .previewRegular),
                reduce: topUpCardReduce,
                handleEffect: { _,_ in },
                scheduler: $0
            )
        }
        
        let topUpCardViewModel = makeTopUpCardViewModel(.immediate)
        let cancellable = topUpCardViewModel.$state
            .sink { _ in }
        
        return .init(topUpCardViewModel, cancellable)
    }
    
    private func createAccountInfoRoute(
    ) -> ProductProfileNavigation.AccountInfoRoute {
        
        let accountInfoReduce = AccountInfoPanelReducer().reduce(_:_:)
        
        let accountInfoHandleEffect = AccountInfoPanelEffectHandler().handleEffect(_:_:)

        let makeAccountInfoPanelViewModel: MakeAccountInfoPanelViewModel =  {
            .init(
                initialState: .init(buttons: .previewRegular),
                reduce: accountInfoReduce,
                handleEffect: accountInfoHandleEffect,
                scheduler: $0
            )
        }
        
        let accountInfoViewModel = makeAccountInfoPanelViewModel(.immediate)
        let cancellable = accountInfoViewModel.$state
            .sink { _ in }
        
        return .init(accountInfoViewModel, cancellable)
    }
    
    private func createProductDetailsRoute(
        shareInfo: @escaping ([String]) -> Void = {_ in }
    ) -> ProductProfileNavigation.ProductDetailsRoute {
        
        let detailsReduce = ProductDetailsReducer(shareInfo: shareInfo).reduce(_:_:)
        
        let detailsHandleEffect = ProductDetailsEffectHandler().handleEffect(_:_:)

        let makeDetailsViewModel: MakeProductDetailsViewModel =  {
            .init(
                initialState: .init(
                    accountDetails: .accountItems,
                    cardDetails: .cardItems),
                reduce: detailsReduce,
                handleEffect: detailsHandleEffect,
                scheduler: $0
            )
        }
        
        let detailsViewModel = makeDetailsViewModel(.immediate)
        let cancellable = detailsViewModel.$state
            .sink { _ in }
        
        return .init(detailsViewModel, cancellable)
    }
}

private extension CardGuardianUI.Card {
    
    static func newCard(
        status: CardGuardianStatus
    ) -> CardGuardianUI.Card {
        
        .init(
            cardId: 1,
            cardNumber: "111",
            cardGuardianStatus: status
        )
    }
}

extension ProductProfileNavigationReducer: Reducer { }
