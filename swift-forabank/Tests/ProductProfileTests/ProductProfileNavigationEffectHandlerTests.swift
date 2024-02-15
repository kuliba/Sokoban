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
    
    func test_create_shouldCallOpenPanel() {
        
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
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
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
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ProductProfileNavigationEffectHandler
    private typealias Event = ProductProfileEvent
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
    
    private func assert(
        event: Event._ProductProfileEvent
    ) {
        var result: Event._ProductProfileEvent? = .none
        var count = 0
        
        let (sut, _) = makeSUT { _ in
            count += 1
            result = .cardGuardian
        } visibilityOnMain: { _ in
            count += 1
            result = .visibilityOnMain
        } showContacts: {
            count += 1
            result = .showContacts
        } changePin: { _ in
            count += 1
            result = .changePin
        }
        
        XCTAssertNoDiff(count, 0)
        
        sut.handleEffect(.sendRequest(Event.createEvent(event: event))) { _ in }
        
        XCTAssertNoDiff(count, 1)
        XCTAssertNoDiff(result, event)
    }
}

private extension ProductProfileEvent {
    
    enum _ProductProfileEvent {
        
        case cardGuardian
        case visibilityOnMain
        case changePin
        case showContacts
    }
    
    static func createEvent(
        cardStatus: CardGuardianStatus = .active,
        productVisibility: Product.Visibility = true,
        event: _ProductProfileEvent
    ) -> ProductProfileEvent {
        
        switch event {
        case .cardGuardian:
            return .cardGuardian(.newCard(status: cardStatus))
        case .visibilityOnMain:
            return .visibilityOnMain(.init(productID: 1, visibility: productVisibility))
        case .changePin:
            return .changePin(.newCard(status: cardStatus))
        case .showContacts:
            return .showContacts
        }
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

private extension ProductProfileNavigation.Event {
    
    enum _Event: Equatable {
        case closeAlert
        case create
        case open
        case cardGuardianInput
        case dismissDestination
        case showAlert
        case alertInput
    }
    
    var value: _Event {
        
        switch self {
        case .closeAlert:
            return .closeAlert
        case .create:
            return .create
        case .open:
            return .open
        case .cardGuardianInput:
            return .cardGuardianInput
        case .dismissDestination:
            return .dismissDestination
        case .showAlert:
            return .showAlert
        case .alertInput:
            return .alertInput
        }
    }
}
