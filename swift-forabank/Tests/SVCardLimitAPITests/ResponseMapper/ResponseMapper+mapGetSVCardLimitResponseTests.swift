//
//  ResponseMapper+mapGetSVCardLimitResponseTests.swift
//
//
//  Created by Andryusina Nataly on 18.06.2024.
//

import SVCardLimitAPI
import RemoteServices
import XCTest

final class ResponseMapper_mapGetSVCardLimitResponseTests: XCTestCase {
    
    func test_map_shouldDeliverInvalidErrorOnInvalidData() throws {
        
        let invalidData = anyData()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }
    
    func test_map_shouldDeliverGetLimitErrorOnDataWithGetLimitErrorWithOkHTTPURLResponseStatusCode() throws {
        
        let okResponse = anyHTTPURLResponse(statusCode: 200)
        let result = map(jsonWithGetLimitError(), okResponse)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Ошибка получения лимитов. Попробуйте позже (1006)"
        )))
    }

    func test_map_shouldDeliverServerErrorOnDataWithServerErrorWithOkHTTPURLResponseStatusCode() throws {
        
        let okResponse = anyHTTPURLResponse(statusCode: 200)
        let result = map(jsonWithServerError(), okResponse)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Возникла техническая ошибка"
        )))
    }
    
    func test_map_shouldDeliverServerErrorOnDataWithServerErrorWithNonOkHTTPURLResponseStatusCode() throws {
        
        let nonOkResponse = anyHTTPURLResponse(statusCode: 400)
        let result = map(jsonWithServerError(), nonOkResponse)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Возникла техническая ошибка"
        )))
    }
    
    func test_map_shouldDeliverInvalidOnNonOkHTTPURLResponseStatusCode() throws {
        
        let statusCode = 400
        let data = anyData()
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
    
    func test_map_shouldDeliverInvalidOnOkHTTPURLResponseStatusCodeWithNullData() throws {
        
        let badData = Data(nullServerResponse.utf8)
        let result = map(badData)
        
        assert(result, equals: .failure(.invalid(statusCode: 200, data: badData)))
    }
    
    func test_map_shouldDeliverEmptyListOnOkHTTPURLResponseStatusCodeWithEmptyData() throws {
        
        let result = map(Data(emptyLimitsServerResponse.utf8))
        
        assert(result, equals: .success(.init(limitsList: [], serial: "111")))
    }
    
    func test_map_shouldDeliverListOnOkHTTPURLResponseStatusCodeWithValidData() throws {
        
        let result = map(Data(jsonStringWithValidData.utf8))
        
        assert(result,
               equals: .success(
                .init(
                    limitsList: [
                        .init(
                            type: "DEBIT_OPERATIONS",
                            limits: [
                                .init(currency: 810,
                                      currentValue: 900.09,
                                      name: "LMTTZ01",
                                      value: 1000.01)
                            ]),
                        .init(
                            type: "WITHDRAWAL",
                            limits: [
                                .init(currency: 810,
                                      currentValue: 90,
                                      name: "LMTTZ03",
                                      value: 100)
                            ])
                    ],
                    serial: nil)))
    }

    func test_map_shouldDeliverListWithZeroValuesOnOkHTTPURLResponseStatusCodeWithValidDataWithOutValues() throws {
        
        let result = map(Data(jsonStringWithValidDataWithOutValues.utf8))
        
        assert(result,
               equals: .success(
                .init(
                    limitsList: [
                        .init(
                            type: "DEBIT_OPERATIONS",
                            limits: [
                                .init(currency: 810,
                                      currentValue: 0,
                                      name: "LMTTZ01",
                                      value: 0)
                            ]),
                        .init(
                            type: "WITHDRAWAL",
                            limits: [
                                .init(currency: 810,
                                      currentValue: 0,
                                      name: "LMTTZ03",
                                      value: 0)
                            ])
                    ],
                    serial: nil)))
    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> ResponseMapper.GetSVCardLimitsResult {
        
        ResponseMapper.mapGetSVCardLimitsResponse(data, httpURLResponse)
    }
}
