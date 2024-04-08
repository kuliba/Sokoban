//
//  AnywayPaymentContextTests.swift
//
//
//  Created by Igor Malyarov on 08.04.2024.
//

struct AnywayPaymentContext: Equatable {
    
    let payment: AnywayPayment
    var staged = Staged()
}

extension AnywayPaymentContext {
    
    typealias Staged = Set<AnywayPayment.Element.StringID>
}

extension AnywayPaymentContext {
    
    mutating func stage() {
        
        staged = .init(payment.elements.parameterIDs)
    }
}

private extension Array where Element == AnywayPayment.Element {
    
    var parameterIDs: [AnywayPayment.Element.StringID] {
        
        compactMap(\.parameterID)
    }
}

private extension AnywayPayment.Element {
    
    var parameterID: AnywayPayment.Element.StringID? {
        
        guard case let .parameter(parameter) = self else { return nil }
        return parameter.field.id
    }
}

import AnywayPaymentCore
import XCTest

final class AnywayPaymentContextTests: XCTestCase {
    
    func test_state_shouldNotChangeEmptyStagedOnEmptyElements() {
        
        var context = makeAnywayPaymentContext(elements: [])
        XCTAssert(context.staged.isEmpty)
        
        context.stage()
        
        XCTAssert(context.staged.isEmpty)
    }
    
    func test_state_shouldNotChangeEmptyStagedOnEmptyParameters() {
        
        var context = makeAnywayPaymentContext(
            elements: [.field(makeAnywayPaymentField())]
        )
        XCTAssert(context.staged.isEmpty)
        
        context.stage()
        
        XCTAssert(context.staged.isEmpty)
    }
    
    func test_state_shouldAppendParameterIDsToEmptyStaged() {
        
        let (parameter1, parameter2) = makeTwoParameters()
        var context = makeAnywayPaymentContext(
            elements: [.parameter(parameter1), .parameter(parameter2), .field(makeAnywayPaymentField())]
        )
        XCTAssert(context.staged.isEmpty)
        
        context.stage()
        
        XCTAssertNoDiff(
            context.staged,
            [parameter1.field.id, parameter2.field.id]
        )
    }
    
    func test_state_shouldAppendParameterIDToNonEmptyStaged() {
        
        let (parameter1, parameter2) = makeTwoParameters()
        var context = makeAnywayPaymentContext(
            elements: [.parameter(parameter1), .parameter(parameter2), .field(makeAnywayPaymentField())],
            staged: [parameter1.field.id]
        )
        XCTAssertFalse(context.staged.isEmpty)

        context.stage()
        
        XCTAssertNoDiff(
            context.staged,
            [parameter1.field.id, parameter2.field.id]
        )
    }
    
    // MARK: - Helpers
    
    private typealias Parameter = AnywayPayment.Element.Parameter
    
    private func makeAnywayPaymentContext(
        elements: [AnywayPayment.Element],
        staged: AnywayPaymentContext.Staged = []
    ) -> AnywayPaymentContext {
        
        let payment = makeAnywayPayment(elements: elements)
        return .init(payment: payment, staged: staged)
    }
    
    private func makeTwoParameters(
    ) -> (parameter1: Parameter, parameter2: Parameter) {
        
        let parameter1 = makeAnywayPaymentParameter()
        let parameter2 = makeAnywayPaymentParameter()
        
        return (parameter1, parameter2)
    }
}
