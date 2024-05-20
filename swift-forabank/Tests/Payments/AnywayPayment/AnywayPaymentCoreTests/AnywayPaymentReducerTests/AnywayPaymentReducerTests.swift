//
//  AnywayPaymentReducerTests.swift
//
//
//  Created by Igor Malyarov on 20.05.2024.
//

enum AnywayPaymentEvent: Equatable {
    
    case setValue(String, for: ParameterID)
}

extension AnywayPaymentEvent {
    
    typealias ParameterID = AnywayPayment.Element.Parameter.Field.ID
}

enum AnywayPaymentEffect: Equatable {}

final class AnywayPaymentReducer {}

extension AnywayPaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        
        switch event {
        case let .setValue(value, for: parameterID):
            reduce(&state, value, parameterID)
        }
        
        return (state, nil)
    }
}

extension AnywayPaymentReducer {
    
    typealias State = AnywayPayment
    typealias Event = AnywayPaymentEvent
    typealias Effect = AnywayPaymentEffect
}

private extension AnywayPaymentReducer {
    
    func reduce(
        _ state: inout State,
        _ value: String,
        _ parameterID: Event.ParameterID
    ) {
        state.setValue(value, for: parameterID)
    }
}

import ForaTools

private extension AnywayPayment {
    
    mutating func setValue(
        _ value: String,
        for parameterID: ParameterID
    ) {
        guard let index = elements.firstIndex(matching: parameterID),
              case var .parameter(parameter) = elements[index]
        else { return }
        
        elements[index] = .parameter(parameter.updating(value: value))
    }
    
    typealias ParameterID = AnywayPayment.Element.Parameter.Field.ID
}

private extension AnywayPayment.Element.Parameter {
    
    func updating(value: Field.Value) -> Self {
        
        return .init(
            field: .init(id: field.id, value: value),
            masking: masking,
            validation: validation,
            uiAttributes: uiAttributes
        )
    }
}

private extension Array where Element == AnywayPayment.Element {
    
    func firstIndex(matching id: ParameterID) -> Index? {
        
        firstIndex {
            
            switch $0 {
            case let .parameter(parameter):
                return parameter.field.id == id
                
            default:
                return false
            }
        }
    }
    
    typealias ParameterID = AnywayPayment.Element.Parameter.Field.ID
}

private extension AnywayPaymentReducer {}

import AnywayPaymentCore
import AnywayPaymentDomain
import XCTest

final class AnywayPaymentReducerTests: XCTestCase {
    
    // MARK: - setValue
    
    func test_setValue_shouldNotChangeStateOnEmpty() {
        
        let missingID = makeParameterID()
        let state = makeEmptyState()
        
        assertState(.setValue(anyMessage(), for: missingID), on: state)
        assertMissingID(state, missingID)
    }
    
    func test_setValue_shouldNotDeliverEffectOnEmpty() {
        
        let missingID = makeParameterID()
        let state = makeEmptyState()
        
        assert(.setValue(anyMessage(), for: missingID), on: state, effect: nil)
        assertMissingID(state, missingID)
    }
    
    func test_setValue_shouldNotChangeStateOnMissingParameterID() {
        
        let missingID = makeParameterID()
        let state = makeState(
            elements: [makeAnywayPaymentParameterElement()]
        )
        
        assertState(.setValue(anyMessage(), for: missingID), on: state)
        assertMissingID(state, missingID)
    }
    
    func test_setValue_shouldNotDeliverEffectOnMissingParameterID() {
        
        let missingID = makeParameterID()
        let state = makeState(
            elements: [makeAnywayPaymentParameterElement()]
        )
        
        assert(.setValue(anyMessage(), for: missingID), on: state, effect: nil)
        assertMissingID(state, missingID)
    }
    
    func test_setValue_shouldChangeParameterValueForGivenID() {
        
        let value = anyMessage()
        let parameterID = makeParameterID()
        let parameter = makeAnywayPaymentParameter(id: parameterID.rawValue)
        let state = makeState(elements: [.parameter(parameter)])
        
        assertState(.setValue(value, for: parameterID), on: state) {
            
            let parameter = AnywayPayment.Element.Parameter(
                field: .init(
                    id: .init(parameterID.rawValue),
                    value: .init(value)
                ),
                masking: parameter.masking,
                validation: parameter.validation,
                uiAttributes: parameter.uiAttributes
            )
            $0.elements = [.parameter(parameter)]
        }
    }
    
    func test_setValue_shouldNotDeliverEffect() {
        
        let value = anyMessage()
        let parameterID = makeParameterID()
        let parameter = makeAnywayPaymentParameter(id: parameterID.rawValue)
        let state = makeState(elements: [.parameter(parameter)])
        
        assert(.setValue(value, for: parameterID), on: state, effect: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = AnywayPaymentReducer
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
    
    private typealias UpdateStateToExpected<State> = (_ state: inout State) -> Void
    
    private func assertState(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        updateStateToExpected: UpdateStateToExpected<State>? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT()
        
        var expectedState = state
        updateStateToExpected?(&expectedState)
        
        let (receivedState, _) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedState,
            expectedState,
            "\nExpected \(expectedState), but got \(receivedState) instead.",
            file: file, line: line
        )
    }
    
    private func assert(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        effect expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT()
        
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
    
    private func assertMissingID(
        _ state: State,
        _ missingID: AnywayPayment.Element.Parameter.Field.ID,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let iDs = Set(state.elements.parameters.map(\.field.id))
        
        XCTAssertFalse(iDs.contains(missingID), "Expected id \(missingID) to be missing but was found in state \(state).", file: file, line: line)
    }
    
    private func makeParameterID(
        id: String = UUID().uuidString
    ) -> AnywayPayment.Element.Parameter.Field.ID {
        
        .init(id)
    }
    
    private func makeEmptyState(
    ) -> State {
        
        let state = makeState(elements: [])
        precondition(state.elements.isEmpty)
        return state
    }
    
    private func makeState(
        elements: [AnywayPayment.Element],
        infoMessage: String? = nil,
        isFinalStep: Bool = false,
        isFraudSuspected: Bool = false,
        puref: AnywayPayment.Puref = .init(anyMessage())
    ) -> State {
        
        return .init(
            elements: elements,
            infoMessage: infoMessage,
            isFinalStep: isFinalStep,
            isFraudSuspected: isFraudSuspected,
            puref: puref
        )
    }
}

private extension Array where Element == AnywayPayment.Element {
    
    var parameters: [AnywayPayment.Element.Parameter] {
        
        compactMap {
            
            guard case let .parameter(parameter) = $0 else { return nil }
            
            return parameter
        }
    }
}
