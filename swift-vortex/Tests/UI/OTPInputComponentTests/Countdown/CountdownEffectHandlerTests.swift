//
//  CountdownEffectHandlerTests.swift
//  
//
//  Created by Igor Malyarov on 19.01.2024.
//

import OTPInputComponent
import RxViewModel
import XCTest

extension CountdownEffectHandler: EffectHandler {}

final class CountdownEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
    }
    
    // MARK: - initiate
    
    func test_initiate_shouldDeliverStartEventOnSuccess() {
        
        let (sut, spy) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .start, on: {
            
            spy.complete(with: .success(()))
        })
    }
    
    func test_initiate_shouldDeliverConnectivityErrorFailureEventOnConnectivityFailure() {
        
        let (sut, spy) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: connectivity(), on: {
            
            spy.complete(with: connectivity())
        })
    }
    
    func test_initiate_shouldDeliverServerErrorFailureEventOnServerFailure() {
        
        let message = anyMessage()
        let (sut, spy) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: serverError(message), on: {
            
            spy.complete(with: serverError(message))
        })
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CountdownEffectHandler
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias InitiateSpy = Spy<Void, SUT.InitiateOTPResult>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        initiateSpy: InitiateSpy
    ) {
        let initiateSpy = InitiateSpy()
        let sut = SUT(initiate: initiateSpy.process(completion:))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(initiateSpy, file: file, line: line)
        
        return (sut, initiateSpy)
    }
}

private func connectivity(
) -> CountdownEvent {
    
    .failure(.connectivityError)
}

private func connectivity(
) -> CountdownEffectHandler.InitiateOTPResult {
    
    .failure(.connectivityError)
}

private func serverError(
    _ message: String = anyMessage()
) -> CountdownEvent {
    
    .failure(.serverError(message))
}

private func serverError(
    _ message: String = anyMessage()
) -> CountdownEffectHandler.InitiateOTPResult {
    
    .failure(.serverError(message))
}
