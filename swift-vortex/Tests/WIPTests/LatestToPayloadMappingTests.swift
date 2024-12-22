//
//  LatestToPayloadMappingTests.swift
//
//
//  Created by Igor Malyarov on 22.12.2024.
//

import LatestPaymentsBackendV3
import Foundation
import RemoteServices

extension RemoteServices.ResponseMapper.LatestPayment {
    
    enum PaymentPayload: Equatable {
        
        case mobilePaymentFlow(MobilePayload)
        case paymentFlow(PaymentFlow)
        
        struct MobilePayload: Equatable {
            
            let amount: Decimal
            let puref: String
            let fields: [Field]
        }
        
        struct Field: Equatable {
            
            let id: String // fieldName
            let title: String?
            let svg: String?
            let value: String
        }
    }
    
    var paymentPayload: PaymentPayload? {
        
        switch self {
        case let .service(service):
            switch service.paymentFlow {
            case .qr:
                return nil
                
            case .mobile:
                return service.mobilePayload.map { .mobilePaymentFlow($0) }
                
            default:
                return .paymentFlow(service.paymentFlow)
            }
            
        default:
            return nil
        }
    }
}

private extension RemoteServices.ResponseMapper.LatestPayment.Service {
    
    var mobilePayload: RemoteServices.ResponseMapper.LatestPayment.PaymentPayload.MobilePayload? {
        
        guard let amount else { return nil }
        
        return .init(
            amount: amount,
            puref: puref,
            fields: (additionalItems ?? []).map {
                
                return .init(id: $0.fieldName, title: $0.fieldTitle, svg: $0.svgImage, value: $0.fieldValue)
            }
        )
    }
}

import XCTest

final class LatestToPayloadMappingTests: XCTestCase {
    
    // MARK: - mobile
    
    func test_shouldDeliverNilOnServiceLatestPaymentWithMobilePaymentFlowNilAmount() {
        
        assert(
            makeServiceLatestPayment(
                amount: nil
            ),
            hasPayload: nil
        )
    }
    
    func test_shouldDeliverMobilePaymentFlowWithEmptyFieldsOnServiceLatestPaymentWithMobilePaymentFlowWithEmptyAdditionalItems() {
        
        let amount = makeAmount()
        let puref = anyMessage()
        
        assert(
            makeServiceLatestPayment(
                additionalItems: [],
                amount: amount,
                paymentFlow: .mobile,
                puref: puref
            ),
            hasPayload: .mobilePaymentFlow(.init(
                amount: amount,
                puref: puref,
                fields: []
            ))
        )
    }
    
    func test_shouldDeliverMobilePaymentFlowOnServiceLatestPaymentWithMobilePaymentFlow() {
        
        let (name, value, title, svg) = (anyMessage(), anyMessage(), anyMessage(), anyMessage())
        let amount = makeAmount()
        let puref = anyMessage()
        
        assert(
            makeServiceLatestPayment(
                additionalItems: [
                    .init(fieldName: name, fieldValue: value, fieldTitle: title, svgImage: svg)
                ],
                amount: amount,
                paymentFlow: .mobile,
                puref: puref
            ),
            hasPayload: .mobilePaymentFlow(.init(
                amount: amount,
                puref: puref,
                fields: [
                    .init(id: name, title: title, svg: svg, value: value)
                ]
            ))
        )
    }
    
    // MARK: - QR
    
    func test_shouldDeliverNilOnServiceLatestPaymentWithQRPaymentFlow() {
        
        assert(
            makeServiceLatestPayment(paymentFlow: .qr),
            hasPayload: nil
        )
    }
    
    // MARK: - standard
    
    func test_shouldDeliverStandardPaymentFlowOnServiceLatestPaymentWithStandardPaymentFlow() {
        
        assert(
            makeServiceLatestPayment(paymentFlow: .standard),
            hasPayload: .paymentFlow(.standard)
        )
    }
    
    // MARK: - taxAndStateServices
    
    func test_shouldDeliverTaxAndStateServicesPaymentFlowOnServiceLatestPaymentWithTaxAndStateServicesPaymentFlow() {
        
        assert(
            makeServiceLatestPayment(paymentFlow: .taxAndStateServices),
            hasPayload: .paymentFlow(.taxAndStateServices)
        )
    }
    
    // MARK: - transport
    
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
    
    private func makeAmount() -> Decimal {
        
        return .init(Int.random(in: 100...10_000)) / 100
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
