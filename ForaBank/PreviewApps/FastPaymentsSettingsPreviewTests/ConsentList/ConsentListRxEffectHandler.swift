//
//  ConsentListRxEffectHandlerTests.swift
//  FastPaymentsSettingsPreviewTests
//
//  Created by Igor Malyarov on 14.01.2024.
//

final class ConsentListRxEffectHandler {
    
    private let changeConsentList: ChangeConsentList
    
    init(changeConsentList: @escaping ChangeConsentList) {
        
        self.changeConsentList = changeConsentList
    }
}

extension ConsentListRxEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .apply(consent):
            changeConsentList(consent) { result in
                
                switch result {
                case .success:
                    dispatch(.consent(consent))
                    
                case let .serverError(message):
                    dispatch(.consentFailure(.serverError(message)))

                case .connectivityError:
                    dispatch(.consentFailure(.connectivityError))
                }
            }
        }
    }
}

extension ConsentListRxEffectHandler {
    
    typealias ChangeConsentListPayload = Set<Bank.ID>
    // (h) changeClientConsentMe2MePull
    typealias ChangeConsentList = (ChangeConsentListPayload, @escaping (ChangeConsentListResponse) -> Void) -> Void
    
    enum ChangeConsentListResponse {
        
        case success
        case serverError(String)
        case connectivityError
    }
}

extension ConsentListRxEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias State = ConsentListState
    typealias Event = ConsentListEvent
    typealias Effect = ConsentListEffect
}

@testable import FastPaymentsSettingsPreview
import XCTest

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
        
        expect(sut, with: effect, toDeliver: .consent(consent), on: {
            
            spy.complete(with: .success)
        })
    }
    
    func test_apply_shouldDeliverEventWithConsentOnSuccess_nonEmpty() {
        
        let consent: ConsentListEffect.Consent = ["открытие", "сургутнефтегазбанк"]
        let effect: Effect = .apply(consent)
        let (sut, spy) = makeSUT()
        
        expect(sut, with: effect, toDeliver: .consent(consent), on: {
            
            spy.complete(with: .success)
        })
    }
    
    func test_apply_shouldDeliverServerErrorOnServerErrorFailure() {
        
        let effect: Effect = .apply(anyConsent())
        let message = "Change Consent Server Error"
        let (sut, spy) = makeSUT()
        
        expect(sut, with: effect, toDeliver: .consentFailure(.serverError(message)), on: {
            
            spy.complete(with: .serverError(message))
        })
    }
    
    func test_apply_shouldDeliverConnectivityErrorOnConnectivityErrorFailure() {
        
        let effect: Effect = .apply(anyConsent())
        let message = "Change Consent Server Error"
        let (sut, spy) = makeSUT()
        
        expect(sut, with: effect, toDeliver: .consentFailure(.connectivityError), on: {
            
            spy.complete(with: .connectivityError)
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
    
    private func expect(
        _ sut: SUT,
        with effect: Effect,
        toDeliver expectedEvent: Event,
        on action: @escaping () -> Void,
        timeout: TimeInterval = 0.05,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.handleEffect(effect) {
            
            XCTAssertNoDiff($0, expectedEvent, file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}
