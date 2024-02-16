//
//  ProductProfileNavigationEffectHandlerTests.swift
//
//
//  Created by Andryusina Nataly on 14.02.2024.
//

@testable import ProductProfile
import CardGuardianModule
import RxViewModel
import UIPrimitives
import XCTest

extension ProductProfileNavigationEffectHandler: EffectHandler {}

final class ProductProfileNavigationEffectHandlerTests: XCTestCase {
    
    // MARK: test showAlert
    
    func test_showCVVAlert_shouldDeliverShowAlert() {
        
        let sut = makeSUT()
        
        let id = UUID()
        let alert = Alerts.alertCVV(id)
        
        expect(sut, with: .delayAlert(alert, 0), toDeliver: .showAlert(alert))
    }
    
    func test_showCardBlockedAlert_shouldDeliverShowAlert() {
        
        let sut = makeSUT()

        let id = UUID()
        let alert = Alerts.alertCardBlocked(id)
        
        expect(sut, with: .delayAlert(alert, 0), toDeliver: .showAlert(alert))
    }
    
    func test_showBlockCardAlert_shouldDeliverShowAlert() {
        
        let sut = makeSUT()

        let id = UUID()
        let alert = Alerts.alertBlockCard(.card(), id)
        
        expect(sut, with: .delayAlert(alert, 0), toDeliver: .showAlert(alert))
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
        guardianCard: @escaping SUT.CardGuardianAction = {_ in },
        visibilityOnMain: @escaping SUT.VisibilityOnMainAction = {_ in },
        showContacts: @escaping SUT.EmptyAction = {},
        changePin: @escaping SUT.CardGuardianAction = {_ in },
        scheduler: AnySchedulerOfDispatchQueue = .immediate,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let cardGuardianReduce = CardGuardianReducer().reduce(_:_:)
        
        let makeCardGuardianViewModel: MakeCardGuardianViewModel =  {
            
            .init(
                initialState: .init(buttons: buttons),
                reduce: cardGuardianReduce,
                handleEffect: { _,_ in },
                scheduler: $0
            )
        }
        
        let sut = SUT(
            makeCardGuardianViewModel: makeCardGuardianViewModel,
            guardianCard: guardianCard,
            visibilityOnMain: visibilityOnMain,
            showContacts: showContacts,
            changePin: changePin,
            scheduler: scheduler
        )
        
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
