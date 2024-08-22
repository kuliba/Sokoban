//
//  PaymentsTransfersToolbarReducerTests.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

struct PaymentsTransfersToolbarState<Profile, QR> {
    
    var navigation: Navigation?
}

extension PaymentsTransfersToolbarState {
    
    enum Navigation {
        
        case profile(Profile)
        case qr(QR)
    }
}

extension PaymentsTransfersToolbarState: Equatable where Profile: Equatable, QR: Equatable {}
extension PaymentsTransfersToolbarState.Navigation: Equatable where Profile: Equatable, QR: Equatable {}

enum PaymentsTransfersToolbarEvent<Profile, QR> {
    
    case dismiss
    case profile(Profile)
    case qr(QR)
    case select(Select)
}

extension PaymentsTransfersToolbarEvent: Equatable where Profile: Equatable, QR: Equatable {}

extension PaymentsTransfersToolbarEvent {
    
    enum Select {
        
        case profile, qr
    }
}

enum PaymentsTransfersToolbarEffect: Equatable {
    
    case select(Select)
}

extension PaymentsTransfersToolbarEffect {
    
    enum Select {
        
        case profile, qr
    }
}

final class PaymentsTransfersToolbarReducer<Profile, QR> {}

extension PaymentsTransfersToolbarReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .dismiss:
            state.navigation = nil
            
        case let .profile(profile):
            state.navigation = .profile(profile)
            
        case let .qr(qr):
            state.navigation = .qr(qr)
            
        case let .select(select):
            self.select(&state, &effect, with: select)
        }
        
        return (state, effect)
    }
}

extension PaymentsTransfersToolbarReducer {
    
    typealias State = PaymentsTransfersToolbarState<Profile, QR>
    typealias Event = PaymentsTransfersToolbarEvent<Profile, QR>
    typealias Effect = PaymentsTransfersToolbarEffect
}

private extension PaymentsTransfersToolbarReducer {
    
    func select(
        _ state: inout State,
        _ effect: inout Effect?,
        with select: Event.Select
    ) {
        state.navigation = nil
        
        switch select {
        case .profile:
            effect = .select(.profile)
            
        case .qr:
            effect = .select(.qr)
        }
    }
}

struct PaymentsTransfersToolbarEffectHandlerMicroServices<Profile, QR> {
    
    let makeProfile: MakeProfile
    let makeQR: MakeQR
    
    init(
        makeProfile: @escaping MakeProfile,
        makeQR: @escaping MakeQR
    ) {
        self.makeProfile = makeProfile
        self.makeQR = makeQR
    }
}

extension PaymentsTransfersToolbarEffectHandlerMicroServices {
    
    typealias MakeProfile = (@escaping (Profile) -> Void) -> Void
    typealias MakeQR = (@escaping (QR) -> Void) -> Void
}

final class PaymentsTransfersToolbarEffectHandler<Profile, QR> {
    
    private let microServices: MicroServices
    
    init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    typealias MicroServices = PaymentsTransfersToolbarEffectHandlerMicroServices<Profile, QR>
}

extension PaymentsTransfersToolbarEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .select(select):
            handleSelect(select, dispatch)
        }
    }
}

extension PaymentsTransfersToolbarEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentsTransfersToolbarEvent<Profile, QR>
    typealias Effect = PaymentsTransfersToolbarEffect
}

private extension PaymentsTransfersToolbarEffectHandler {
    
    func handleSelect(
        _ select: Effect.Select,
        _ dispatch: @escaping Dispatch
    ) {
        switch select {
        case .profile:
            microServices.makeProfile { dispatch(.profile($0)) }

        case .qr:
            microServices.makeQR { dispatch(.qr($0)) }
        }
    }
}

import XCTest

