//
//  LatestToPayloadMappingTests.swift
//
//
//  Created by Igor Malyarov on 22.12.2024.
//

import LatestPaymentsBackendV3
import RemoteServices

extension RemoteServices.ResponseMapper.LatestPayment {
    
    enum PaymentPayload: Equatable {
        
        case paymentFlow(PaymentFlow)
    }
    
    var paymentPayload: PaymentPayload? {
        
        switch self {
        case let .service(service):
            switch service.paymentFlow {
            case .qr:
                return nil
                
            default:
                return .paymentFlow(service.paymentFlow)
            }
            
        default:
            return nil
        }
    }
}

import XCTest

final class LatestToPayloadMappingTests: XCTestCase {
    
    func test_shouldDeliverMobilePaymentFlowOnServiceLatestPaymentWithMobilePaymentFlow() {
        
        assert(
            makeServiceLatestPayment(paymentFlow: .mobile),
            hasPayload: .paymentFlow(.mobile)
        )
    }
    
    func test_shouldDeliverNilOnServiceLatestPaymentWithQRPaymentFlow() {
        
        assert(
            makeServiceLatestPayment(paymentFlow: .qr),
            hasPayload: nil
        )
    }
    
    func test_shouldDeliverStandardPaymentFlowOnServiceLatestPaymentWithStandardPaymentFlow() {
        
        assert(
            makeServiceLatestPayment(paymentFlow: .standard),
            hasPayload: .paymentFlow(.standard)
        )
    }
    
    func test_shouldDeliverTaxAndStateServicesPaymentFlowOnServiceLatestPaymentWithTaxAndStateServicesPaymentFlow() {
        
        assert(
            makeServiceLatestPayment(paymentFlow: .taxAndStateServices),
            hasPayload: .paymentFlow(.taxAndStateServices)
        )
    }
    
    func test_shouldDeliverTransportPaymentFlowOnServiceLatestPaymentWithTransportPaymentFlow() {
        
        assert(
            makeServiceLatestPayment(paymentFlow: .transport),
            hasPayload: .paymentFlow(.transport)
        )
    }
    
    // MARK: - Helpers
    
    private typealias Latest = RemoteServices.ResponseMapper.LatestPayment
    
    private func assert(
        _ service: Latest.Service,
        hasPayload expectedPayload: Latest.PaymentPayload?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let payload = Latest.service(service).paymentPayload
        
        XCTAssertNoDiff(payload, expectedPayload, "Expected \(String(describing: expectedPayload)), but got \(String(describing: payload)) instead.", file: file, line: line)
    }
    
    private func makeServiceLatestPayment(
        additionalItems: [ResponseMapper.LatestPayment.Service.AdditionalItem]? = nil,
        amount: Decimal? = nil,
        currency: String? = nil,
        date: Int = .random(in: 1...100),
        detail: ResponseMapper.LatestPayment.PaymentOperationDetailType? = nil,
        inn: String? = nil,
        lpName: String? = nil,
        md5Hash: String? = nil,
        name: String? = nil,
        paymentDate: Date = .init(),
        paymentFlow: ResponseMapper.LatestPayment.PaymentFlow = .qr,
        puref: String = anyMessage(),
        type: ResponseMapper.LatestPayment.LatestType = .security
    ) -> Latest.Service {
        
        return .init(
            additionalItems: additionalItems,
            amount: amount,
            currency: currency,
            date: date,
            detail: detail,
            inn: inn,
            lpName: lpName,
            md5Hash: md5Hash,
            name: name,
            paymentDate: paymentDate,
            paymentFlow: paymentFlow,
            puref: puref,
            type: type
        )
    }
}
