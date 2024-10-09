//
//  ResponseMapper+mapCollateralLoanShowCaseResponseTests.swift
//  swift-forabank
//
//  Created by Valentin Ozerov on 08.10.2024.
//

import RemoteServices
import XCTest

@testable import CollateralLoanLanding

final class ResponseMapper_mapCollateralLoanShowCaseResponseTests: XCTestCase {
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
            .failure(.invalid(statusCode: 200, data: .invalidData))
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
            .failure(.invalid(statusCode: 200, data: .emptyDataResponse))
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
            let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
            
            XCTAssertNoDiff(
                map(.validData, nonOkResponse),
                .failure(.invalid(statusCode: statusCode, data: .validData))
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
    
    // MARK: - Helpers
    
    private typealias Response = [ResponseMapper.CollateralLoanLandingShowCaseModel]
    private typealias MappingResult = Swift.Result<
        ResponseMapper.CollateralLoanLandingShowCaseModel,
        ResponseMapper.MappingError
    >
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapCollateralLoanShowCaseResponse(data, httpURLResponse)
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
    static let validData: Data = String.validJson.json
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
    
    static let validJson = """
{
  "RestResult": {
    "statusCode": 0,
    "errorMessage": "",
    "data": {
      "serial": "d0f7b46028dc52536477c4639198658a",
      "id": "COLLATERAL_SHOWCASE",
      "products": [
        {
          "theme": "GRAY",
          "name": "Кредит под залог транспорта",
          "keyMarketingParams": {
            "rate": "от 17,5%",
            "amount": "до 15 млн ₽",
            "term": "До 84 месяцев"
          },
          "features": {
            "list": [
              {
                "bullet": true,
                "text": "0 ₽. Условия обслуживания"
              },
              {
                "bullet": false,
                "text": "Кешбэк до 10 000 ₽ в месяц"
              },
              {
                "bullet": true,
                "text": "5% выгода при покупке топлива"
              }
            ]
          },
          "image": "dict/getProductCatalogImage?image=/products/landing-image/collateral-loan/list_car_collateral_loan.png",
          "terms": "https://www.forabank.ru/",
          "landingId": "COLLATERAL_LOAN_CALC_CAR"
        },
        {
          "thema": "WHITE",
          "title": "Кредит под залог недвижимости",
          "keyMarketingParams": {
            "rate": "от 16,5 %",
            "amount": "До 15 млн. ₽",
            "term": "до 10 лет"
          },
          "features": {
            "header": "Под залог:",
            "list": [
              {
                "bullet": false,
                "text": "Квартиры"
              },
              {
                "bullet": false,
                "text": "Жилого дома с земельным участком"
              },
              {
                "bullet": true,
                "text": "Нежилого или складского помещения"
              }
            ],
            "image": "dict/getProductCatalogImage?image=/products/landing-image/collateral-loan/list_real_estate_collateral_loan.png"
          },
          "terms": "https://www.forabank.ru/",
          "landingId": "COLLATERAL_LOAN_CALC_REAL_ESTATE"
        }
      ]
    }
  }
}
"""
}
