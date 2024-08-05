//
//  AnywayPaymentTransactionReducerTests.swift
//
//
//  Created by Igor Malyarov on 21.05.2024.
//

import AnywayPaymentAdapters
import AnywayPaymentBackend
import AnywayPaymentCore
import AnywayPaymentDomain
import XCTest

class AnywayPaymentTransactionReducerTests: XCTestCase {
    
    func test_init() {
        
        _ = makeSUT()
    }
    
    func test_dismissRecoverableError_shouldNotChangeTerminatedState() {
        
        let state = makeState(
            status: .result(.failure(.updatePaymentFailure))
        )
        
        assertState(.dismissRecoverableError, on: state)
    }
    
    func test_dismissRecoverableError_shouldResetServerErrorStatus() {
        
        let state = makeState(
            status: .serverError(anyMessage())
        )
        
        assertState(.dismissRecoverableError, on: state) {
            
            $0.status = nil
        }
    }
    
    func test_dismissRecoverableError_shouldNotDeliverEffect() {
        
        let state = makeState(
            status: .result(.failure(.updatePaymentFailure))
        )
        
        assert(.dismissRecoverableError, on: state, effect: nil)
    }
    
    // MARK: - add tests for OTP
    
    // TODO: add integration tests
    
    // MARK: - helpers tests
    
    func test_makeState_shouldCreateEmptyTransaction() {
        
        let state = makeState()
        
        XCTAssertNoDiff(state.context.payment.elements, [])
        XCTAssertNoDiff(state.context.payment.footer, .continue)
        XCTAssertFalse(state.context.payment.isFinalStep)
        
        XCTAssertNil(state.context.outline.amount)
        XCTAssertNotNil(state.context.outline.product)
        XCTAssertNoDiff(state.context.outline.fields, [:])
        XCTAssertNotNil(state.context.outline.payload)
        
        XCTAssertNoDiff(state.context.staged, .init())
        XCTAssertNoDiff(state.context.shouldRestart, false)
        
        XCTAssertNoDiff(state.isValid, true)
        XCTAssertNil(state.status)
    }
    
    // MARK: - Helpers
    
    typealias SUT = TransactionReducer<Report, AnywayPaymentContext, AnywayPaymentEvent, AnywayPaymentEffect, AnywayPaymentDigest, AnywayPaymentUpdate>
    
    typealias State = SUT.State
    typealias Event = SUT.Event
    typealias Effect = SUT.Effect
    
    typealias Status = TransactionStatus<AnywayPaymentContext, AnywayPaymentUpdate, Report>
    
    typealias Report = String
    typealias Response = ResponseMapper.CreateAnywayTransferResponse
    
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let composer = AnywayPaymentTransactionReducerComposer<Report>()
        let sut = composer.compose()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    func reduce(
        _ state: inout State,
        _ event: Event
    ) {
        (state, _) = makeSUT().reduce(state, event)
    }
    
     func update(
        _ state: inout State,
        with result: Event.UpdatePaymentResult
    ) throws {
        
        reduce(&state, .updatePayment(result))
    }
    
     func update(
        _ state: inout State,
        with string: String
    ) throws {
        
        try update(&state, with: makeUpdatePaymentResult(from: string))
    }
    
     func makePaymentUpdate(
        from string: String
    ) throws -> AnywayPaymentUpdate {
        
        return try XCTUnwrap(.init(makeResponse(from: string)))
    }
    
     func makeUpdatePaymentResult(
        _ response: Response
    ) throws -> Event.UpdatePaymentResult {
        
        return try .success(XCTUnwrap(.init(response)))
    }
    
     func makeUpdatePaymentResult(
        from string: String
    ) throws -> Event.UpdatePaymentResult {
        
        return try .success(XCTUnwrap(.init(makeResponse(from: string))))
    }
    
     func makeResponse(
        from string: String
    ) throws -> Response {
        
        try ResponseMapper.mapCreateAnywayTransferResponse(
            .init(string.utf8), ok()
        ).get()
    }
    
     func ok(
        url: URL = anyURL()
    ) -> HTTPURLResponse {
        
        return .init(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
     func makeState(
        context: AnywayPaymentContext? = nil,
        isValid: Bool = true,
        status: Status? = nil
    ) -> State {
        
        return .init(
            context: context ?? makeAnywayPaymentContext(),
            isValid: isValid,
            status: status
        )
    }
    
     func isFraudSuspected(
        _ state: SUT.State
    ) -> Bool {
        
        switch state.status {
        case .fraudSuspected: return true
        default: return false
        }
    }
    
     typealias UpdateStateToExpected<State> = (_ state: inout State) -> Void
    
     func assertState(
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
    
     func assert(
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
    
    func assertValue(
        _ value: String?,
        forParameterID id: String,
        in state: State,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let field = state.parameters.first(where: { $0.field.id == id })?.field
        
        XCTAssertNoDiff(field?.value, value, "Expected \(String(describing: value)), but got \(String(describing: field?.id)) instead.", file: file, line: line)
    }
}
