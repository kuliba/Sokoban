//
//  RootViewModelFactory+getPaymentProviderPickerNavigationTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 30.12.2024.
//

@testable import Vortex
import PayHub
import XCTest

extension RootViewModelFactory {
    
    func getPaymentProviderPickerNavigation(
        select: PaymentProviderPickerDomain.Select,
        notify: @escaping PaymentProviderPickerDomain.FlowDomain.Notify,
        completion: @escaping (PaymentProviderPickerDomain.Navigation) -> Void
    ) {
        switch select {
        case .detailPayment:
            completion(.destination(.detailPayment(makePaymentsNode(
                payload: .service(.requisites),
                notify: { event in
                    
                    switch event {
                    case .close:  notify(.dismiss)
                    case .scanQR: notify(.select(.outside(.qr)))
                    }
                }
            ))))
            
        case let .latest(latest):
            return
            
        case let .outside(paymentProviderPickerFlowOutside):
            return
            
        case let .provider(provider):
            return
        }
    }
}

final class RootViewModelFactory_getPaymentProviderPickerNavigationTests: RootViewModelFactoryTests {
    
    // MARK: - detailPayment
    
    func test_detailPayment_shouldSetNavigation() {
        
        let (sut, _,_) = makeSUT()
        
        expect(sut, select: .detailPayment, toDeliver: .destination(.detailPayment))
    }
    
    func test_detailPayment_shouldNotifyWithDismissOnCloseAction() {
        
        let (sut, _,_) = makeSUT()
        
        expect(sut, select: .detailPayment, toNotifyWith: .dismiss) {
            
            try? $0.detailPayment().closeAction()
        }
    }
    
    func test_detailPayment_shouldNotifyWithQROnScanQR() {
        
        let (sut, _,_) = makeSUT()
        
        expect(sut, select: .detailPayment, toNotifyWith: .select(.outside(.qr))) {
            
            try? $0.detailPayment().action.send(PaymentsViewModelAction.ScanQrCode())
        }
    }
    
    // MARK: - Helpers
    
    private typealias Domain = PaymentProviderPickerDomain
    private typealias NotifySpy = CallSpy<Domain.FlowDomain.NotifyEvent, Void>
    
    private enum EquatableNavigation: Equatable {
        
        case alert(BackendFailure)
        case destination(EquatableDestination)
        case outside(Domain.PaymentProviderPickerFlowOutside)
        
        enum EquatableDestination: Equatable {
            
            case backendFailure(BackendFailure)
            case detailPayment
            case payment(PaymentResult)
            case servicePicker
            case servicesFailure
            
            typealias PaymentResult = Result<PaymentSuccess, PaymentFailure>
            
            enum PaymentSuccess: Equatable {
                
                case services
                case startPayment
            }
            enum PaymentFailure: Error, Equatable {
                
                case operatorFailure(UtilityPaymentProvider)
                case serviceFailure(ServiceFailureAlert.ServiceFailure)
            }
        }
    }
    
    private func equatable(
        _ navigation: Domain.Navigation
    ) -> EquatableNavigation {
        
        switch navigation {
        case let .alert(alert):
            return .alert(alert)
            
        case let .destination(destination):
            return .destination(equatable(destination))
            
        case let .outside(outside):
            return .outside(outside)
        }
    }
    
    private func equatable(
        _ destination: Domain.Destination
    ) -> EquatableNavigation.EquatableDestination {
        
        switch destination {
        case let .backendFailure(backendFailure):
            return .backendFailure(backendFailure)
            
        case .detailPayment:
            return .detailPayment
            
        case let .payment(result):
            switch result {
            case let .failure(failure):
                switch failure {
                case let .operatorFailure(`operator`):
                    return .payment(.failure(.operatorFailure(`operator`)))
                    
                case let .serviceFailure(failure):
                    return .payment(.failure(.serviceFailure(failure)))
                }
                
            case let .success(success):
                switch success {
                case .services:
                    return .payment(.success(.services))
                    
                case .startPayment:
                    return .payment(.success(.startPayment))
                }
            }
            
        case .servicePicker:
            return .servicePicker
            
        case .servicesFailure:
            return .servicesFailure
        }
    }
    
    private func expect(
        _ sut: SUT,
        select: Domain.Select,
        toDeliver expectedNavigation: EquatableNavigation,
        on action: () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.getPaymentProviderPickerNavigation(select: select, notify: { _ in }) {
            
            XCTAssertNoDiff(self.equatable($0), expectedNavigation, "Expected \(expectedNavigation), but got \($0) instead.", file: file, line: line)
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
    
    private func expect(
        _ sut: SUT,
        select: Domain.Select,
        toNotifyWith notifyEvent: Domain.FlowDomain.NotifyEvent,
        on action: () -> Void = {},
        perform: @escaping (Domain.Navigation) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let notifySpy = NotifySpy(stubs: [()])
        let exp = expectation(description: "wait for completion")
        
        sut.getPaymentProviderPickerNavigation(
            select: select,
            notify: notifySpy.call
        ) {
            perform($0)
            XCTAssertNoDiff(notifySpy.payloads, [notifyEvent])
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
}

// MARK: - DSL

private extension PaymentProviderPickerDomain.Navigation {
    
    func detailPayment(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> PaymentsViewModel {
        
        guard case let .destination(.detailPayment(detailPayment)) = self
        else {
            XCTFail("Expected detailPayment, but got \(self) instead.", file: file, line: line)
            throw NSError(domain: "Unexpected destination", code: -1)
        }
        
        return detailPayment.model
    }
}
