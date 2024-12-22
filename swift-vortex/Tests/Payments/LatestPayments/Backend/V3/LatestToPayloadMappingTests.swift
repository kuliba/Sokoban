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
            return service.payload.map { .paymentFlow(service.paymentFlow, $0) }
            
        default:
            return nil
        }
    }
}

private typealias LatestPayment = RemoteServices.ResponseMapper.LatestPayment

private extension LatestPayment.Service {
    
    var payload: LatestPayment.PaymentPayload.Payload? {
        
        guard paymentFlow != .qr,
              let amount
        else { return nil }
        
        return .init(
            amount: amount,
            puref: puref,
            fields: additionalItems?.map(\.field)  ?? []
        )
    }
}

private extension LatestPayment.Service.AdditionalItem {
    
    var field: LatestPayment.PaymentPayload.Payload.Field {
        
        return .init(id: fieldName, title: fieldTitle, svg: svgImage, value: fieldValue)
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
    
    func test_shouldDeliverNilOnServiceLatestPaymentWithTaxAndStateServicesPaymentFlowNilAmount() {
        
        assert(
            makeServiceLatestPayment(
                amount: nil,
                paymentFlow: .taxAndStateServices
            ),
            hasPayload: nil
        )
    }
    
    func test_shouldDeliverTaxAndStateServicesPaymentFlowWithEmptyFieldsOnServiceLatestPaymentWithTaxAndStateServicesPaymentFlowWithEmptyAdditionalItems() {
        
        let amount = makeAmount()
        let puref = anyMessage()
        
        assert(
            makeServiceLatestPayment(
                additionalItems: [],
                amount: amount,
                paymentFlow: .taxAndStateServices,
                puref: puref
            ),
            hasPayload: .paymentFlow(.taxAndStateServices, .init(
                amount: amount,
                puref: puref,
                fields: []
            ))
        )
    }
    
    func test_shouldDeliverTaxAndStateServicesPaymentFlowOnServiceLatestPaymentWithTaxAndStateServicesPaymentFlow() {
        
        let (name, value, title, svg) = (anyMessage(), anyMessage(), anyMessage(), anyMessage())
        let amount = makeAmount()
        let puref = anyMessage()
        
        assert(
            makeServiceLatestPayment(
                additionalItems: [
                    .init(fieldName: name, fieldValue: value, fieldTitle: title, svgImage: svg)
                ],
                amount: amount,
                paymentFlow: .taxAndStateServices,
                puref: puref
            ),
            hasPayload: .paymentFlow(.taxAndStateServices, .init(
                amount: amount,
                puref: puref,
                fields: [
                    .init(id: name, title: title, svg: svg, value: value)
                ]
            ))
        )
    }
    
    func test_shouldDeliverTaxAndStateServicesPaymentFlowOnServiceLatestPaymentWithTaxAndStateServicesPaymentFlowWithTwoAdditionalItems() {
        
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
                paymentFlow: .taxAndStateServices,
                puref: puref
            ),
            hasPayload: .paymentFlow(.taxAndStateServices, .init(
                amount: amount,
                puref: puref,
                fields: [
                    .init(id: name1, title: title1, svg: svg1, value: value1),
                    .init(id: name2, title: title2, svg: svg2, value: value2)
                ]
            ))
        )
    }
    
    // MARK: - transport
    
    func test_shouldDeliverNilOnServiceLatestPaymentWithTransportPaymentFlowNilAmount() {
        
        assert(
            makeServiceLatestPayment(
                amount: nil,
                paymentFlow: .transport
            ),
            hasPayload: nil
        )
    }
    
    func test_shouldDeliverTransportPaymentFlowWithEmptyFieldsOnServiceLatestPaymentWithTransportPaymentFlowWithEmptyAdditionalItems() {
        
        let amount = makeAmount()
        let puref = anyMessage()
        
        assert(
            makeServiceLatestPayment(
                additionalItems: [],
                amount: amount,
                paymentFlow: .transport,
                puref: puref
            ),
            hasPayload: .paymentFlow(.transport, .init(
                amount: amount,
                puref: puref,
                fields: []
            ))
        )
    }
    
    func test_shouldDeliverTransportPaymentFlowOnServiceLatestPaymentWithTransportPaymentFlow() {
        
        let (name, value, title, svg) = (anyMessage(), anyMessage(), anyMessage(), anyMessage())
        let amount = makeAmount()
        let puref = anyMessage()
        
        assert(
            makeServiceLatestPayment(
                additionalItems: [
                    .init(fieldName: name, fieldValue: value, fieldTitle: title, svgImage: svg)
                ],
                amount: amount,
                paymentFlow: .transport,
                puref: puref
            ),
            hasPayload: .paymentFlow(.transport, .init(
                amount: amount,
                puref: puref,
                fields: [
                    .init(id: name, title: title, svg: svg, value: value)
                ]
            ))
        )
    }
    
    func test_shouldDeliverTransportPaymentFlowOnServiceLatestPaymentWithTransportPaymentFlowWithTwoAdditionalItems() {
        
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
                paymentFlow: .transport,
                puref: puref
            ),
            hasPayload: .paymentFlow(.transport, .init(
                amount: amount,
                puref: puref,
                fields: [
                    .init(id: name1, title: title1, svg: svg1, value: value1),
                    .init(id: name2, title: title2, svg: svg2, value: value2)
                ]
            ))
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
