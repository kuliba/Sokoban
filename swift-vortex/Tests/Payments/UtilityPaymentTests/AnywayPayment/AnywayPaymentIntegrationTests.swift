//
//  AnywayPaymentIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

import RxViewModel
import UtilityPayment
import XCTest

final class AnywayPaymentIntegrationTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_,_, createAnywayTransferSpy, makeTransferSpy) = makeSUT()
        
        XCTAssertEqual(createAnywayTransferSpy.callCount, 0)
        XCTAssertEqual(makeTransferSpy.callCount, 0)
    }
    
//    func test_flow() {
//        
//        let initialState: State = .init()
//        let (sut, stateSpy) = makeSUT()
//        
//        sut.event(<#T##event: Event##Event#>)
//        
//        assert(
//            stateSpy,
//            initialState,
//            {
//                _ in
//            }
//        )
//    }
    
    // MARK: - Helpers
    
    private typealias State = AnywayPaymentState<Payment>
    private typealias Event = AnywayPaymentEvent<CreateAnywayTransferResponse>
    private typealias Effect = AnywayPaymentEffect<Payment>
    
    private typealias SUT = RxViewModel<State, Event, Effect>
    private typealias StateSpy = ValueSpy<State>
    
    private typealias Reducer = AnywayPaymentReducer<Payment, CreateAnywayTransferResponse>
    
    private typealias EffectHandler = AnywayPaymentEffectHandler<Payment, CreateAnywayTransferResponse>
    private typealias CreateAnywayTransferSpy = Spy<EffectHandler.CreateAnywayTransferPayload, EffectHandler.CreateAnywayTransferResult>
    private typealias MakeTransferSpy = Spy<EffectHandler.MakeTransferPayload, EffectHandler.MakeTransferResult>

    private func makeSUT(
        initialState: State = .payment(.init()),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        stateSpy: StateSpy,
        createAnywayTransferSpy: CreateAnywayTransferSpy,
        makeTransferSpy: MakeTransferSpy
    ) {
        let reducer = Reducer(update: { _,_ in fatalError() })
        
        let createAnywayTransferSpy = CreateAnywayTransferSpy()
        let makeTransferSpy = MakeTransferSpy()
        let effectHandler = EffectHandler(
            createAnywayTransfer: createAnywayTransferSpy.process,
            makeTransfer: makeTransferSpy.process
        )
        
        let sut = SUT(
            initialState: initialState,
            reduce: reducer.reduce,
            handleEffect: effectHandler.handleEffect,
            scheduler: .immediate
        )
        let stateSpy = StateSpy(sut.$state)
        
        trackForMemoryLeaks(stateSpy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(reducer, file: file, line: line)
        trackForMemoryLeaks(effectHandler, file: file, line: line)
        trackForMemoryLeaks(createAnywayTransferSpy, file: file, line: line)
        trackForMemoryLeaks(makeTransferSpy, file: file, line: line)
        
        return (sut, stateSpy, createAnywayTransferSpy, makeTransferSpy)
    }
    
    private func assert(
        _ spy: StateSpy,
        _ initialState: State,
        _ updates: ((inout State) -> Void)...,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var state = initialState
        var values = [State]()
        
        for update in updates {
            
            update(&state)
            values.append(state)
        }
        
        XCTAssertNoDiff(spy.values, values, file: file, line: line)
    }
}
