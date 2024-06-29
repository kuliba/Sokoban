//
//  ResponseMapper+mapGetAllLatestServicePaymentsResponseTests.swift
//
//
//  Created by Igor Malyarov on 25.03.2024.
//

import LatestPayments
import RemoteServices
import XCTest

final class ResponseMapper_mapGetAllLatestServicePaymentsResponseTests: XCTestCase {
    
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
        
        let serverError: Data = .serverError
        
        XCTAssertNoDiff(
            map(serverError),
            .failure(.server(
                statusCode: 102,
                errorMessage: "Возникла техническая ошибка"
            ))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnNonOkHTTPResponse() {
        
        for statusCode in [199, 201, 399, 400, 401, 404] {
            
            let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
            
            XCTAssertNoDiff(
                map(.validData, nonOkResponse),
                .failure(.invalid(
                    statusCode: statusCode,
                    data: .validData
                ))
            )
        }
    }
    
    func test_map_shouldDeliverInvalidFailureOnNonService() {
        
        let nonService: Data = .nonService
        
        XCTAssertNoDiff(
            map(nonService),
            .failure(.invalid(statusCode: 200, data: nonService))
        )
    }
    
    func test_map_shouldDeliverResponse_validDataSingle() throws {
        
        try assert(.validDataSingle, [
            makeLatestServicePayment(
                date: makeDate(4, 9, 2023, 16, 51, 53),
                amount: 999,
                name: "ПАО Калужская сбытовая компания",
                md5Hash: "aeacabf71618e6f66aac16ed3b1922f3",
                puref: "iFora||KSK",
                additionalItems: [
                    makeAdditionalItem(
                        fieldName: "account",
                        fieldValue: "110110581"
                    ),
                ]
            )
        ])
    }
    
    func test_map_shouldDeliverResponse_validData() throws {
        
        try assert(.validData, [
            makeLatestServicePayment(
                date: makeDate(28, 06, 2024, 20, 19, 21),
                amount: 777,
                name: "МУП АГО АНГАРСКИЙ ВОДОКАНАЛ",
                md5Hash: "1efeda3c9130101d4d88113853b03bb5",
                puref: "iForaNKORR||18650",
                additionalItems: [
                    makeAdditionalItem(
                        fieldName: "1",
                        fieldValue: "100062"
                    ),
                    makeAdditionalItem(
                        fieldName: "2",
                        fieldValue: "0121"
                    ),
                    makeAdditionalItem(
                        fieldName: "8",
                        fieldValue: " "
                    ),
                    makeAdditionalItem(
                        fieldName: "12",
                        fieldValue: " "
                    ),
                    makeAdditionalItem(
                        fieldName: "SumSTrs",
                        fieldValue: "777"
                    ),
                ]
            ),
            makeLatestServicePayment(
                date: makeDate(27, 06, 2024, 7, 44, 33),
                amount: 6820,
                name: "ООО БАЙКАЛЬСКАЯ ЭНЕРГЕТИЧЕСКАЯ КОМПАНИЯ",
                md5Hash: "1efeda3c9130101d4d88113853b03bb5",
                puref: "iForaNKORR||18631",
                additionalItems: [
                    makeAdditionalItem(
                        fieldName: "1",
                        fieldValue: "АБ02Т0000862"
                    ),
                    makeAdditionalItem(
                        fieldName: "4",
                        fieldValue: "012021"
                    ),
                    makeAdditionalItem(
                        fieldName: "8",
                        fieldValue: " "
                    ),
                    makeAdditionalItem(
                        fieldName: "63",
                        fieldValue: "3910"
                    ),
                    makeAdditionalItem(
                        fieldName: "66",
                        fieldValue: "2910"
                    ),
                ]
            ),
        ])
    }
    
    // MARK: - Helpers
    
    private typealias Response = [ResponseMapper.LatestServicePayment]
    private typealias MappingResult = ResponseMapper.MappingResult<Response>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapGetAllLatestServicePaymentsResponse(data, httpURLResponse)
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
    
    private func makeDate(
        _ day: Int,
        _ month: Int,
        _ year: Int,
        _ hour: Int,
        _ minute: Int,
        _ second: Int
    ) throws -> Date {
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        
        let calendar = Calendar(identifier: .gregorian)
        return try XCTUnwrap(calendar.date(from: dateComponents))
    }
    
    private func makeLatestServicePayment(
        date: Date,
        amount: Decimal,
        name: String,
        md5Hash: String?,
        puref: String,
        additionalItems: [ResponseMapper.LatestServicePayment.AdditionalItem]
    ) -> ResponseMapper.LatestServicePayment {
        
        return .init(
            date: date,
            amount: amount,
            name: name,
            md5Hash: md5Hash,
            puref: puref,
            additionalItems: additionalItems
        )
    }
    
    private func makeAdditionalItem(
        fieldName: String,
        fieldValue: String,
        fieldTitle: String? = nil,
        svgImage: String? = nil
    ) -> ResponseMapper.LatestServicePayment.AdditionalItem {
        
        return .init(
            fieldName: fieldName,
            fieldValue: fieldValue,
            fieldTitle: fieldTitle,
            svgImage: svgImage
        )
    }
}

private extension Data {
    
