//
//  ResponseMapper+mapGetAllLatestPaymentsResponseTests.swift
//
//
//  Created by Igor Malyarov on 13.08.2024.
//

import LatestPaymentsBackendV3
import RemoteServices
import XCTest

final class ResponseMapper_mapGetAllLatestPaymentsResponseTests: XCTestCase {
    
    func test_map_shouldDeliverInvalidFailureOnEmptyData() {
        
        let emptyData: Data = .empty
        
        XCTAssertNoDiff(
            map(emptyData),
            .failure(.invalid(statusCode: 200, data: emptyData))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnInvalidData() {
        
        let invalidData: Data = .invalidData
        
        XCTAssertNoDiff(
            map(invalidData),
            .failure(.invalid(statusCode: 200, data: invalidData))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyJSON() {
        
        let emptyJSON: Data = .emptyJSON
        
        XCTAssertNoDiff(
            map(emptyJSON),
            .failure(.invalid(statusCode: 200, data: emptyJSON))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyDataResponse() {
        
        let emptyDataResponse: Data = .emptyDataResponse
        
        XCTAssertNoDiff(
            map(emptyDataResponse),
            .failure(.invalid(statusCode: 200, data: emptyDataResponse))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnNullServerResponse() {
        
        let nullServerResponse: Data = .nullServerResponse
        
        XCTAssertNoDiff(
            map(.nullServerResponse),
            .failure(.invalid(statusCode: 200, data: nullServerResponse))
        )
    }
    
    func test_map_shouldDeliverServerErrorOnServerError() {
        
        XCTAssertNoDiff(
            map(.serverError),
            .failure(.server(
                statusCode: 102,
                errorMessage: "Возникла техническая ошибка"
            ))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnNonOkHTTPResponse() throws {
        
        for statusCode in [199, 201, 399, 400, 401, 404] {
            
            let data = try data(from: "v3_getAllLatestPayments")
            let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
            
            XCTAssertNoDiff(
                map(data, nonOkResponse),
                .failure(.invalid(statusCode: statusCode, data: data))
            )
        }
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyList() {
        
        let emptyDataResponse: Data = .emptyListResponse
        
        XCTAssertNoDiff(
            map(emptyDataResponse),
            .failure(.invalid(statusCode: 200, data: emptyDataResponse))
        )
    }
    
    func test_fileData_count() throws {
        
        let mapped = try map(data(from: "v3_getAllLatestPayments")).get()
        
        XCTAssertEqual(mapped.count, 18)
    }
    
    func test_fileData() throws {
        
        let mapped = try map(data(from: "v3_getAllLatestPayments")).get()
        
        XCTAssertNoDiff(mapped.prefix(2), [
            makeService(
                additionalItems: [
                    makeAdditional(fieldName: "P1", fieldValue: "33694934")
                ],
                amount: 25.5,
                date: 1725603273000,
                detail: .internet,
                md5Hash: "fe9594527b02d8295319c7aca3d13ee0",
                name: "АКАДО Телеком",
                paymentDate: .init(timeIntervalSince1970: 1725603273000 / 1000),
                paymentFlow: .standard,
                puref: "iFora||CTV",
                type: .internet
            ),
            makeService(
                additionalItems: [
                    makeAdditional(fieldName: "account", fieldValue: "766440148001"),
                    makeAdditional(fieldName: "counter", fieldValue: "97"),
                    makeAdditional(fieldName: "counterDay", fieldValue: "97"),
                    makeAdditional(fieldName: "counterNight", fieldValue: "12"),
                    makeAdditional(fieldName: "fine", fieldValue: "42"),
                ],
                amount: 12.7,
                date: 1725601828000,
                detail: .housingAndCommunalService,
                inn: "7606052264",
                md5Hash: "1efeda3c9130101d4d88113853b03bb5",
                name: "ПАО ТНС энерго Ярославль",
                paymentDate: .init(timeIntervalSince1970: 1725601828000 / 1000),
                paymentFlow: .standard,
                puref: "iFora||TNS",
                type: .service
            ),
        ])
        
        XCTAssertNoDiff(mapped[2], makeService(
            additionalItems: [
                makeAdditional(fieldName: "account", fieldValue: "110110580"),
            ],
            amount: 12.5,
            date: 1725601648000,
            detail: .housingAndCommunalService,
            inn: "4029030252",
            md5Hash: "aeacabf71618e6f66aac16ed3b1922f3",
            name: "ПАО Калужская сбытовая компания",
            paymentDate: .init(timeIntervalSince1970: 1725601648000 / 1000),
            paymentFlow: .standard,
            puref: "iFora||KSK",
            type: .service
        ))
        
        XCTAssertNoDiff(mapped[3], makeService(
            additionalItems: [
                makeAdditional(fieldName: "P1", fieldValue: "161807"),
            ],
            amount: 11.5,
            date: 1725346984000,
            detail: .transport,
            md5Hash: "425e86123a5415c2ada1770b9e4abf1b",
            name: "Автодор Платные дороги (по договору)",
            paymentDate: .init(timeIntervalSince1970: 1725346984000 / 1000),
            paymentFlow: .transport,
            puref: "iFora||AVDD",
            type: .transport
        ))
        
        XCTAssertNoDiff(mapped[4], makeService(
            additionalItems: [
                makeAdditional(fieldName: "a3_divisionSelect_2_1", fieldValue: "inn_oktmo"),
                makeAdditional(fieldName: "a3_OKTMO_5_1", fieldValue: "45390000"),
                makeAdditional(fieldName: "a3_dutyCategory_1_1", fieldValue: "3"),
                makeAdditional(fieldName: "a3_categorySelect_3_1", fieldValue: "44"),
                makeAdditional(fieldName: "a3_INN_4_1", fieldValue: "7723013452"),
                makeAdditional(fieldName: "a3_address_2_2", fieldValue: "РОССИЙСКАЯ ФЕДЕРАЦИЯ, 125445, Москва г, Ленинградское ш,  д. 112,  к. 2,  кв. 563"),
                makeAdditional(fieldName: "a3_fio_1_2", fieldValue: "Пыркова Дарья Владимировна"),
                makeAdditional(fieldName: "a3_docValue_4_2", fieldValue: "183472137431"),
                makeAdditional(fieldName: "a3_docType_3_2", fieldValue: "2"),
            ],
            amount: 56,
            date: 1725023735000,
            detail: .taxAndStateService,
            md5Hash: "c2f4632ed9ee1b5cbd4fdaed5146e464",
            name: "ФНС",
            paymentDate: .init(timeIntervalSince1970: 1725023735000 / 1000),
            paymentFlow: .taxAndStateServices,
            puref: "iFora||6273",
            type: .taxAndStateService
        ))
        
        XCTAssertNoDiff(mapped[10], makeWithPhone(
            amount: 16.8,
            bankID: "1crt88888881",
            bankName: "Пир Банк",
            date: 1724054929000,
            detail: .sfp,
            paymentDate: .init(timeIntervalSince1970: 1724054929000 / 1000),
            phoneNumber: "0079191619658",
            puref: "iFora||TransferC2CSTEP",
            type: .phone
        ))
    }
    
    // MARK: - Helpers
    
    private typealias Response = [ResponseMapper.LatestPayment]
    private typealias MappingResult = ResponseMapper.MappingResult<Response>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapGetAllLatestPaymentsResponse(data, httpURLResponse)
    }
    
    private func assert(
        _ data: Data,
        _ response: Response,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let receivedResponse = try map(data).get()
        XCTAssertNoDiff(receivedResponse, response, file: file, line: line)
    }
    
    private func data(
        from filename: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Data {
        
        let filename = Bundle.module.url(forResource: filename, withExtension: "json")
        let url = try XCTUnwrap(filename, file: file, line: line)
        return try Data(contentsOf: url)
    }
    
    private func makeService(
        additionalItems: [ResponseMapper.LatestPayment.Service.AdditionalItem]? = nil,
        amount: Decimal? = nil,
        currency: String? = "RUB",
        date: Int,
        detail: ResponseMapper.LatestPayment.PaymentOperationDetailType? = nil,
        inn: String? = nil,
        lpName: String? = nil,
        md5Hash: String? = nil,
        name: String? = nil,
        paymentDate: Date,
        paymentFlow: ResponseMapper.LatestPayment.PaymentFlow? = nil,
        puref: String,
        type: ResponseMapper.LatestPayment.LatestType
    ) -> ResponseMapper.LatestPayment {
        
        return .service(.init(
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
        ))
    }
    
    private func makeAdditional(
        fieldName: String,
        fieldValue: String,
        fieldTitle: String? = nil,
        svgImage: String? = nil
    ) -> ResponseMapper.LatestPayment.Service.AdditionalItem {
        
        return .init(
            fieldName: fieldName,
            fieldValue: fieldValue,
            fieldTitle: fieldTitle,
            svgImage: svgImage
        )
    }
    
    private func makeWithPhone(
        amount: Decimal? = nil,
        bankID: String? = nil,
        bankName: String? = nil,
        currency: String? = "RUB",
        date: Int,
        detail: ResponseMapper.LatestPayment.PaymentOperationDetailType?,
        md5Hash: String? = nil,
        name: String? = nil,
        paymentDate: Date,
        paymentFlow: ResponseMapper.LatestPayment.PaymentFlow? = nil,
        phoneNumber: String? = nil,
        puref: String? = nil,
        type: ResponseMapper.LatestPayment.LatestType
    ) -> ResponseMapper.LatestPayment {
        
        return .withPhone(.init(
            amount: amount,
            bankID: bankID,
            bankName: bankName,
            currency: currency,
            date: date,
            detail: detail,
            md5Hash: md5Hash,
            name: name,
            paymentDate: paymentDate,
            paymentFlow: paymentFlow,
            phoneNumber: phoneNumber,
            puref: puref,
            type: type
        ))
    }
}

private extension Data {
    
    static let empty: Data = .init()
    static let invalidData: Data = String.invalidData.json
    static let emptyJSON: Data = String.emptyJSON.json
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let emptyListResponse: Data = String.emptyList.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let serverError: Data = String.serverError.json
}

private extension String {
    
    var json: Data { .init(self.utf8) }
    
    static let invalidData = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": { "a": "junk" }
}
"""
    
    static let emptyJSON = "{}"
    
    static let emptyDataResponse = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": {}
}
"""
    
    static let nullServerResponse = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": null
}
"""
    
    static let serverError = """
{
    "statusCode": 102,
    "errorMessage": "Возникла техническая ошибка",
    "data": null
}
"""
    
    static let emptyList = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": []
}
"""
}
