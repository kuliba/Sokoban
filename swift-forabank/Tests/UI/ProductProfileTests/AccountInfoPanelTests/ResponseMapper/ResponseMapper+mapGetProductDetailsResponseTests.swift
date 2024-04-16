//
//  ResponseMapper+mapGetProductDetailsResponseTests.swift
//
//
//  Created by Andryusina Nataly on 05.03.2024.
//

import AccountInfoPanel
import XCTest
import RemoteServices

final class ResponseMapper_mapGetProductDetailsResponseTests: XCTestCase {
    
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
    
    func test_map_shouldDeliverNilResponseOnOkHTTPURLResponseStatusCodeWithEmptyData() throws {
        
        let emptyData = Data(jsonStringWithEmpty.utf8)
        let result = map(emptyData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: emptyData
        )))
    }
    
    func test_map_shouldDeliverResponseOnOkHTTPURLResponseStatusCodeWithValidCardDetailsData() throws {
        
        let validData = Data(jsonStringCardDetails.utf8)
        let result = map(validData)
        
        assert(result, equals: .success(.cardDetails))
    }
    
    func test_map_shouldDeliverResponseOnOkHTTPURLResponseStatusCodeWithValidCardDetailsDataWithEmpty() throws {
        
        let validData = Data(jsonStringCardDetailsWithNull.utf8)
        let result = map(validData)
        
        assert(result, equals: .success(.cardDetailsWithEmpty))
    }
    
    func test_map_shouldDeliverResponseOnOkHTTPURLResponseStatusCodeWithValidAccountDetailsData() throws {
        
        let validData = Data(jsonStringAccountDetails.utf8)
        let result = map(validData)
        
        assert(result, equals: .success(.accountDetails))
    }
    
    func test_map_shouldDeliverResponseOnOkHTTPURLResponseStatusCodeWithValidDepositDetailsData() throws {
        
        let validData = Data(jsonStringDepositDetails.utf8)
        let result = map(validData)
        
        assert(result, equals: .success(.depositDetails))
    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> ResponseMapper.MappingResult<ProductDetails> {
        
        ResponseMapper.mapGetProductDetailsResponse(data, httpURLResponse)
    }
}

private extension ProductDetails {
    
    static let accountDetails: Self = .accountDetails(.init(
            accountNumber: "4081781000000000001",
            bic: "044525341",
            corrAccount: "30101810300000000341",
            inn: "7704113772",
            kpp: "770401001",
            payeeName: "Иванов Иван Иванович"))
    
    static let cardDetails: Self = .cardDetails(.init(
            accountNumber: "4081781000000000001",
            bic: "044525341",
            cardNumber: "4444555566661122",
            corrAccount: "30101810300000000341",
            expireDate: "08/25",
            holderName: "IVAN IVANOV",
            inn: "7704113772",
            kpp: "770401001",
            maskCardNumber: "4444 55** **** 1122",
            payeeName: "Иванов Иван Иванович",
            info: "Реквизиты счета доступны владельцу основной карты. Он сможет их посмотреть в ЛК.",
            md5hash: "72ffaeb111fbcbd37cb97e0c2886bc89"
    ))
    
    static let cardDetailsWithEmpty: Self = .cardDetails(.init(
            accountNumber: "",
            bic: "",
            cardNumber: "4444555566661122",
            corrAccount: "",
            expireDate: "08/25",
            holderName: "IVAN IVANOV",
            inn: "",
            kpp: "",
            maskCardNumber: "4444 55** **** 1122",
            payeeName: "",
            info: "",
            md5hash: ""
    ))

    
    static let depositDetails: Self = .depositDetails(.init(
            accountNumber: "4081781000000000001",
            bic: "044525341",
            corrAccount: "30101810300000000341",
            expireDate: "08/25",
            inn: "7704113772",
            kpp: "770401001",
            payeeName: "Иванов Иван Иванович"))
}
