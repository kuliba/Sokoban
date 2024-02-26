//
//  ProductProfileNavigationEffectHandlerTests.swift
//
//
//  Created by Andryusina Nataly on 14.02.2024.
//

@testable import ProductProfile
import CardGuardianModule
import ActivateSlider
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
        
        expect(sut, with: .delayAlert(alert, 0), toDeliver: .showAlert(alert))
    }
    
    func test_showCardBlockedAlert_shouldDeliverShowAlert() {
        
        let sut = makeSUT()
        
        let id = UUID()
        let alert = AlertModelOf.alertCardBlocked(id)
        
        expect(sut, with: .delayAlert(alert, 0), toDeliver: .showAlert(alert))
    }
    
    func test_showBlockCardAlert_shouldDeliverShowAlert() {
        
        let sut = makeSUT()
        
        let id = UUID()
        let alert = AlertModelOf.alertBlockCard(.card(), id)
        
        expect(sut, with: .delayAlert(alert, 0), toDeliver: .showAlert(alert))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ProductProfileNavigationEffectHandler
    private typealias EventNavigation = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias MakeCardGuardianViewModel = (AnySchedulerOfDispatchQueue) -> CardGuardianViewModel
    
    private typealias MakeCardViewModel = (AnySchedulerOfDispatchQueue) -> CardViewModel
    
    private typealias OpenPanelSpy = () -> Void
    
    private func makeSUT(
        buttons: [CardGuardianState._Button] = .preview,
        event: CardGuardianEvent? = nil,
        guardianCard: @escaping SUT.CardGuardianAction = {_ in },
        toggleVisibilityOnMain: @escaping SUT.VisibilityOnMainAction = {_ in },
        showContacts: @escaping SUT.EmptyAction = {},
        changePin: @escaping SUT.CardGuardianAction = {_ in },
        scheduler: AnySchedulerOfDispatchQueue = .immediate,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let cardGuardianReduce = CardGuardianReducer()
        
        let makeCardGuardianViewModel: MakeCardGuardianViewModel =  {
            
            .init(
                initialState: .init(buttons: buttons),
                reduce: cardGuardianReduce.reduce(_:_:),
                handleEffect: { _,_ in },
                scheduler: $0
            )
        }
        
        let cardReduce = CardReducer()
        
        let makeCardViewModel: MakeCardViewModel =  {
            
            .init(
                initialState: .status(nil),
                reduce: cardReduce.reduce(_:_:),
                handleEffect: { _,_ in },
                scheduler: $0
            )
        }
        
        let sut = SUT(
            makeCardGuardianViewModel: makeCardGuardianViewModel,
            makeCardViewModel: makeCardViewModel,
            guardianCard: guardianCard,
            toggleVisibilityOnMain: toggleVisibilityOnMain,
            showContacts: showContacts,
            changePin: changePin,
            scheduler: scheduler
        )
        
        trackForMemoryLeaks(cardGuardianReduce, file: file, line: line)
        trackForMemoryLeaks(cardReduce, file: file, line: line)
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
