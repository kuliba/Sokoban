//
//  TemplatesListFlowEffectHandlerMicroServicesComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 27.08.2024.
//

@testable import ForaBank
import XCTest

final class TemplatesListFlowEffectHandlerMicroServicesComposerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborator() {
        
        let (_, spy) = makeSUT(paymentsTransfersFlag: .active, utilitiesPaymentsFlag: .inactive)
        
        XCTAssertEqual(spy.callCount, 0)
    }
    
    // MARK: - compose inactive-inactive
    
    func test_compose_shouldDeliverLegacy_inactivePaymentsTransfers_inactiveUtilitiesPayments() {
        
        let (sut, _) = makeSUT(
            paymentsTransfersFlag: .inactive,
            utilitiesPaymentsFlag: .inactive
        )
        
        makePayment(sut) {
            
            switch $0 {
            case .success(.legacy):
                break
                
            default:
                XCTFail("Expected legacy, but got \(String(describing: $0)) instead.")
            }
        }
    }

    // MARK: - compose inactive-active
    
    func test_compose_shouldCallCollaboratorWithPayload_inactivePaymentsTransfers_activeUtilitiesPayments() {
        
        let template = makeTemplate()
        let (sut, spy) = makeSUT(
            paymentsTransfersFlag: .inactive,
            utilitiesPaymentsFlag: .active(.live)
        )
        
        sut.makePayment((template, {})) { _ in }
        
        XCTAssertEqual(spy.payloads, [template])
    }
    
    func test_compose_shouldDeliverConnectivityError_inactivePaymentsTransfers_activeUtilitiesPayments() {
        
        let (sut, spy) = makeSUT(
            paymentsTransfersFlag: .inactive,
            utilitiesPaymentsFlag: .active(.live)
        )
        let exp = expectation(description: "wait for completion")
        
        sut.makePayment((makeTemplate(), {})) { result in
        
            switch result {
            case .failure(.connectivityError):
                break
                
            default:
                XCTFail("Expected failure, but got \(result) instead.")
            }
            
            exp.fulfill()
        }
        
        spy.complete(with: .failure(.connectivityError))

        wait(for: [exp], timeout: 1)
    }
    
    func test_compose_shouldDeliverServiceError_inactivePaymentsTransfers_activeUtilitiesPayments() {
        
        let message = anyMessage()
        let (sut, spy) = makeSUT(
            paymentsTransfersFlag: .inactive,
            utilitiesPaymentsFlag: .active(.live)
        )
        let exp = expectation(description: "wait for completion")
        
        sut.makePayment((makeTemplate(), {})) { result in
        
            switch result {
            case let .failure(.serverError(receivedMessage)):
                XCTAssertNoDiff(receivedMessage, message)
                
            default:
                XCTFail("Expected failure, but got \(result) instead.")
            }
            
            exp.fulfill()
        }
        
        spy.complete(with: .failure(.serverError(message)))

        wait(for: [exp], timeout: 1)
    }
    
    func test_compose_shouldDeliverPayment_inactivePaymentsTransfers_activeUtilitiesPayments() {
        
        let payment = makePayment()
        let (sut, spy) = makeSUT(
            paymentsTransfersFlag: .inactive,
            utilitiesPaymentsFlag: .active(.live)
        )
        let exp = expectation(description: "wait for completion")
        
        sut.makePayment((makeTemplate(), {})) { result in
        
            switch result {
            case let .success(.v1(receivedPayment)):
                XCTAssertNoDiff(receivedPayment, payment)
                
            default:
                XCTFail("Expected failure, but got \(result) instead.")
            }
            
            exp.fulfill()
        }
        
        spy.complete(with: .success(payment))

        wait(for: [exp], timeout: 1)
    }
        
    // MARK: - compose inactive-active non-housing
    
    func test_compose_shouldDeliverLegacy_inactivePaymentsTransfers_activeUtilitiesPayments_nonHousing() {
        
        let (sut, _) = makeSUT(
            paymentsTransfersFlag: .inactive,
            utilitiesPaymentsFlag: .active(.live)
        )
        
        sut.makePayment((makeTemplate(type: .sfp), {})) {
            
            switch $0 {
            case .success(.legacy):
                break
                
            default:
                XCTFail("Expected legacy, but got \(String(describing: $0)) instead.")
            }
        }
    }
        
    // MARK: - compose active-inactive
    
    func test_compose_shouldCallCollaboratorWithPayload_activePaymentsTransfers_inactiveUtilitiesPayments() {
        
        let template = makeTemplate()
        let (sut, spy) = makeSUT(
            paymentsTransfersFlag: .active,
            utilitiesPaymentsFlag: .inactive
        )
        
        sut.makePayment((template, {})) { _ in }
        
        XCTAssertEqual(spy.payloads, [template])
    }
    
    func test_compose_shouldDeliverConnectivityError_activePaymentsTransfers_inactiveUtilitiesPayments() {
        
        let (sut, spy) = makeSUT(
            paymentsTransfersFlag: .active,
            utilitiesPaymentsFlag: .inactive
        )
        let exp = expectation(description: "wait for completion")
        
        sut.makePayment((makeTemplate(), {})) { result in
        
            switch result {
            case .failure(.connectivityError):
                break
                
            default:
                XCTFail("Expected failure, but got \(result) instead.")
            }
            
            exp.fulfill()
        }
        
        spy.complete(with: .failure(.connectivityError))

        wait(for: [exp], timeout: 1)
    }
    
    func test_compose_shouldDeliverServiceError_activePaymentsTransfers_inactiveUtilitiesPayments() {
        
        let message = anyMessage()
        let (sut, spy) = makeSUT(
            paymentsTransfersFlag: .active,
            utilitiesPaymentsFlag: .inactive
        )
        let exp = expectation(description: "wait for completion")
        
        sut.makePayment((makeTemplate(), {})) { result in
        
            switch result {
            case let .failure(.serverError(receivedMessage)):
                XCTAssertNoDiff(receivedMessage, message)
                
            default:
                XCTFail("Expected failure, but got \(result) instead.")
            }
            
            exp.fulfill()
        }
        
        spy.complete(with: .failure(.serverError(message)))

        wait(for: [exp], timeout: 1)
    }
    
    func test_compose_shouldDeliverPayment_activePaymentsTransfers_inactiveUtilitiesPayments() {
        
        let payment = makePayment()
        let (sut, spy) = makeSUT(
            paymentsTransfersFlag: .active,
            utilitiesPaymentsFlag: .inactive
        )
        let exp = expectation(description: "wait for completion")
        
        sut.makePayment((makeTemplate(), {})) { result in
        
            switch result {
            case let .success(.v1(receivedPayment)):
                XCTAssertNoDiff(receivedPayment, payment)
                
            default:
                XCTFail("Expected failure, but got \(result) instead.")
            }
            
            exp.fulfill()
        }
        
        spy.complete(with: .success(payment))

        wait(for: [exp], timeout: 1)
    }
        
    // MARK: - compose active-active
    
    func test_compose_shouldCallCollaboratorWithPayload_activePaymentsTransfers_activeUtilitiesPayments() {
        
        let template = makeTemplate()
        let (sut, spy) = makeSUT(
            paymentsTransfersFlag: .active,
            utilitiesPaymentsFlag: .active(.live)
        )
        
        sut.makePayment((template, {})) { _ in }
        
        XCTAssertEqual(spy.payloads, [template])
    }
    
    func test_compose_shouldDeliverConnectivityError_activePaymentsTransfers_activeUtilitiesPayments() {
        
        let (sut, spy) = makeSUT(
            paymentsTransfersFlag: .active,
            utilitiesPaymentsFlag: .active(.live)
        )
        let exp = expectation(description: "wait for completion")
        
        sut.makePayment((makeTemplate(), {})) { result in
        
            switch result {
            case .failure(.connectivityError):
                break
                
            default:
                XCTFail("Expected failure, but got \(result) instead.")
            }
            
            exp.fulfill()
        }
        
        spy.complete(with: .failure(.connectivityError))

        wait(for: [exp], timeout: 1)
    }
    
    func test_compose_shouldDeliverServiceError_activePaymentsTransfers_activeUtilitiesPayments() {
        
        let message = anyMessage()
        let (sut, spy) = makeSUT(
            paymentsTransfersFlag: .active,
            utilitiesPaymentsFlag: .active(.live)
        )
        let exp = expectation(description: "wait for completion")
        
        sut.makePayment((makeTemplate(), {})) { result in
        
            switch result {
            case let .failure(.serverError(receivedMessage)):
                XCTAssertNoDiff(receivedMessage, message)
                
            default:
                XCTFail("Expected failure, but got \(result) instead.")
            }
            
            exp.fulfill()
        }
        
        spy.complete(with: .failure(.serverError(message)))

        wait(for: [exp], timeout: 1)
    }
    
    func test_compose_shouldDeliverPayment_activePaymentsTransfers_activeUtilitiesPayments() {
        
        let payment = makePayment()
        let (sut, spy) = makeSUT(
            paymentsTransfersFlag: .active,
            utilitiesPaymentsFlag: .active(.live)
        )
        let exp = expectation(description: "wait for completion")
        
        sut.makePayment((makeTemplate(), {})) { result in
        
            switch result {
            case let .success(.v1(receivedPayment)):
                XCTAssertNoDiff(receivedPayment, payment)
                
            default:
                XCTFail("Expected failure, but got \(result) instead.")
            }
            
            exp.fulfill()
        }
        
        spy.complete(with: .success(payment))

        wait(for: [exp], timeout: 1)
    }
        
    // MARK: - Helpers
    
    private typealias Composer = TemplatesListFlowEffectHandlerMicroServicesComposer<Payment>
    private typealias SUT = TemplatesListFlowEffectHandlerMicroServices<Payment>
    private typealias InitiatePaymentSpy = Spy<PaymentTemplateData, Payment, ServiceFailure>
    private typealias ServiceFailure = ServiceFailureAlert.ServiceFailure
    
    private func makeSUT(
        paymentsTransfersFlag: PaymentsTransfersFlag.RawValue,
        utilitiesPaymentsFlag: UtilitiesPaymentsFlag.RawValue,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: InitiatePaymentSpy
    ) {
        let model: Model = .mockWithEmptyExcept()
        let spy = InitiatePaymentSpy()
        let composer = Composer(
            initiatePayment: spy.process(_:completion:),
            model: model,
            paymentsTransfersFlag: .init(paymentsTransfersFlag),
            utilitiesPaymentsFlag: .init(utilitiesPaymentsFlag)
        )
        let sut = composer.compose()
        
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(composer, file: file, line: line)
        
        return (sut, spy)
    }
    
    private struct Payment: Equatable {
        
        let value: String
    }
    
    private func makePayment(
        _ value: String = anyMessage()
    ) -> Payment {
        
        return .init(value: value)
    }
    
    private func makeTemplate(
        id: Int = .random(in: 1...100),
        type: PaymentTemplateData.Kind = .housingAndCommunalService
    ) -> PaymentTemplateData {
        
        return .templateStub(paymentTemplateId: id, type: type)
    }
    
    private func makePayment(
        _ sut: SUT,
        template: PaymentTemplateData? = nil,
        assert: @escaping SUT.MakePaymentCompletion
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.makePayment((template ?? makeTemplate(), {})) {
            
            assert($0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
    }
}
