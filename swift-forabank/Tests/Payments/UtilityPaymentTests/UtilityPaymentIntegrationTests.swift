//
//  UtilityPaymentIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

import RxViewModel
import UtilityPayment
import XCTest

final class UtilityPaymentIntegrationTests: XCTestCase {
    
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
    
    private typealias State = UtilityPaymentState
    private typealias Event = UtilityPaymentEvent
    private typealias Effect = UtilityPaymentEffect
    
    private typealias SUT = RxViewModel<State, Event, Effect>
    private typealias StateSpy = ValueSpy<State>
    
    private typealias CreateAnywayTransferSpy = Spy<UtilityPaymentEffectHandler.CreateAnywayTransferPayload, UtilityPaymentEffectHandler.CreateAnywayTransferResult>
    private typealias MakeTransferSpy = Spy<UtilityPaymentEffectHandler.MakeTransferPayload, UtilityPaymentEffectHandler.MakeTransferResult>

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
        let reducer = UtilityPaymentReducer()
        
        let createAnywayTransferSpy = CreateAnywayTransferSpy()
        let makeTransferSpy = MakeTransferSpy()
        let effectHandler = UtilityPaymentEffectHandler(
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
