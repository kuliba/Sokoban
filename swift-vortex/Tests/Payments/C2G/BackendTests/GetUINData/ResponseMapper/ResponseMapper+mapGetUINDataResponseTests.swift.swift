//
//  ResponseMapper+mapGetUINDataResponseTests.swift.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import C2GBackend
import RemoteServices
import XCTest

final class ResponseMapper_mapGetUINDataResponseTests_swift: XCTestCase {
    
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
        
        let data: Data = .validData
        for statusCode in [199, 201, 399, 400, 401, 404] {
            
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
    
    func test_shouldDeliverResponse_onValid18810192085432512980_true() throws {
        
        let validData: Data = .valid18810192085432512980_true
        
        XCTAssertNoDiff(
            map(validData),
            .success(makeResponse(
                termsCheck: true,
                transAmm: 200,
                purpose: "Штраф ГИБДД",
                merchantName: "Федеральное Казначейство",
                dateN: "2024-08-26",
                legalAct: "Часть 1 статьи 12.16 КоАП",
                discountExpiry: "2024-12-25",
                discount: "50 %",
                uin: "18810192085432512980"
            ))
        )
    }
    
    func test_shouldDeliverResponse_onValid18810192085432512980() throws {
        
        let validData: Data = .valid18810192085432512980
        
        XCTAssertNoDiff(
            map(validData),
            .success(makeResponse(
                termsCheck: false,
                transAmm: 200,
                purpose: "Штраф ГИБДД",
                merchantName: "Федеральное Казначейство",
                dateN: "2024-08-26",
                legalAct: "Часть 1 статьи 12.16 КоАП",
                discountExpiry: "2024-12-25",
                discount: "50 %",
                uin: "18810192085432512980"
            ))
        )
    }
    
    func test_shouldDeliverResponse_onValid18810111111111212144() throws {
        
        let validData: Data = .valid18810111111111212144
        
        XCTAssertNoDiff(
            map(validData),
            .success(makeResponse(
                transAmm: 600.2,
                purpose: "Штраф ГИБДД 600,2р ВУ",
                merchantName: "ГУОБДД МВД России",
                dateN: "2024-12-03",
                legalAct: "12.09.2 - Превышение скорости движения ТС от 20 до 40 км/ч",
                discountExpiry: "2024-12-27",
                discount: "50 %",
                uin: "18810111111111212144"
            ))
        )
    }
    
    func test_shouldDeliverResponse_onValid18810111111111212446() throws {
        
        let validData: Data = .valid18810111111111212446
        
        XCTAssertNoDiff(
            map(validData),
            .success(makeResponse(
                transAmm: 900.1,
                purpose: "Штраф ГИБДД 900,1р СТС",
                merchantName: "ГУОБДД МВД России",
                dateN: "2024-12-03",
                legalAct: "12.09.2 - Превышение скорости движения ТС от 20 до 40 км/ч",
                uin: "18810111111111212446"
            ))
        )
    }
    
    func test_shouldDeliverResponse_onValid18810111111111212349() throws {
        
        let validData: Data = .valid18810111111111212349
        
        XCTAssertNoDiff(
            map(validData),
            .success(makeResponse(
                transAmm: 800.01,
                purpose: "Штраф ГИБДД 800,01р СТС",
                merchantName: "ГУОБДД МВД России",
                dateN: "2024-12-03",
                legalAct: "12.09.2 - Превышение скорости движения ТС от 20 до 40 км/ч",
                uin: "18810111111111212349"
                
            ))
        )
    }
    
    func test_shouldDeliverResponse_onValid18810111111111212047() throws {
        
        let validData: Data = .valid18810111111111212047
        
        XCTAssertNoDiff(
            map(validData),
            .success(makeResponse(
                transAmm: 500.02,
                purpose: "Штраф ГИБДД 500,02р ВУ",
                merchantName: "ГУОБДД МВД России",
                dateN: "2024-12-03",
                legalAct: "12.09.2 - Превышение скорости движения ТС от 20 до 40 км/ч",
                discountExpiry: "2024-12-27",
                discount: "50 %",
                payerINN: "126380940125",
                uin: "18810111111111212047"
            ))
        )
    }
    
    // MARK: - Helpers
    
    private typealias Response = ResponseMapper.GetUINDataResponse
    private typealias MappingResult = ResponseMapper.MappingResult<Response>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapGetUINDataResponse(data, httpURLResponse)
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
    
    private func makeResponse(
        termsCheck: Bool = false,
        transAmm: Decimal? = nil,
        purpose: String? = nil,
        merchantName: String? = nil,
        dateN: String? = nil,
        legalAct: String? = nil,
        paymentTerm: String? = nil,
        discountExpiry: String? = nil,
        discount: String? = nil,
        payerName: String? = nil,
        payerINN: String? = nil,
        payerKPP: String? = nil,
        url: URL = .init(string: "https://www.vortex.com/dkbo/dkbo.pdf")!,
        uin: String
    ) -> ResponseMapper.GetUINDataResponse {
        
        return .init(
            termsCheck: termsCheck,
            transAmm: transAmm,
            purpose: purpose,
            merchantName: merchantName,
            dateN: dateN,
            legalAct: legalAct,
            paymentTerm: paymentTerm,
            discountExpiry: discountExpiry,
            discount: discount,
            payerName: payerName,
            payerINN: payerINN,
            payerKPP: payerKPP,
            url: url,
            uin: uin
        )
    }
}

private extension Data {
    
