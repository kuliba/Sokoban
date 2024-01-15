//
//  FastPaymentsSettingsRxReducerTests.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

final class FastPaymentsSettingsRxReducer {
    
}

extension FastPaymentsSettingsRxReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .appear:
            (state, effect) = handleAppear(state)
            
        case let .loadedUserPaymentSettings(userPaymentSettings):
            state = handleLoadedUserPaymentSettings(userPaymentSettings)
            
        case .activateContract:
            fatalError("unimplemented")
        case .deactivateContract:
            fatalError("unimplemented")
        case .resetStatus:
            fatalError("unimplemented")
        case .setBankDefault:
            fatalError("unimplemented")
        case .prepareSetBankDefault:
            fatalError("unimplemented")
        case .confirmSetBankDefault:
            fatalError("unimplemented")
        }
        
        return (state, effect)
    }
}

private extension FastPaymentsSettingsRxReducer {
    
    func handleAppear(
        _ state: State
    ) -> (State, Effect) {
        
        var state = state
        state.status = .inflight
        
        return (state, .getUserPaymentSettings)
    }
    
    func handleLoadedUserPaymentSettings(
        _ userPaymentSettings: UserPaymentSettings
    ) -> State {
        
        .init(userPaymentSettings: userPaymentSettings)
    }
}

extension FastPaymentsSettingsRxReducer {
    
    typealias State = FastPaymentsSettingsState
    typealias Event = FastPaymentsSettingsEvent
    typealias Effect = FastPaymentsSettingsEffect
}

import FastPaymentsSettings
import XCTest

final class FastPaymentsSettingsRxReducerTests: XCTestCase {
    
    // MARK: - appear
    
    func test_appear_shouldSetStatusToInflight_emptyState() {
        
        let emptyState: State = .init()
        
        XCTAssertNoDiff(
            reduce(makeSUT(), emptyState, .appear).state,
            .init(status: .inflight)
        )
    }
    
    func test_appear_shouldDeliverGetUserPaymentSettingsEffect_emptyState() {
        
        let EmptyState: State = .init()
        
        XCTAssertNoDiff(
            reduce(makeSUT(), EmptyState, .appear).effect,
            .getUserPaymentSettings
        )
    }
    
    func test_appear_shouldSetStatusToInflight_nonEmptyState() {
        
        let userPaymentSettings = anyContractedSettings()
        let state: State = .init(userPaymentSettings: userPaymentSettings)
        
        XCTAssertNoDiff(
            reduce(makeSUT(), state, .appear).state,
            .init(
                userPaymentSettings: userPaymentSettings,
                status: .inflight
            )
        )
    }
    
    func test_appear_shouldDeliverGetUserPaymentSettingsEffect_nonEmptyState() {
        
        let userPaymentSettings = anyContractedSettings()
        let state: State = .init(userPaymentSettings: userPaymentSettings)
        
        XCTAssertNoDiff(
            reduce(makeSUT(), state, .appear).effect,
            .getUserPaymentSettings
        )
    }
    
    // MARK: - loadedUserPaymentSettings
    
    func test_loadedUserPaymentSettings_shouldSetStateToSettingsWithoutStatus_emptyState() {
        
        let state: State = .init(status: .inflight)
        let loaded = anyContractedSettings()
        
        XCTAssertNoDiff(
            reduce(makeSUT(), state, .loadedUserPaymentSettings(loaded)).state,
            .init(
                userPaymentSettings: loaded,
                status: nil
            )
        )
    }
    
    func test_loadedUserPaymentSettings_shouldNotDeliverEffect_emptyState() {
        
        let state: State = .init(status: .inflight)
        let loaded = anyContractedSettings()
        
        XCTAssertNoDiff(
            reduce(makeSUT(), state, .loadedUserPaymentSettings(loaded)).effect,
            nil
        )
    }
    
    func test_loadedUserPaymentSettings_shouldSetStateToLoadedSettingsWithoutStatus_nonEmptyState() {
        
        let contracted = anyContractedSettings()
        let loaded = anyContractedSettings()
        let state: State = .init(
            userPaymentSettings: contracted,
            status: .inflight
        )
        
        XCTAssertNoDiff(
            reduce(makeSUT(), state, .loadedUserPaymentSettings(loaded)).state,
            .init(
                userPaymentSettings: loaded,
                status: nil
            )
        )
    }
    
    func test_loadedUserPaymentSettings_shouldNotDeliverEffect_nonEmptyState() {
        
        let contracted = anyContractedSettings()
        let loaded = anyContractedSettings()
        let state: State = .init(
            userPaymentSettings: contracted,
            status: .inflight
        )
        
        XCTAssertNoDiff(
            reduce(makeSUT(), state, .loadedUserPaymentSettings(loaded)).effect,
            nil
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FastPaymentsSettingsRxReducer
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
}
