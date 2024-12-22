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
        
        case paymentFlow(PaymentFlow, Payload)
        case paymentFlow(PaymentFlow)
        
        struct Payload: Equatable {
            
            let amount: Decimal
            let puref: String
            let fields: [Field]
            
            struct Field: Equatable {
                
                let id: String // fieldName
                let title: String?
                let svg: String?
                let value: String
            }
        }
    }
    
    var paymentPayload: PaymentPayload? {
        
        switch self {
        case let .service(service):
            switch service.paymentFlow {
            case .qr:
                return nil
                
            case .mobile:
                return service.payload.map { .paymentFlow(.mobile, $0) }
                
            case .standard:
                return service.payload.map { .paymentFlow(.standard, $0) }
                
            default:
                return .paymentFlow(service.paymentFlow)
            }
            
        default:
            return nil
        }
    }
}

private extension RemoteServices.ResponseMapper.LatestPayment.Service {
    
    var payload: RemoteServices.ResponseMapper.LatestPayment.PaymentPayload.Payload? {
        
        guard let amount else { return nil }
        
        return .init(
            amount: amount,
            puref: puref,
            fields: (additionalItems ?? []).map {
                
                return .init(
                    id: $0.fieldName,
                    title: $0.fieldTitle,
                    svg: $0.svgImage,
                    value: $0.fieldValue
                )
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
            hasPayload: .paymentFlow(.mobile, .init(
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
            hasPayload: .paymentFlow(.mobile, .init(
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
    
    func test_shouldDeliverNilOnServiceLatestPaymentWithStandardPaymentFlowNilAmount() {
        
        assert(
            makeServiceLatestPayment(
                amount: nil,
                paymentFlow: .standard
            ),
            hasPayload: nil
        )
    }
    
    func test_shouldDeliverStandardPaymentFlowWithEmptyFieldsOnServiceLatestPaymentWithStandardPaymentFlowWithEmptyAdditionalItems() {
        
        let amount = makeAmount()
        let puref = anyMessage()
        
        assert(
            makeServiceLatestPayment(
                additionalItems: [],
                amount: amount,
                paymentFlow: .standard,
                puref: puref
            ),
            hasPayload: .paymentFlow(.standard, .init(
                amount: amount,
                puref: puref,
                fields: []
            ))
        )
    }
    
    func test_shouldDeliverStandardPaymentFlowOnServiceLatestPaymentWithStandardPaymentFlow() {
        
        let (name, value, title, svg) = (anyMessage(), anyMessage(), anyMessage(), anyMessage())
        let amount = makeAmount()
        let puref = anyMessage()
        
        assert(
            makeServiceLatestPayment(
                additionalItems: [
                    .init(fieldName: name, fieldValue: value, fieldTitle: title, svgImage: svg)
                ],
                amount: amount,
                paymentFlow: .standard,
                puref: puref
            ),
            hasPayload: .paymentFlow(.standard, .init(
                amount: amount,
                puref: puref,
                fields: [
                    .init(id: name, title: title, svg: svg, value: value)
                ]
            ))
        )
    }
    
    func test_shouldDeliverStandardPaymentFlowOnServiceLatestPaymentWithStandardPaymentFlowWithTwoAdditionalItems() {
        
        let (name1, value1, title1, svg1) = (anyMessage(), anyMessage(), anyMessage(), anyMessage())
        let (name2, value2, title2, svg2) = (anyMessage(), anyMessage(), anyMessage(), anyMessage())
        let amount = makeAmount()
        let puref = anyMessage()
        
        assert(
            makeServiceLatestPayment(
                additionalItems: [
                    .init(fieldName: name1, fieldValue: value1, fieldTitle: title1, svgImage: svg1),
                    .init(fieldName: name2, fieldValue: value2, fieldTitle: title2, svgImage: svg2)
                ],
                amount: amount,
                paymentFlow: .standard,
                puref: puref
            ),
            hasPayload: .paymentFlow(.standard, .init(
                amount: amount,
                puref: puref,
                fields: [
                    .init(id: name1, title: title1, svg: svg1, value: value1),
                    .init(id: name2, title: title2, svg: svg2, value: value2)
                ]
            ))
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
