//
//  ProductProfileNavigationEffectHandlerTests.swift
//
//
//  Created by Andryusina Nataly on 14.02.2024.
//

@testable import ProductProfile
import CardGuardianUI
import RxViewModel
import UIPrimitives
import XCTest

extension ProductProfileNavigationEffectHandler: EffectHandler {}

final class ProductProfileNavigationEffectHandlerTests: XCTestCase {
    
    // MARK: test showAlert
    
    func test_showCVVAlert_shouldDeliverShowAlert() {
        
        let sut = makeSUT()
        
        let id = UUID()
        let alert = AlertModelOf.alertCVV(id)
        
        expect(sut, with: .delayAlert(alert, .milliseconds(300)), toDeliver: .showAlert(alert))
    }
    
    func test_showCardBlockedAlert_shouldDeliverShowAlert() {
        
        let sut = makeSUT()
        
        let id = UUID()
        let alert = AlertModelOf.alertCardBlocked(id)
        
        expect(sut, with: .delayAlert(alert, .milliseconds(300)), toDeliver: .showAlert(alert))
    }
    
    func test_showBlockCardAlert_shouldDeliverShowAlert() {
        
        let sut = makeSUT()
        
        let id = UUID()
        let alert = AlertModelOf.alertBlockCard(.card(), id)
        
        expect(sut, with: .delayAlert(alert, .seconds(1)), toDeliver: .showAlert(alert))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ProductProfileNavigationEffectHandler
    private typealias EventNavigation = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias MakeCardGuardianViewModel = (AnySchedulerOfDispatchQueue) -> CardGuardianViewModel
        
    private typealias OpenPanelSpy = () -> Void
    
    private func makeSUT(
        buttons: [CardGuardianState._Button] = .preview,
        event: CardGuardianEvent? = nil,
        guardianCard: @escaping SUT.GuardCard = {_ in },
        toggleVisibilityOnMain: @escaping SUT.ToggleVisibilityOnMain = {_ in },
        showContacts: @escaping SUT.ShowContacts = {},
        changePin: @escaping SUT.GuardCard = {_ in },
        scheduler: AnySchedulerOfDispatchQueue = .immediate,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let cardGuardianReduce = CardGuardianReducer()
        
        let cardGuardianHandleEffect = CardGuardianEffectHandler()
        
        let makeCardGuardianViewModel: MakeCardGuardianViewModel =  {
            
            .init(
                initialState: .init(buttons: buttons),
                reduce: cardGuardianReduce.reduce(_:_:),
                handleEffect: cardGuardianHandleEffect.handleEffect(_:_:),
                scheduler: $0
            )
        }
        
        let sut = SUT(
            makeCardGuardianViewModel: makeCardGuardianViewModel,
            guardianCard: guardianCard,
            toggleVisibilityOnMain: toggleVisibilityOnMain,
            showContacts: showContacts,
            changePin: changePin,
            scheduler: scheduler
        )
        
        trackForMemoryLeaks(cardGuardianReduce, file: file, line: line)
        trackForMemoryLeaks(cardGuardianHandleEffect, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

private extension Card {
    
    static func card(
        status: CardGuardianStatus = .active
    ) -> Card {
        
        .init(
            cardId: 1,
            cardNumber: "111",
            cardGuardianStatus: status
        )
    }
}

private extension Product {
    
    static let product: Self = .init(
        productID: 1,
        visibility: false)
}
