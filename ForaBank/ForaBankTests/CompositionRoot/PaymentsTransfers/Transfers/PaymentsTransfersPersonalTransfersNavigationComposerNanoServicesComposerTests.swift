//
//  PaymentsTransfersPersonalTransfersNavigationComposerNanoServicesComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 24.10.2024.
//

import Combine
@testable import ForaBank
import XCTest

final class PaymentsTransfersPersonalTransfersNavigationComposerNanoServicesComposerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallNotify() {
        
        let (_,_,_, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
    }
    
    // MARK: - abroad
    
    func test_makeAbroad_shouldCallNotifyWithDismissOnPaymentRequest() throws {
        
        let (_, nanoServices, _, spy) = makeSUT()
        let abroad = nanoServices.makeAbroad(spy.call(payload:))
        
        abroad.requestPayment(with: .avtodor)
        
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
    }
    
    func test_makeAbroad_shouldCallNotifyWithDelayOnPaymentRequestWithSource() throws {
        
        let (_, nanoServices, scheduler, spy) = makeSUT()
        let abroad = nanoServices.makeAbroad(spy.call(payload:))
        
        abroad.requestPayment(with: .avtodor)
        advance(by: .milliseconds(300), on: scheduler)
        
        XCTAssertNoDiff(spy.equatablePayloads, [
            .dismiss,
            .select(.contacts(.avtodor))
        ])
    }
    
    func test_makeAbroad_shouldCallNotifyWithDelayOnPaymentRequestWithLatest() throws {
        
        let latestID: LatestPaymentData.ID = .random(in: 1...100)
        let (_, nanoServices, scheduler, spy) = makeSUT()
        let abroad = nanoServices.makeAbroad(spy.call(payload:))
        
        abroad.requestPayment(with: .latestPayment(latestID))
        advance(by: .milliseconds(300), on: scheduler)
        
        XCTAssertNoDiff(spy.equatablePayloads, [
            .dismiss,
            .select(.latest(latestID))
        ])
    }
    
    func test_makeAbroad_shouldCallNotifyWithDismissOnCountriesItemTap() throws {
        
        let (_, nanoServices, _, spy) = makeSUT()
        let abroad = nanoServices.makeAbroad(spy.call(payload:))
        
        abroad.countriesItemTap(with: .avtodor)
        
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
    }
    
    func test_makeAbroad_shouldCallNotifyWithDelayOnCountriesItemTapWithSource() throws {
        
        let (_, nanoServices, scheduler, spy) = makeSUT()
        let abroad = nanoServices.makeAbroad(spy.call(payload:))
        
        abroad.countriesItemTap(with: .avtodor)
        advance(by: .milliseconds(300), on: scheduler)
        
        XCTAssertNoDiff(spy.equatablePayloads, [
            .dismiss,
            .select(.countries(.avtodor))
        ])
    }
    
    // MARK: - makeAnotherCard
    
    func test_makeAnotherCard_shouldRequestTemplatesList() {
        
        let model: Model = .mockWithEmptyExcept()
        let productTemplateListRequestSpy = ValueSpy(model.productTemplateListRequest)
        XCTAssertEqual(productTemplateListRequestSpy.values.count, 0)
        
        let (_, nanoServices, _, spy) = makeSUT(model: model)
        _ = nanoServices.makeAnotherCard(spy.call(payload:))
        
        XCTAssertEqual(productTemplateListRequestSpy.values.count, 1)
    }
    
    func test_makeAnotherCard_shouldCallNotifyWithDismissOnScanQRCode() throws {
        
        let (_, nanoServices, _, spy) = makeSUT()
        let anotherCard = nanoServices.makeAnotherCard(spy.call(payload:))
        
        anotherCard.scanQRCode()
        
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
    }
    
    func test_makeAnotherCard_shouldCallNotifyWithDelayOnPaymentRequestWithSource() throws {
        
        let (_, nanoServices, scheduler, spy) = makeSUT()
        let anotherCard = nanoServices.makeAnotherCard(spy.call(payload:))
        
        anotherCard.scanQRCode()
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
        
        scheduler.advance(by: .milliseconds(799))
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
        
        scheduler.advance(by: .milliseconds(800))
        XCTAssertNoDiff(spy.equatablePayloads, [
            .dismiss,
            .select(.scanQR)
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersPersonalTransfersNavigationComposerNanoServicesComposer
    private typealias NotifySpy = CallSpy<SUT.Event, Void>
    
    private func makeSUT(
        model: Model = .mockWithEmptyExcept(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        nanoServices: SUT.NanoServices,
        scheduler: TestSchedulerOfDispatchQueue,
        spy: NotifySpy
    ) {
        let scheduler = DispatchQueue.test
        let sut = SUT(model: model, scheduler: scheduler.eraseToAnyScheduler())
        let spy = NotifySpy(stubs: .init(repeating: (), count: 9))
        let nanoServices = sut.compose()
        
        //    trackForMemoryLeaks(sut, file: file, line: line)
        //    trackForMemoryLeaks(model, file: file, line: line)
        //    trackForMemoryLeaks(scheduler, file: file, line: line)
        //    trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, nanoServices, scheduler, spy)
    }
    
    private func advance(
        by interval: DispatchQueue.SchedulerTimeType.Stride,
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: interval)
    }
}

// MARK: - Equatable

private extension PaymentsTransfersPersonalTransfersDomain.FlowEvent {
    
    var equatable: EquatableEvent {
        
        switch self {
        case .dismiss:
            return .dismiss
            
        case let .receive(receive):
            return unimplemented("\(receive) is not used in tests.")
            
        case let .select(select):
            return .select(select)
        }
    }
    
    enum EquatableEvent: Equatable {
        
        case dismiss
        case select(PaymentsTransfersPersonalTransfersDomain.Element)
    }
}

private extension CallSpy
where Payload == PaymentsTransfersPersonalTransfersDomain.FlowEvent {
    
    typealias EquatablePayload = PaymentsTransfersPersonalTransfersDomain.FlowEvent.EquatableEvent
    
    var equatablePayloads: [EquatablePayload] {
        
        return payloads.map(\.equatable)
    }
}

// MARK: - DSL

private extension Model {
    
    var productTemplateListRequest: AnyPublisher<ModelAction.ProductTemplate.List.Request, Never> {
        
        action
            .compactMap { $0 as? ModelAction.ProductTemplate.List.Request }
            .eraseToAnyPublisher()
    }
}

private extension Node where Model == ContactsViewModel {
    
    func requestPayment(
        with source: Payments.Operation.Source
    ) {
        let action = ContactsViewModelAction.PaymentRequested(source: source)
        model.action.send(action)
    }
    
    func countriesItemTap(
        with source: Payments.Operation.Source
    ) {
        let action = ContactsSectionViewModelAction.Countries.ItemDidTapped(source: source)
        model.action.send(action)
    }
}

private extension Node where Model == ClosePaymentsViewModelWrapper {
    
    func scanQRCode() {
        
        let action = PaymentsViewModelAction.ScanQrCode()
        model.paymentsViewModel.action.send(action)
    }
}
