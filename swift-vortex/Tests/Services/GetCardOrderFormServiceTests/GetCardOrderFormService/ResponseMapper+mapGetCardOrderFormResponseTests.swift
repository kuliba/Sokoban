//
//  ResponseMapper+mapGetCardOrderFormResponseTests.swift
//
//
//  Created by Дмитрий Савушкин on 27.03.2025.
//

import GetCardOrderFormService
import RemoteServices
import XCTest

final class ResponseMapper_mapGetCardOrderFormResponseTests_swift: XCTestCase {
    
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
    
    func test_shouldDeliverResponse_onValidData() throws {
        
        let validData: Data = .validData
        
        XCTAssertNoDiff(
            map(validData),
            .success(
                makeResponse(
                    list: [
                        .init(
                            conditionsLink: "https://www.forabank.ru/dkbo/dkbo.pdf",
                            tariffLink: "https://www.forabank.ru/tarify/",
                            list: [
                                .digital,
                                .unembossed,
                                .embossed
                            ]
                        )
                    ],
                    serial: "serial"
                )
            )
        )
    }
    
    // MARK: - Helpers
    
    private typealias Response = ResponseMapper.GetCardOrderFormDataResponse
    private typealias MappingResult = ResponseMapper.MappingResult<Response>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapGetCardOrderFormResponse(data, httpURLResponse)
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
        list: [ResponseMapper.GetCardOrderFormData] = [],
        serial: String = anyMessage()
    ) -> Response {
        
        return .init(list: list, serial: serial)
    }
    
    private func makeFormData(
        conditionsLink: String = anyMessage(),
        tariffLink: String = anyMessage(),
        list: [ResponseMapper.GetCardOrderFormData.Item] = []
    ) -> ResponseMapper.GetCardOrderFormData {
        
        return .init(
            conditionsLink: conditionsLink,
            tariffLink: tariffLink,
            list: list
        )
    }
    
    private func makeItem(
        type: String = anyMessage(),
        typeText: String = anyMessage(),
        id: String = anyMessage(),
        title: String = anyMessage(),
        description: String = anyMessage(),
        design: String = anyMessage(),
        currency: ResponseMapper.GetCardOrderFormData.Item.Currency? = nil,
        fee: ResponseMapper.GetCardOrderFormData.Item.Fee? = nil
    ) -> ResponseMapper.GetCardOrderFormData.Item {
        
        return .init(
            type: type,
            typeText: typeText,
            id: id,
            title: title,
            description: description,
            design: design,
            currency: currency ?? makeCurrency(),
            fee: fee ?? makeFee()
        )
    }
    
    private func makeCurrency(
        code: String = anyMessage(),
        symbol: String = anyMessage()
    ) -> ResponseMapper.GetCardOrderFormData.Item.Currency {
        
        return .init(code: code, symbol: symbol)
    }
    
    private func makeFee(
        maintenance: ResponseMapper.GetCardOrderFormData.Item.Fee.Maintenance? = nil,
        open: String = anyMessage()
    ) -> ResponseMapper.GetCardOrderFormData.Item.Fee {
        
        return .init(maintenance: maintenance ?? makeMaintenance(), open: open)
    }
    
    private func makeMaintenance(
        period: String = anyMessage(),
        value: Int = .random(in: 1...100)
    ) -> ResponseMapper.GetCardOrderFormData.Item.Fee.Maintenance {
        
        return .init(period: period, value: value)
    }
}

private extension ResponseMapper.GetCardOrderFormData.Item {
    
    static let digital: Self = .init(
        type: "DIGITAL",
        typeText: "Цифровая",
        id: "20000000119",
        title: "МИР, Всё включено 2.0",
        description: "Кешбэк до 10 Р в месяц",
        design: "6439f792279d4103f9d65243a02d8216",
        currency: .init(code: "810", symbol: "₽"),
        fee: .init(
            maintenance: .init(period: "free", value: 900),
            open: "0"
        )
    )
    
    static let unembossed: Self = .init(
        type: "UNEMBOSSED",
        typeText: "Физическая",
        id: "10000001457",
        title: "Премиальный, Visa Platinum",
        description: "% на остаток",
        design: "c81056de27fa28861c72ad6e248e1103",
        currency: .init(code: "810", symbol: "$"),
        fee: .init(
            maintenance: .init(
                period: "month",
                value: 100
            ),
            open: "50"
        )
    )
    
    static let embossed: Self = .init(
        type: "EMBOSSED",
        typeText: "Физическая (именная)",
        id: "10000000532",
        title: "Фора-эксклюзив, Visa Infinity",
        description: "Кешбэк",
        design: "e8d11b3218455a1dd77973d1059a84de",
        currency: .init(code: "978", symbol: "€"),
        fee: .init(
            maintenance: .init(
                period: "year",
                value: 800
            ),
            open: "100"
        )
    )
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
    
    static let validData = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "serial",
    "products": [
      {
        "conditionsLink": "https://www.forabank.ru/dkbo/dkbo.pdf",
        "tariffLink": "https://www.forabank.ru/tarify/",
        "list": [
          {
            "type": "DIGITAL",
            "typeText": "Цифровая",
            "id": "20000000119",
            "title": "МИР, Всё включено 2.0",
            "tariffName": "БОС ВСЁ ВКЛЮЧЕНО 2.0",
            "description": "Кешбэк до 10 Р в месяц",
            "design": "6439f792279d4103f9d65243a02d8216",
            "currency": {
              "code": "810",
              "symbol": "₽"
            },
            "fee": {
              "open": "0",
              "maintenance": {
                "period": "free",
                "value": 900
              }
            }
          },
          {
            "type": "UNEMBOSSED",
            "typeText": "Физическая",
            "id": "10000001457",
            "title": "Премиальный, Visa Platinum",
            "description": "% на остаток",
            "design": "c81056de27fa28861c72ad6e248e1103",
            "currency": {
              "code": "810",
              "symbol": "$"
            },
            "fee": {
              "open": "50",
              "maintenance": {
                "period": "month",
                "value": 100
              }
            }
          },
          {
            "type": "EMBOSSED",
            "typeText": "Физическая (именная)",
            "id": "10000000532",
            "title": "Фора-эксклюзив, Visa Infinity",
            "description": "Кешбэк",
            "design": "e8d11b3218455a1dd77973d1059a84de",
            "currency": {
              "code": "978",
              "symbol": "€"
            },
            "fee": {
              "open": "100",
              "maintenance": {
                "period": "year",
                "value": 800
              }
            }
          }
        ]
      }
    ]
  }
}
"""
}