final class PaymentsTransfersToolbarEffectHandlerTests: PaymentsTransfersToolbarTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, makeProfile, makeQR) = makeSUT()
        
        XCTAssertEqual(makeProfile.callCount, 0)
        XCTAssertEqual(makeQR.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - select
    
    func test_select_profile_shouldCallMakeProfile() {
        
        let (sut, makeProfile, _) = makeSUT()
        
        sut.handleEffect(.select(.profile)) { _ in }
        
        XCTAssertEqual(makeProfile.callCount, 1)
    }
    
    func test_select_profile_shouldDeliverProfile() {
        
        let profile = makeProfile()
        let (sut, makeProfile, _) = makeSUT()
        
        expect(sut, with: .select(.profile), toDeliver: .profile(profile)) {
            
            makeProfile.complete(with: profile)
        }
    }
    
    func test_select_qr_shouldCallMakeProfile() {
        
        let (sut, _, makeQR) = makeSUT()
        
        sut.handleEffect(.select(.qr)) { _ in }
        
        XCTAssertEqual(makeQR.callCount, 1)
    }
    
    func test_select_qr_shouldDeliverQR() {
        
        let qr = makeQR()
        let (sut, _, makeQR) = makeSUT()
        
        expect(sut, with: .select(.qr), toDeliver: .qr(qr)) {
            
            makeQR.complete(with: qr)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersToolbarEffectHandler<Profile, QR>
    private typealias MakeProfileSpy = Spy<Void, Profile>
    private typealias MakeQRSpy = Spy<Void, QR>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        makeProfile: MakeProfileSpy,
        makeQR: MakeQRSpy
    ) {
        let makeProfile = MakeProfileSpy()
        let makeQR = MakeQRSpy()
        let sut = SUT(microServices: .init(
            makeProfile: makeProfile.process(completion:),
            makeQR: makeQR.process(completion:)
        ))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(makeProfile, file: file, line: line)
        trackForMemoryLeaks(makeQR, file: file, line: line)
        
        return (sut, makeProfile, makeQR)
    }
    
    private func expect(
        _ sut: SUT? = nil,
        with effect: SUT.Effect,
        toDeliver expectedEvents: SUT.Event...,
        on action: @escaping () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT().sut
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedEvents.count
        var events = [SUT.Event]()
        
        sut.handleEffect(effect) {
            
            events.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(events, expectedEvents, file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
}

class PaymentsTransfersToolbarTests: XCTestCase {
    
    struct Profile: Equatable {
        
        let value: String
    }
    
    func makeProfile(
        _ value: String = anyMessage()
    ) -> Profile {
        
        return .init(value: value)
    }
    
    struct QR: Equatable {
        
        let value: String
    }
    
    func makeQR(
        _ value: String = anyMessage()
    ) -> QR {
        
        return .init(value: value)
    }
}

final class PaymentsTransfersToolbarReducerTests: PaymentsTransfersToolbarTests {
    
    // MARK: - dismiss
    
    func test_dismiss_shouldSetNavigationToNil() {
        
        let state = makeState(navigation: anyNavigation())
        
        assert(state, event: .dismiss) {
            
            $0.navigation = nil
        }
    }
    
    func test_dismiss_shouldNotDeliverEffect() {
        
        let state = makeState(navigation: anyNavigation())
        
        assert(state, event: .dismiss, delivers: nil)
    }
    
    func test_dismiss_shouldNotChangeNilNavigation() {
        
        let state = makeState(navigation: nil)
        
        assert(state, event: .dismiss) {
            
            $0.navigation = nil
        }
    }
    
    func test_dismiss_shouldNotDeliverEffectOnNilNavigation() {
        
        let state = makeState(navigation: nil)
        
        assert(state, event: .dismiss, delivers: nil)
    }
    
    // MARK: - profile
    
    func test_profile_shouldChangeNilNavigation() {
        
        let profile = makeProfile()
        let state = makeState(navigation: nil)
        
        assert(state, event: .profile(profile)) {
            
            $0.navigation = .profile(profile)
        }
    }
    
    func test_profile_shouldNotDeliverEffectOnNilNavigation() {
        
        let state = makeState(navigation: nil)
        
        assert(state, event: .profile(makeProfile()), delivers: nil)
    }
        
    func test_profile_shouldChangeNonNilNavigation() {
        
        let profile = makeProfile()
        let state = makeState(navigation: anyNavigation())
        
        assert(state, event: .profile(profile)) {
            
            $0.navigation = .profile(profile)
        }
    }
    
    func test_profile_shouldNotDeliverEffectOnNonNilNavigation() {
        
        let state = makeState(navigation: anyNavigation())
        
        assert(state, event: .profile(makeProfile()), delivers: nil)
    }
        
    // MARK: - qr
    
    func test_qr_shouldChangeNilNavigation() {
        
        let qr = makeQR()
        let state = makeState(navigation: nil)
        
        assert(state, event: .qr(qr)) {
            
            $0.navigation = .qr(qr)
        }
    }
    
    func test_qr_shouldNotDeliverEffectOnNilNavigation() {
        
        let state = makeState(navigation: nil)
        
        assert(state, event: .qr(makeQR()), delivers: nil)
    }
        
    func test_qr_shouldChangeNonNilNavigation() {
        
        let qr = makeQR()
        let state = makeState(navigation: anyNavigation())
        
        assert(state, event: .qr(qr)) {
            
            $0.navigation = .qr(qr)
        }
    }
    
    func test_qr_shouldNotDeliverEffectOnNonNilNavigation() {
        
        let state = makeState(navigation: anyNavigation())
        
        assert(state, event: .qr(makeQR()), delivers: nil)
    }
        
    // MARK: - select
    
    func test_select_profile_shouldNotChangeNilState() {
        
        let state = makeState(navigation: nil)
        
        assert(state, event: .select(.qr))
    }
    
    func test_select_profile_shouldDeliverEffectOnNilState() {
        
        let state = makeState(navigation: nil)
        
        assert(state, event: .select(.profile), delivers: .select(.profile))
    }
    
    func test_select_profile_shouldResetNonNilState() {
        
        let state = makeState(navigation: anyNavigation())
        
        assert(state, event: .select(.profile)) {
            
            $0.navigation = nil
        }
    }
    
    func test_select_profile_shouldDeliverEffectOnNonNilState() {
        
        let state = makeState(navigation: nil)
        
        assert(state, event: .select(.profile), delivers: .select(.profile))
    }
    
    func test_select_qr_shouldNotChangeNilState() {
        
        let state = makeState(navigation: nil)
        
        assert(state, event: .select(.qr))
    }
    
    func test_select_qr_shouldDeliverEffectOnNilState() {
        
        let state = makeState(navigation: nil)
        
        assert(state, event: .select(.qr), delivers: .select(.qr))
    }
    
    func test_select_qr_shouldResetNonNilState() {
        
        let state = makeState(navigation: anyNavigation())
        
        assert(state, event: .select(.qr)) {
            
            $0.navigation = nil
        }
    }
    
    func test_select_qr_shouldDeliverEffectOnNonNilState() {
        
        let state = makeState(navigation: nil)
        
        assert(state, event: .select(.qr), delivers: .select(.qr))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersToolbarReducer<Profile, QR>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
        navigation: SUT.State.Navigation? = nil
    ) -> SUT.State {
        
        return .init(navigation: navigation)
    }
    
    private func anyNavigation(
    ) -> SUT.State.Navigation {
        
        return .profile(makeProfile())
    }
    
    @discardableResult
    private func assert(
        sut: SUT? = nil,
        _ state: SUT.State,
        event: SUT.Event,
        updateStateToExpected: ((inout SUT.State) -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.State {
        
        let sut = sut ?? makeSUT(file: file, line: line)
        
        var expectedState = state
        updateStateToExpected?(&expectedState)
        
        let (receivedState, _) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedState,
            expectedState,
            "\nExpected \(String(describing: expectedState)), but got \(String(describing: receivedState)) instead.",
            file: file, line: line
        )
        
        return receivedState
    }
    
    @discardableResult
    private func assert(
        sut: SUT? = nil,
        _ state: SUT.State,
        event: SUT.Event,
        delivers expectedEffect: SUT.Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.Effect? {
        
        let sut = sut ?? makeSUT(file: file, line: line)
        
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
        
        return receivedEffect
    }
}
