//
//  EffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 21.03.2025.
//

import CreditCardMVPCore
import XCTest

final class EffectHandlerTests: LogicTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, application, loadOTP, otp) = makeSUT()
        
        XCTAssertEqual(application.callCount, 0)
        XCTAssertEqual(loadOTP.callCount, 0)
        XCTAssertEqual(otp.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - apply
    
    func test_apply_shouldCallConfirmApplicationWithPayload() {
        
        let payload = makePayload()
        let (sut, application, _,_) = makeSUT()
        
        sut.handleEffect(.apply(payload)) { _ in }
        
        XCTAssertNoDiff(application.payloads, [payload])
    }
    
    func test_apply_shouldDeliverAlertFailure_onApplicationAlertFailure() {
        
        let (sut, application, _,_) = makeSUT()
        let message = anyMessage()
        
        expect(
            sut,
            with: makeApplication(),
            toDeliver: makeApplicationResultFailure(message: message, type: .alert)
        ) {
            application.complete(with: .failure(.init(message: message, type: .alert)))
        }
    }
    
    func test_apply_shouldDeliverInformerFailure_onApplicationInformerFailure() {
        
        let (sut, application, _,_) = makeSUT()
        let message = anyMessage()
        
        expect(
            sut,
            with: makeApplication(),
            toDeliver: makeApplicationResultFailure(message: message, type: .informer)
        ) {
            application.complete(with: .failure(.init(message: message, type: .informer)))
        }
    }
    
    func test_apply_shouldDeliverOTPFailure_onApplicationOTPFailure() {
        
        let (sut, application, _,_) = makeSUT()
        let message = anyMessage()
        
        expect(
            sut,
            with: makeApplication(),
            toDeliver: makeApplicationResultFailure(message: message, type: .otp)
        ) {
            application.complete(with: .failure(.init(message: message, type: .otp)))
        }
    }
    
    func test_apply_shouldDeliverSuccess_onApplicationSuccess() {
        
        let (sut, application, _,_) = makeSUT()
        let success = makeApplicationSuccess()
        
        expect(
            sut,
            with: makeApplication(),
            toDeliver: makeApplicationResultSuccess(success: success)
        ) {
            application.complete(with: .success(success))
        }
    }
    
    // MARK: - loadOTP
    
    func test_loadOTP_shouldCallLoadOTP() {
        
        let (sut, _, loadOTP, _) = makeSUT()
        
        sut.handleEffect(.loadOTP) { _ in }
        
        XCTAssertEqual(loadOTP.callCount, 1)
    }
    
    // TODO: add test for Notify!!
    
    func test_loadOTP_shouldDeliverInformerFailure_onLoadOTPInformerFailure() {
        
        let message = anyMessage()
        let (sut, _, loadOTP, _) = makeSUT()
        
        expect(sut, with: .loadOTP, toDeliver: makeLoadOTPFailure(message: message, type: .alert)) {
            
            loadOTP.complete(with: .failure(.init(message: message, type: .alert)))
        }
    }
    
    func test_loadOTP_shouldDeliverAlertFailure_onLoadOTPAlertFailure() {
        
        let message = anyMessage()
        let (sut, _, loadOTP, _) = makeSUT()
        
        expect(sut, with: .loadOTP, toDeliver: makeLoadOTPFailure(message: message, type: .informer)) {
            
            loadOTP.complete(with: .failure(.init(message: message, type: .informer)))
        }
    }
    
    func test_loadOTP_shouldDeliverOTP_onLoadOTPSuccess() {
        
        let otp = OTP()
        let (sut, _, loadOTP, _) = makeSUT()
        
        expect(sut, with: .loadOTP, toDeliver: makeLoadOTPSuccess(otp)) {
            
            loadOTP.complete(with: .success(otp))
        }
    }
    
    // MARK: - notifyOTP
    
    func test_notifyOTP_shouldCallNotifyOTP() {
        
        let message = anyMessage()
        let (sut, _,_, otp) = makeSUT()
        
        sut.handleEffect(.notifyOTP(otp, message)) { _ in }
        
        XCTAssertNoDiff(otp.payloads, [message])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = EffectHandler<ApplicationPayload, ApplicationSuccess, OTP>
    private typealias Application = Spy<ApplicationPayload, Event.ApplicationResult>
    private typealias LoadOTPSpy = Spy<Void, Event.LoadedOTPResult>
    private typealias OTP = CallSpy<String, Void>
    private typealias Event = CreditCardMVPCore.Event<ApplicationSuccess, OTP>
    private typealias Effect = CreditCardMVPCore.Effect<ApplicationPayload, OTP>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        application: Application,
        loadOTP: LoadOTPSpy,
        otp: OTP
    ) {
        let application = Application()
        let loadOTP = LoadOTPSpy()
        let otp = OTP(stubs: [()])
        let sut = SUT(
            apply: application.process,
            loadOTP: loadOTP.process,
            otpWitness: { _ in otp.call }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(application, file: file, line: line)
        trackForMemoryLeaks(loadOTP, file: file, line: line)
        trackForMemoryLeaks(otp, file: file, line: line)
        
        return (sut, application, loadOTP, otp)
    }
    
    private func makeApplication(
        _ payload: ApplicationPayload? = nil
    ) -> Effect {
        
        return .apply(payload ?? makePayload())
    }
    
    private func makeApplicationResultFailure(
        message: String = anyMessage(),
        type: Event.ApplicationFailure
    ) -> Event {
        
        return .applicationResult(.failure(.init(
            message: message,
            type: type
        )))
    }
    
    private func makeApplicationResultSuccess(
        success: ApplicationSuccess? = nil
    ) -> Event {
        
        return .applicationResult(.success(success ?? makeApplicationSuccess()))
    }
    
    private func makeLoadOTPFailure(
        message: String = anyMessage(),
        type: Event.LoadOTPFailure
    ) -> Event {
        
        return .loadedOTP(.failure(.init(
            message: message,
            type: type
        )))
    }
    
    private func makeLoadOTPSuccess(
        _ otp: OTP? = nil
    ) -> Event {
        
        return .loadedOTP(.success(otp ?? .init()))
    }
    
    private func equatable(
        _ event: Event
    ) -> EquatableEvent {
        
        switch event {
        case let .applicationResult(applicationResult):
            return .applicationResult(applicationResult)
            
        case .continue:
            return .continue
            
        case let .loadedOTP(result):
            switch result {
            case let .failure(failure):
                return .loadedOTP(.failure(failure))
                
            case let .success(otp):
                return .loadedOTP(.success(.init(otp)))
            }
        }
    }
    
    private enum EquatableEvent: Equatable {
        
        case applicationResult(Event.ApplicationResult)
        case `continue`
        case loadedOTP(Result<ObjectIdentifier, LoadFailure<Event.LoadOTPFailure>>)
    }
    
    private func expect(
        _ sut: SUT,
        with effect: Effect,
        toDeliver expectedEvents: Event...,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedEvents.count
        var events = [Event]()
        
        sut.handleEffect(effect) {
            
            events.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(events.map(equatable), expectedEvents.map(equatable), file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
}
