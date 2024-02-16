//
//  ProductProfileNavigationReducerTests.swift
//
//
//  Created by Andryusina Nataly on 15.02.2024.
//

@testable import ProductProfile
import XCTest
import UIPrimitives
import CardGuardianModule
import RxViewModel

final class ProductProfileNavigationReducerTests: XCTestCase {
    
    // MARK: test create
    
    func test_create_shouldEffectCreate() {
        
        assert(
            .create,
            on: productProfileState(),
            effect: .create)
    }
    
    // MARK: test open
    
    func test_open_shouldEffectNil() {
        
        assert(
            .open(createCardGuardianRoute()),
            on: productProfileState(),
            effect: nil)
    }
    
    // MARK: test closeAlert
    
    func test_closeAlert_shouldEffectNil() {
        
        assert(
            .closeAlert,
            on: productProfileState(),
            effect: nil)
    }
    
    // MARK: test dismissDestination
    
    func test_dismissDestination_shouldEffectNil() {
        
        assert(
            .dismissDestination,
            on: productProfileState(),
            effect: nil)
    }
    
    // MARK: test cardGuardianInput
    
    func test_cardGuardianInput_shouldEffectNil() {
        
        assert(
            .cardGuardianInput(.appear),
            on: productProfileState(),
            effect: nil)
    }
    
    // MARK: test showAlert
    
    func test_showAlert_shouldEffectNil() {
        
        assert(
            .showAlert(Alerts.alertBlockCard(.newCard(status: .active))),
            on: productProfileState(),
            effect: nil)
    }

    // MARK: test alertInput
    
    func test_alertInput_showContacts_shouldEffectShowContacts() {
        
        assert(
            .productProfile(.showContacts),
            on: productProfileState(),
            effect: .productProfile(.showContacts))
    }
    
    private typealias SUT = ProductProfileNavigationReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    private typealias MakeCardGuardianViewModel = (AnySchedulerOfDispatchQueue) -> CardGuardianViewModel
    
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
        
        let cardGuardianViewModel = makeCardGuardianViewModel(.main)
        let cancellable = cardGuardianViewModel.$state
            .sink { _ in }
        
        return .init(cardGuardianViewModel, cancellable)
    }
}

private extension Card {
    
    static func newCard(
        status: CardGuardianStatus
    ) -> Card {
        
        .init(
            cardId: 1,
            cardNumber: "111",
            cardGuardianStatus: status
        )
    }
}