    static let empty: Data = .init()
    static let invalidData: Data = String.invalidData.json
    static let emptyJSON: Data = String.emptyJSON.json
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let serverError: Data = String.serverError.json
    static let nonService: Data = String.nonService.json
    static let validDataSingle: Data = String.validDataSingle.json
    static let validData: Data = String.validData.json
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
    
    static let validDataSingle = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": [
        {
            "paymentDate": "04.09.2023 16:51:53",
            "date": 1693835513315,
            "type": "service",
            "amount": 999.00,
            "puref": "iFora||KSK",
            "lpName": null,
            "md5hash": "aeacabf71618e6f66aac16ed3b1922f3",
            "name": "ПАО Калужская сбытовая компания",
            "additionalList": [
                {
                    "fieldName": "account",
                    "fieldValue": "110110581",
                    "fieldTitle": null,
                    "svgImage": null,
                    "recycle": null,
                    "typeIdParameterList": null
                }
            ]
        }
    ]
}
"""
    
    static let nonService = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": [
        {
            "paymentDate": "04.09.2023 16:51:53",
            "date": 1693835513315,
            "type": "non-service",
            "amount": 999.00,
            "puref": "iFora||KSK",
            "lpName": null,
            "md5hash": "aeacabf71618e6f66aac16ed3b1922f3",
            "name": "ПАО Калужская сбытовая компания",
            "additionalList": [
                {
                    "fieldName": "account",
                    "fieldValue": "110110581",
                    "fieldTitle": null,
                    "svgImage": null,
                    "recycle": null,
                    "typeIdParameterList": null
                }
            ]
        }
    ]
}
"""
    
    static let validData = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": [
    {
      "paymentDate": "28.06.2024 20:19:21",
      "date": 1719595161000,
      "type": "service",
      "amount": 777,
      "puref": "iForaNKORR||18650",
      "lpName": null,
      "md5hash": "1efeda3c9130101d4d88113853b03bb5",
      "name": "МУП АГО АНГАРСКИЙ ВОДОКАНАЛ",
      "additionalList": [
        {
          "fieldName": "1",
          "fieldValue": "100062",
          "fieldTitle": null,
          "svgImage": null,
          "recycle": null,
          "typeIdParameterList": null
        },
        {
          "fieldName": "2",
          "fieldValue": "0121",
          "fieldTitle": null,
          "svgImage": null,
          "recycle": null,
          "typeIdParameterList": null
        },
        {
          "fieldName": "8",
          "fieldValue": " ",
          "fieldTitle": null,
          "svgImage": null,
          "recycle": null,
          "typeIdParameterList": null
        },
        {
          "fieldName": "12",
          "fieldValue": " ",
          "fieldTitle": null,
          "svgImage": null,
          "recycle": null,
          "typeIdParameterList": null
        },
        {
          "fieldName": "SumSTrs",
          "fieldValue": "777",
          "fieldTitle": null,
          "svgImage": null,
          "recycle": null,
          "typeIdParameterList": null
        }
      ]
    },
    {
      "paymentDate": "27.06.2024 07:44:33",
      "date": 1719463473000,
      "type": "service",
      "amount": 6820,
      "puref": "iForaNKORR||18631",
      "lpName": null,
      "md5hash": "1efeda3c9130101d4d88113853b03bb5",
      "name": "ООО БАЙКАЛЬСКАЯ ЭНЕРГЕТИЧЕСКАЯ КОМПАНИЯ",
      "additionalList": [
        {
          "fieldName": "1",
          "fieldValue": "АБ02Т0000862",
          "fieldTitle": null,
          "svgImage": null,
          "recycle": null,
          "typeIdParameterList": null
        },
        {
          "fieldName": "4",
          "fieldValue": "012021",
          "fieldTitle": null,
          "svgImage": null,
          "recycle": null,
          "typeIdParameterList": null
        },
        {
          "fieldName": "8",
          "fieldValue": " ",
          "fieldTitle": null,
          "svgImage": null,
          "recycle": null,
          "typeIdParameterList": null
        },
        {
          "fieldName": "63",
          "fieldValue": "3910",
          "fieldTitle": null,
          "svgImage": null,
          "recycle": null,
          "typeIdParameterList": null
        },
        {
          "fieldName": "66",
          "fieldValue": "2910",
          "fieldTitle": null,
          "svgImage": null,
          "recycle": null,
          "typeIdParameterList": null
        }
      ]
    }
  ]
}
"""
}
