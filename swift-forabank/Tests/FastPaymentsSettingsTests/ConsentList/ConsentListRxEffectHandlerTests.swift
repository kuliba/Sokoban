//
//  ConsentListRxEffectHandlerTests.swift
//  FastPaymentsSettingsPreviewTests
//
//  Created by Igor Malyarov on 14.01.2024.
//

import FastPaymentsSettings
import RxViewModel
import XCTest

extension ConsentListRxEffectHandler: EffectHandler {}

final class ConsentListRxEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, spy) = makeSUT()
        
        XCTAssertNoDiff(spy.callCount, 0)
    }
    
    func test_apply_shouldCallChangeConsentListWithConsent_empty() {
        
        let consent: ConsentListEffect.Consent = .init()
        let (sut, spy) = makeSUT()
        
        sut.handleEffect(.apply(consent)) { _ in }
        
        XCTAssertNoDiff(spy.payloads, [consent])
    }
    
    func test_apply_shouldCallChangeConsentListWithConsent_nonEmpty() {
        
        let consent: ConsentListEffect.Consent = ["открытие", "сургутнефтегазбанк"]
        let (sut, spy) = makeSUT()
        
        sut.handleEffect(.apply(consent)) { _ in }
        
        XCTAssertNoDiff(spy.payloads, [consent])
    }
    
    func test_apply_shouldDeliverEventWithConsentOnSuccess_empty() {
        
        let consent: ConsentListEffect.Consent = .init()
        let effect: Effect = .apply(consent)
        let (sut, spy) = makeSUT()
        
        expect(sut, with: effect, toDeliver: .changeConsent(consent), on: {
            
            spy.complete(with: .success(.init()))
        })
    }
    
    func test_apply_shouldDeliverEventWithConsentOnSuccess_nonEmpty() {
        
        let consent: ConsentListEffect.Consent = ["открытие", "сургутнефтегазбанк"]
        let effect: Effect = .apply(consent)
        let (sut, spy) = makeSUT()
        
        expect(sut, with: effect, toDeliver: .changeConsent(consent), on: {
            
            spy.complete(with: .success(.init()))
        })
    }
    
    func test_apply_shouldDeliverServerErrorOnServerErrorFailure() {
        
        let effect: Effect = .apply(anyConsent())
        let message = "Change Consent Server Error"
        let (sut, spy) = makeSUT()
        
        expect(sut, with: effect, toDeliver: .changeConsentFailure(.serverError(message)), on: {
            
            spy.complete(with: .failure(.serverError(message)))
        })
    }
    
    func test_apply_shouldDeliverConnectivityErrorOnConnectivityErrorFailure() {
        
        let effect: Effect = .apply(anyConsent())
        let (sut, spy) = makeSUT()
        
        expect(sut, with: effect, toDeliver: .changeConsentFailure(.connectivityError), on: {
            
            spy.complete(with: .failure(.connectivityError))
        })
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ConsentListRxEffectHandler
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias ChangeConsentListSpy = Spy<SUT.ChangeConsentListPayload, SUT.ChangeConsentListResponse>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: ChangeConsentListSpy
    ) {
        let spy = ChangeConsentListSpy()
        let sut = SUT(changeConsentList: spy.process(_:completion:))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
}
