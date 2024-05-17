//
//  ResponseMapper+mapGetOperatorsListByParamOperatorOnlyFalseResponseTests.swift
//
//
//  Created by Дмитрий Савушкин on 19.02.2024.
//

import XCTest
import OperatorsListComponents

final class ResponseMapper_mapGetOperatorsListByParamOperatorOnlyFalseResponseTests: XCTestCase {
    
    func test_map_shouldDeliverInvalidErrorOnInvalidData() throws {
        
        let invalidData = "invalid data".data(using: .utf8)!
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }
    
    func test_map_shouldDeliverServerErrorOnDataWithServerErrorWithOkHTTPURLResponseStatusCode() throws {
        
        let okResponse = anyHTTPURLResponse(statusCode: 200)
        let result = map(jsonWithServerError(), okResponse)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Серверная ошибка при выполнении запроса"
        )))
    }
    
    func test_map_shouldDeliverServerErrorOnDataWithServerErrorWithNonOkHTTPURLResponseStatusCode() throws {
        
        let nonOkResponse = anyHTTPURLResponse(statusCode: 400)
        let result = map(jsonWithServerError(), nonOkResponse)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Серверная ошибка при выполнении запроса"
        )))
    }
    
    func test_map_shouldDeliverInvalidOnNonOkHTTPURLResponseStatusCode() throws {
        
        let statusCode = 400
        let data = Data()
        let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
        let result = map(data, nonOkResponse)
        
        assert(result, equals: .failure(.invalid(
            statusCode: statusCode,
            data: data
        )))
    }
    
    func test_map_shouldDeliverInvalidOnNonOkHTTPURLResponseStatusCodeWithBadData() throws {
        
        let badData = Data(jsonStringWithBadData.utf8)
        let statusCode = 400
        let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
        let result = map(badData, nonOkResponse)
        
        assert(result, equals: .failure(.invalid(
            statusCode: statusCode,
            data: badData
        )))
    }
    
    func test_map_shouldDeliverNilResponseOnOkHTTPURLResponseStatusCodeWithValidData() throws {
        
        let validData = Data(jsonStringWithEmpty.utf8)
        let result = map(validData)
        
        assert(result, equals: .failure(.invalid(statusCode: 200, data: validData)))
    }
    
    func test_map_shouldDeliverMultiServiceResponseOnOkHTTPURLResponseStatusCodeWithMultiServiceValidData() throws {
        
        let validData = Data(String.multiServicesValidJSON.utf8)
        let services = try map(validData).get()
        
        XCTAssertNoDiff(services.map(\.name), [
            "КОММУНАЛЬНЫЕ УСЛУГИ-МИРНАЯ 3",
            "КОММУНАЛЬНЫЕ УСЛУГИ-БУРАШЕВСКОЕ Ш 62",
            "КОММУНАЛЬНЫЕ УСЛУГИ-П ЗАВОЛЖСКИЙ",
            "КОММУНАЛЬНЫЕ УСЛУГИ-СТАРТОВАЯ 27",
            "КОММУНАЛЬНЫЕ УСЛУГИ-БУРАШЕВСКОЕ Ш 64",
            "КОММУНАЛЬНЫЕ УСЛУГИ-МОЖАЙСКОГО 62 К.1",
            "КОММУНАЛЬНЫЕ УСЛУГИ-БУРАШЕВСКОЕ Ш 66"
        ])
        
        XCTAssertNoDiff(services.map(\.puref), [
            "iForaNKORR||55177",
            "iForaNKORR||66659",
            "iForaNKORR||66681",
            "iForaNKORR||66685",
            "iForaNKORR||66689",
            "iForaNKORR||66691",
            "iForaNKORR||66692"
        ])
    }
    
    func test_map_shouldDeliverSingleServiceResponseOnOkHTTPURLResponseStatusCodeWithSingleServiceValidData() throws {
        
        let validData = Data(String.singleServiceValidJSON.utf8)
        let services = try map(validData).get()
        
        XCTAssertNoDiff(services.map(\.name), [
            "КАПРЕМОНТ (Р/С ...00024)"
        ])
        
        XCTAssertNoDiff(services.map(\.puref), [
            "iForaNKORR||42358"
        ])
    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> ResponseMapper.MappingResult<[ResponseMapper.SberUtilityService]> {
        
        ResponseMapper.mapGetOperatorsListByParamOperatorOnlyFalseResponse(data, httpURLResponse)
    }
}

private extension String {
    
    static let multiServicesValidJSON = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "45b51b783a5a629eafd41c45b7413a3e",
    "operatorList": [
      {
        "type": "housingAndCommunalService",
        "atributeList": [
          {
            "md5hash": "ef7a4271cdec35cc20c4ca0bb4d43f93",
            "juridicalName": "ООО УК КОТИАРА",
            "customerId": "2792",
            "serviceList": [
              {
                "channel": "iForaNKORR",
                "protocol": "55177",
                "descr": "КОММУНАЛЬНЫЕ УСЛУГИ-МИРНАЯ 3"
              },
              {
                "channel": "iForaNKORR",
                "protocol": "66659",
                "descr": "КОММУНАЛЬНЫЕ УСЛУГИ-БУРАШЕВСКОЕ Ш 62"
              },
              {
                "channel": "iForaNKORR",
                "protocol": "66681",
                "descr": "КОММУНАЛЬНЫЕ УСЛУГИ-П ЗАВОЛЖСКИЙ"
              },
              {
                "channel": "iForaNKORR",
                "protocol": "66685",
                "descr": "КОММУНАЛЬНЫЕ УСЛУГИ-СТАРТОВАЯ 27"
              },
              {
                "channel": "iForaNKORR",
                "protocol": "66689",
                "descr": "КОММУНАЛЬНЫЕ УСЛУГИ-БУРАШЕВСКОЕ Ш 64"
              },
              {
                "channel": "iForaNKORR",
                "protocol": "66691",
                "descr": "КОММУНАЛЬНЫЕ УСЛУГИ-МОЖАЙСКОГО 62 К.1"
              },
              {
                "channel": "iForaNKORR",
                "protocol": "66692",
                "descr": "КОММУНАЛЬНЫЕ УСЛУГИ-БУРАШЕВСКОЕ Ш 66"
              }
            ],
            "inn": "6950220774"
          }
        ]
      }
    ]
  }
}
"""
    
    static let singleServiceValidJSON = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "83216ac357627f84faccbf9438504370",
    "operatorList": [
      {
        "type": "housingAndCommunalService",
        "atributeList": [
          {
            "md5hash": "ef7a4271cdec35cc20c4ca0bb4d43f93",
            "juridicalName": "ООО ПИК-КОМФОРТ",
            "customerId": "8798",
            "serviceList": [
              {
                "channel": "iForaNKORR",
                "protocol": "42358",
                "descr": "КАПРЕМОНТ (Р/С ...00024)"
              }
            ],
            "inn": "7701208190"
          }
        ]
      }
    ]
  }
}
"""
}