    static let empty: Data = .init()
    static let emptyJSON: Data = String.emptyJSON.json
    static let invalidData: Data = String.invalidData.json
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let emptyListResponse: Data = String.emptyList.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let serverError: Data = String.serverError.json
    
    static let validData: Data = String.validData.json
    static let valid18810192085432512980_true: Data = String.valid18810192085432512980_true.json
    static let valid18810192085432512980: Data = String.valid18810192085432512980.json
    static let valid18810111111111212144: Data = String.valid18810111111111212144.json
    static let valid18810111111111212446: Data = String.valid18810111111111212446.json
    static let valid18810111111111212349: Data = String.valid18810111111111212349.json
    static let valid18810111111111212047: Data = String.valid18810111111111212047.json
}

private extension String {
    
    var json: Data { .init(utf8) }
    
    static let emptyJSON = "{}"
    
    static let invalidData = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": { "a": "junk" }
}
"""
    
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
    
    static let validData = valid18810192085432512980
    
    static let valid18810192085432512980_true = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "termsCheck": true,
    "transAmm": 200,
    "purpose": "Штраф ГИБДД",
    "merchantName": "Федеральное Казначейство",
    "dateN": "2024-08-26",
    "legalAct": "Часть 1 статьи 12.16 КоАП",
    "discountExpiry": "2024-12-25",
    "discount": "50 %",
    "url": "https://www.vortex.com/dkbo/dkbo.pdf",
    "UIN": "18810192085432512980"
  }
}
"""
    
    static let valid18810192085432512980 = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "termsCheck": false,
    "transAmm": 200,
    "purpose": "Штраф ГИБДД",
    "merchantName": "Федеральное Казначейство",
    "dateN": "2024-08-26",
    "legalAct": "Часть 1 статьи 12.16 КоАП",
    "discountExpiry": "2024-12-25",
    "discount": "50 %",
    "url": "https://www.vortex.com/dkbo/dkbo.pdf",
    "UIN": "18810192085432512980"
  }
}
"""
    
    static let valid18810111111111212144 = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "termsCheck": false,
    "transAmm": 600.2,
    "purpose": "Штраф ГИБДД 600,2р ВУ",
    "merchantName": "ГУОБДД МВД России",
    "dateN": "2024-12-03",
    "legalAct": "12.09.2 - Превышение скорости движения ТС от 20 до 40 км/ч",
    "discountExpiry": "2024-12-27",
    "discount": "50 %",
    "url": "https://www.vortex.com/dkbo/dkbo.pdf",
    "UIN": "18810111111111212144"
  }
}
"""
    
    static let valid18810111111111212446 = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "termsCheck": false,
    "transAmm": 900.1,
    "purpose": "Штраф ГИБДД 900,1р СТС",
    "merchantName": "ГУОБДД МВД России",
    "dateN": "2024-12-03",
    "legalAct": "12.09.2 - Превышение скорости движения ТС от 20 до 40 км/ч",
    "url": "https://www.vortex.com/dkbo/dkbo.pdf",
    "UIN": "18810111111111212446"
  }
}
"""
    
    static let valid18810111111111212349 = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "termsCheck": false,
    "transAmm": 800.01,
    "purpose": "Штраф ГИБДД 800,01р СТС",
    "merchantName": "ГУОБДД МВД России",
    "dateN": "2024-12-03",
    "legalAct": "12.09.2 - Превышение скорости движения ТС от 20 до 40 км/ч",
    "url": "https://www.vortex.com/dkbo/dkbo.pdf",
    "UIN": "18810111111111212349"
  }
}
"""
    
    static let valid18810111111111212047 = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "termsCheck": false,
    "transAmm": 500.02,
    "purpose": "Штраф ГИБДД 500,02р ВУ",
    "merchantName": "ГУОБДД МВД России",
    "dateN": "2024-12-03",
    "legalAct": "12.09.2 - Превышение скорости движения ТС от 20 до 40 км/ч",
    "discountExpiry": "2024-12-27",
    "discount": "50 %",
    "payerINN": "126380940125",
    "url": "https://www.vortex.com/dkbo/dkbo.pdf",
    "UIN": "18810111111111212047"
  }
}
"""
}
