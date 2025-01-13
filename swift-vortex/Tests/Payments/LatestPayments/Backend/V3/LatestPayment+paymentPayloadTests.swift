//
//  LatestPayment+paymentPayloadTests.swift
//
//
//  Created by Igor Malyarov on 22.12.2024.
//

import LatestPaymentsBackendV3
import RemoteServices
import XCTest

final class LatestPayment_paymentPayloadTests: XCTestCase {
    
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
    
    // MARK: - multiple
    
    func test_fileData() throws {
        
        let mapped = try ResponseMapper.mapGetAllLatestPaymentsResponse(data(from: "v3_getAllLatestPayments"), anyHTTPURLResponse()).get()
        
#warning("outside is not mapped!")
        
        XCTAssertNoDiff(
            mapped.map(\.paymentPayload)[0],
            .paymentFlow(.standard, .init(
                amount: 25.50,
                puref: "iVortex||CTV",
                fields: [makeField(id: "P1", value: "33694934")]
            ))
        )
        
        XCTAssertNoDiff(
            mapped.map(\.paymentPayload)[1],
            .paymentFlow(.standard, .init(
                amount: 12.70,
                puref: "iVortex||TNS",
                fields: [
                    makeField(id: "account", value: "766440148001"),
                    makeField(id: "counter", value: "97"),
                    makeField(id: "counterDay", value: "97"),
                    makeField(id: "counterNight", value: "12"),
                    makeField(id: "fine", value: "42")
                ]
            ))
        )
        
        XCTAssertNoDiff(
            mapped.map(\.paymentPayload)[2],
            .paymentFlow(.standard, .init(
                amount: 12.50,
                puref: "iVortex||KSK",
                fields: [makeField(id: "account", value: "110110580")]
            ))
        )
        
        XCTAssertNoDiff(
            mapped.map(\.paymentPayload)[3],
            .paymentFlow(.transport, .init(
                amount: 11.50,
                puref: "iVortex||AVDD",
                fields: [makeField(id: "P1", value: "161807")]
            ))
        )
        
        XCTAssertNoDiff(
            mapped.map(\.paymentPayload)[4],
            .paymentFlow(.taxAndStateServices, .init(
                amount: 56.00,
                puref: "iVortex||6273",
                fields: [
                    makeField(id: "a3_divisionSelect_2_1", value: "inn_oktmo"),
                    makeField(id: "a3_OKTMO_5_1", value: "45390000"),
                    makeField(id: "a3_dutyCategory_1_1", value: "3"),
                    makeField(id: "a3_categorySelect_3_1", value: "44"),
                    makeField(id: "a3_INN_4_1", value: "7723013452"),
                    makeField(id: "a3_address_2_2", value: "РОССИЙСКАЯ ФЕДЕРАЦИЯ, 125445, Москва г, Ленинградское ш,  д. 112,  к. 2,  кв. 563"),
                    makeField(id: "a3_fio_1_2", value: "Пыркова Дарья Владимировна"),
                    makeField(id: "a3_docValue_4_2", value: "183472137431"),
                    makeField(id: "a3_docType_3_2", value: "2")
                ]
            ))
        )
        
        XCTAssertNoDiff(
            mapped.map(\.paymentPayload)[5],
            .paymentFlow(.taxAndStateServices, .init(
                amount: 5000.00,
                puref: "iVortex||7069",
                fields: [
                    makeField(id: "a3_BillNumber_1_1", value: "18201800230035226326"),
                    makeField(id: "a3_fio_4_1", value: "Пыркова Дарья Владимировна"),
                    makeField(id: "a3_address_10_1", value: "РОССИЙСКАЯ ФЕДЕРАЦИЯ, 125445, Москва г, Ленинградское ш,  д. 112,  к. 2,  кв. 563")
                ]
            ))
        )
        
        XCTAssertNoDiff(
            mapped.map(\.paymentPayload)[6],
            .paymentFlow(.mobile, .init(
                amount: 63.00,
                puref: "iVortex||6169",
                fields: [makeField(id: "a3_PERSONAL_ACCOUNT_1_1", value: "9955082827")]
            ))
        )
        
        XCTAssertNoDiff(
            mapped.map(\.paymentPayload)[7],
            .paymentFlow(.mobile, .init(
                amount: 54.00,
                puref: "iVortex||4285",
                fields: [makeField(id: "a3_NUMBER_1_2", value: "9031115311")]
            ))
        )
        
        XCTAssertNoDiff(
            mapped.map(\.paymentPayload)[8],
            .paymentFlow(.standard, .init(
                amount: 123.00,
                puref: "iVortex||8084",
                fields: [
                    makeField(id: "a3_COMMENT_2_1", value: ""),
                    makeField(id: "a3_SUM_3_1", value: "123")
                ]
            ))
        )
        
        XCTAssertNoDiff(
            mapped.map(\.paymentPayload)[9],
            .paymentFlow(.standard, .init(
                amount: 10.00,
                puref: "iVortex||7994",
                fields: [makeField(id: "a3_PERSONAL_ACCOUNT_1_2", value: "kvna0908@gmail.com")]
            ))
        )
        
        XCTAssertNoDiff(
            mapped.map(\.paymentPayload)[10],
            .phone(.init(
                amount: 16.8,
                bankID: "1crt88888881",
                phoneNumber: "0079191619658",
                puref: "iVortex||TransferC2CSTEP"
            ))
        )
        
        XCTAssertNoDiff(
            mapped.map(\.paymentPayload)[11],
            .phone(.init(
                amount: 21,
                bankID: "1crt88888881",
                phoneNumber: "0070115110217",
                puref: "iVortex||TransferC2CSTEP"
            ))
        )
        
        XCTAssertNoDiff(mapped.map(\.paymentPayload)[12], nil)
        
        XCTAssertNil(mapped.map(\.paymentPayload)[13])
        
        XCTAssertNil(mapped.map(\.paymentPayload)[14])
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
    
    private func makeField(
        id: String,
        title: String? = nil,
        svg: String? = nil,
        value: String
    ) -> Latest.PaymentPayload.Payload.Field {
        
        return .init(id: id, title: title, svg: svg, value: value)
    }
    
    private func makeServiceLatestPayment(
        additionalItems: [ResponseMapper.LatestPayment.Service.AdditionalItem]? = nil,
        amount: Decimal? = nil,
        currency: String? = nil,
        date: Int = .random(in: 1...100),
        detail: ResponseMapper.LatestPayment.PaymentOperationDetailType = .addressless,
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
    
    func data(
        from filename: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Data {
        
        let filename = Bundle.module.url(forResource: filename, withExtension: "json")
        let url = try XCTUnwrap(filename, file: file, line: line)
        return try Data(contentsOf: url)
    }
}
