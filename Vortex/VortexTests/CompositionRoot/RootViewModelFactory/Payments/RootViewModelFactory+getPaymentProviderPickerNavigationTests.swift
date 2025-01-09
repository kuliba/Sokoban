//
//  RootViewModelFactory+getPaymentProviderPickerNavigationTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 30.12.2024.
//

@testable import Vortex
import PayHub
import XCTest

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
    
    // MARK: - latest
    
    func test_latest_shouldSetAlert_onMissingProduct() {
        
        let latest = makeServiceLatest()
        let (sut, _,_) = makeSUT()
        
        expect(
            sut,
            select: .latest(latest),
            toDeliver: .alert(.paymentConnectivity)
        )
    }
    
    func test_latest_shouldSetAlert_onHTTPClientFailure() {
        
        let latest = makeServiceLatest()
        let model: Model = .mockWithEmptyExcept()
        model.addSberProduct()
        let (sut, httpClient, _) = makeSUT(model: model)
        
        expect(
            sut,
            select: .latest(latest),
            toDeliver: .alert(.paymentConnectivity),
            on: { httpClient.complete(with: anyError()) }
        )
    }
    
    func test_latest_shouldSetStartPaymentDestinationOnHTTPClientSuccess() {
        
        let latest = makeServiceLatest()
        let model: Model = .mockWithEmptyExcept()
        model.addSberProduct()
        let (sut, httpClient, _) = makeSUT(model: model)
        
        expect(
            sut,
            select: .latest(latest),
            toDeliver: .destination(.payment(.success(.startPayment))),
            on: {
                httpClient.complete(withString: .createAnywayTransferIsNewPaymentTrueResponse)
            }
        )
    }
    
    // MARK: - outside
    
    func test_outside_back_shouldSetNavigation() {
        
        let (sut, _,_) = makeSUT()
        
        expect(sut, select: .outside(.back), toDeliver: .outside(.back))
    }
    
    func test_outside_chat_shouldSetNavigation() {
        
        let (sut, _,_) = makeSUT()
        
        expect(sut, select: .outside(.chat), toDeliver: .outside(.chat))
    }
    
    func test_outside_main_shouldSetNavigation() {
        
        let (sut, _,_) = makeSUT()
        
        expect(sut, select: .outside(.main), toDeliver: .outside(.main))
    }
    
    func test_outside_payments_shouldSetNavigation() {
        
        let (sut, _,_) = makeSUT()
        
        expect(sut, select: .outside(.payments), toDeliver: .outside(.payments))
    }
    
    func test_outside_qr_shouldSetNavigation() {
        
        let (sut, _,_) = makeSUT()
        
        expect(sut, select: .outside(.qr), toDeliver: .outside(.qr))
    }
    
    // MARK: - provider
    
    func test_provider_shouldSetOperatorFailureDestinationOnHTTPClientFailure() {
        
        let provider = makeUtilityPaymentProvider()
        let (sut, httpClient, _) = makeSUT()
        
        expect(
            sut,
            select: .provider(provider),
            toDeliver: .destination(.payment(.failure(.operatorFailure(provider)))),
            on: {
                 httpClient.complete(with: anyError())
            }
        )
    }

    func test_provider_shouldSetServicesDestinationOnHTTPClientSuccessWithServices() {
        
        let provider = makeUtilityPaymentProvider()
        let (sut, httpClient, _) = makeSUT()
        
        expect(
            sut,
            select: .provider(provider),
            toDeliver: .destination(.payment(.success(.services))),
            on: {
                httpClient.complete(withString: .multiServicesValidJSON)
            }
        )
    }

    func test_provider_shouldSetFailureDestinationOnMissingProduct() {
        
        let provider = makeUtilityPaymentProvider()
        let (sut, httpClient, _) = makeSUT()

        expect(
            sut,
            select: .provider(provider),
            toDeliver: .destination(.payment(.failure(.serviceFailure(.connectivityError)))),
            on: {
                httpClient.complete(withString: .singleServiceValidJSON)
                httpClient.complete(withString: .createAnywayTransferIsNewPaymentTrueResponse, at: 1)
                XCTAssertNoDiff(httpClient.lastPathComponentsWithQueryValue(for: "operatorOnly"), [
                    "getOperatorsListByParam-false",
                    "createAnywayTransfer"
                ])
                XCTAssertNoDiff(httpClient.lastPathComponentsWithQueryValue(for: "isNewPayment"), [
                    "getOperatorsListByParam",
                    "createAnywayTransfer-true"
                ])
            }
        )
    }

    func test_provider_shouldSetStartPaymentDestinationOnHTTPClientSuccess() {
        
        let provider = makeUtilityPaymentProvider()
        let model: Model = .mockWithEmptyExcept()
        model.addSberProduct()
        let (sut, httpClient, _) = makeSUT(model: model)

        expect(
            sut,
            select: .provider(provider),
            toDeliver: .destination(.payment(.success(.startPayment))),
            on: {
                httpClient.complete(withString: .singleServiceValidJSON)
                httpClient.complete(withString: .createAnywayTransferIsNewPaymentTrueResponse, at: 1)
                XCTAssertNoDiff(httpClient.lastPathComponentsWithQueryValue(for: "operatorOnly"), [
                    "getOperatorsListByParam-false",
                    "createAnywayTransfer"
                ])
                XCTAssertNoDiff(httpClient.lastPathComponentsWithQueryValue(for: "isNewPayment"), [
                    "getOperatorsListByParam",
                    "createAnywayTransfer-true"
                ])
            }
        )
    }

    // MARK: - Helpers
    
    private typealias Domain = PaymentProviderPickerDomain
    private typealias NotifySpy = CallSpy<Domain.FlowDomain.NotifyEvent, Void>
    
    private enum EquatableNavigation: Equatable {
        
        case alert(BackendFailure)
        case destination(EquatableDestination)
        case outside(Domain.PaymentProviderPickerFlowOutside)
        
        enum EquatableDestination: Equatable {
            
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
