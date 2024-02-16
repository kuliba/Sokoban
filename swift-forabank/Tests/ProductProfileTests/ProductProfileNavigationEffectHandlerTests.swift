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

final class ProductProfileNavigationEffectHandlerTests: XCTestCase {
    
    // MARK: test init
    
    func test_init_shouldNotCallCollaborators() {
        
        var count = 0
        
        (_, _) = makeSUT { _ in
            count = 1
        } visibilityOnMain: { _ in
            count = 2
        } showContacts: {
            count = 3
        } changePin: { _ in
            count = 4
        }
        
        XCTAssertNoDiff(count, 0)
    }
    
    // MARK: test create
    
   /* func test_create_shouldCallOpenPanel() {
        
        var event: EventNavigation._Event? = .none
        
        let (sut, _) = makeSUT()
        
        sut.handleEffect(.create) {
            
            event = $0.value
        }
        
        XCTAssertNoDiff(event, .open)
    }
    
    // MARK: test show panel
    
    func test_create_shouldShowPanel() {
        
        var event: EventNavigation._Event? = .none
        
        let (sut, _) = makeSUT()
        
        sut.handleEffect(.create) {
            
            event = $0.value
        }
                
        XCTAssertNoDiff(event, .open)
    }
    
    // MARK: test show alert
    
    func test_delayAlert_shouldShowAlert() {
        
        var event: EventNavigation._Event? = .none
        
        let (sut, _) = makeSUT()
        
        sut.handleEffect(.delayAlert(Alerts.alertBlockCard(.newCard(status: .active)), 0)) {
            
            event = $0.value
        }
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNoDiff(event, .showAlert)
    }
    
    // MARK: - tap alert button show/hide on main
    
    func test_tap_shouldCallOnlyVisibilityOnMain() {
        
        assert(event: .visibilityOnMain)
    }
    
    // MARK: - tap changePin
    
    func test_tap_shouldCallOnlyChangePin() {
        
        assert(event: .changePin)
    }
    
    // MARK: - tap alert button block/unblock
    
    func test_tap_shouldCallOnlyCardGuardian() {
        
        assert(event: .cardGuardian)
    }
    
    // MARK: - tap alert button showContacts
    
    func test_tap_shouldCallOnlyShowContacts() {
        
        assert(event: .showContacts)
    }*/
    
    // MARK: - Helpers
    
    private typealias SUT = ProductProfileNavigationEffectHandler
    private typealias EventNavigation = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias MakeCardGuardianViewModel = (AnySchedulerOfDispatchQueue) -> CardGuardianViewModel
    
    private func makeSUT(
        buttons: [CardGuardianState._Button] = .preview,
        event: CardGuardianEvent? = nil,
        guardianCard: @escaping SUT.CardGuardianAction = {_ in },
        visibilityOnMain: @escaping SUT.VisibilityOnMainAction = {_ in },
        showContacts: @escaping SUT.EmptyAction = {},
        changePin: @escaping SUT.CardGuardianAction = {_ in },
        scheduler: AnySchedulerOfDispatchQueue = .makeMain(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        cardGuardianViewModel: MakeCardGuardianViewModel
    ) {
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
        
        return (sut, makeCardGuardianViewModel)
    }
    
  /*  private func assertProductProfileEffect(
        // Spy
        effect: ProductProfileEffect
    ) {
        var result: ProductProfileEffect?
        
        let exp = expectation(description: "wait for handle")

        let (sut, _) = makeSUT { _ in
            result = .cardGuardian
            exp.fulfill()

        } visibilityOnMain: { _ in
            result = .visibilityOnMain
            exp.fulfill()

        } showContacts: {
            result = .showContacts
            exp.fulfill()

        } changePin: { _ in
            result = .changePin
            exp.fulfill()
        }
        
        sut.handleEffect(.(Event.createEvent(event: event))) { _ in }

        wait(for: [exp], timeout: 0.5)
        
        XCTAssertNoDiff(result, event)
    }*/
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
