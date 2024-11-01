//
//  PaymentsTransfersPersonalFlowBindingFactoryTests.swift
//
//
//  Created by Igor Malyarov on 28.10.2024.
//

import Combine
import CombineSchedulers
import PayHubUI
import XCTest

final class PaymentsTransfersPersonalFlowBindingFactoryTests: XCTestCase {
    
    // MARK: - bindScanQR
    
    func test_bindScanQR_shouldDelayNotifyEvent() {
        
        let (sut, scheduler) = makeSUT(delay: .milliseconds(200))
        let (emitter, notifySpy, cancellable) = bindScanQR(sut, scheduler)
        
        emitter.send(())
        
        XCTAssertEqual(notifySpy.callCount, 0)
        
        scheduler.advance(by: .milliseconds(199))
        XCTAssertEqual(notifySpy.callCount, 0)
        
        scheduler.advance(by: .milliseconds(1))
        XCTAssertEqual(notifySpy.callCount, 1)
        
        XCTAssertNotNil(cancellable)
    }
    
    // MARK: - bindQRNavigation
    
    func test_bindQRNavigationR_shouldDelayNotifyEvent() {
        
        let qrNavigation = makeQRNavigation()
        let (sut, scheduler) = makeSUT(delay: .milliseconds(200))
        let (emitter, notifySpy, cancellable) = bindQRNavigation(sut, scheduler)
        
        emitter.send(qrNavigation)
        
        XCTAssertEqual(notifySpy.callCount, 0)
        
        scheduler.advance(by: .milliseconds(199))
        XCTAssertEqual(notifySpy.callCount, 0)
        
        scheduler.advance(by: .milliseconds(1))
        XCTAssertNoDiff(notifySpy.payloads, [qrNavigation])
        
        XCTAssertNotNil(cancellable)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersPersonalFlowBindingFactory<QRNavigation>
    private typealias VoidNotifySpy = CallSpy<Void, Void>
    private typealias QRNavigationNotifySpy = CallSpy<QRNavigation, Void>
    private typealias Emitter<T> = PassthroughSubject<T, Never>
    
    private func makeSUT(
        delay: SUT.Delay = .milliseconds(300),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let scheduler = DispatchQueue.test
        let sut = SUT(
            delay: delay,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, scheduler)
    }
    
    private func bindScanQR(
        _ sut: SUT,
        _ scheduler: TestSchedulerOf<DispatchQueue>
    ) -> (
        emitter: Emitter<Void>,
        notifySpy: VoidNotifySpy,
        cancellable: AnyCancellable
    ) {
        let emitter = Emitter<Void>()
        let notifySpy = VoidNotifySpy(stubs: [()])
        
        let cancellable = sut.bindScanQR(
            emitter: emitter,
            to: notifySpy.call,
            using: { $0.eraseToAnyPublisher() }
        )
        
        return (emitter, notifySpy, cancellable)
    }
    
    private func bindQRNavigation(
        _ sut: SUT,
        _ scheduler: TestSchedulerOf<DispatchQueue>
    ) -> (
        emitter: Emitter<QRNavigation>,
        notifySpy: QRNavigationNotifySpy,
        cancellable: AnyCancellable
    ) {
        let emitter = Emitter<QRNavigation>()
        let notifySpy = QRNavigationNotifySpy(stubs: [()])
        
        let cancellable = sut.bindQRNavigation(
            emitter: emitter,
            to: notifySpy.call,
            using: { $0.eraseToAnyPublisher() }
        )
        
        return (emitter, notifySpy, cancellable)
    }
    
    private struct QRNavigation: Equatable {
        
        let value: String
    }
    
    private func makeQRNavigation(
        _ value: String = anyMessage()
    ) -> QRNavigation {
        
        return .init(value: value)
    }
}
