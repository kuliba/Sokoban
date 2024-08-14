//
//  NanoServices+makeGetServiceCategoryListTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 13.08.2024.
//

@testable import ForaBank
import RemoteServices
import XCTest

final class NanoServices_makeGetServiceCategoryListTests: XCTestCase {
    
    func test_shouldCallHTTPClient() {
        
        let (sut, httpClient) = makeSUT()
        let exp = expectation(description: "wait for HTTPClient")
        
        sut { _ in exp.fulfill() }
        httpClient.complete(with: .success((anyData(), anyHTTPURLResponse())))
        
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_shouldCallHTTPClientWithGetServiceCategoryListRequest() throws {
        
        let (sut, httpClient) = makeSUT()
        let request = try createRequest()
        
        sut { _ in }
        
        XCTAssertNoDiff(httpClient.requests, [request])
    }
    
    func test_shouldDeliverInvalidFailureOnEmptyData() {
        
        let (sut, httpClient) = makeSUT()
        
        expect(sut, toDeliver: .failure(.connectivityError)) {
            
            httpClient.complete(with: .success((.empty, anyHTTPURLResponse())))
        }
    }
    
    func test_shouldDeliverInvalidFailureOnInvalidData() {
        
        let (sut, httpClient) = makeSUT()
        
        expect(sut, toDeliver: .failure(.connectivityError)) {
            
            httpClient.complete(with: .success((.invalidData, anyHTTPURLResponse())))
        }
    }
    
    func test_shouldDeliverInvalidFailureOnEmptyJSON() {
        
        let (sut, httpClient) = makeSUT()
        
        expect(sut, toDeliver: .failure(.connectivityError)) {
            
            httpClient.complete(with: .success((.emptyJSON, anyHTTPURLResponse())))
        }
    }
    
    func test_shouldDeliverInvalidFailureOnEmptyDataResponse() {
        
        let (sut, httpClient) = makeSUT()
        
        expect(sut, toDeliver: .failure(.connectivityError)) {
            
            httpClient.complete(with: .success((.emptyDataResponse, anyHTTPURLResponse())))
        }
    }
    
    func test_shouldDeliverInvalidFailureOnNullServerResponse() {
        
        let (sut, httpClient) = makeSUT()
        
        expect(sut, toDeliver: .failure(.connectivityError)) {
            
            httpClient.complete(with: .success((.nullServerResponse, anyHTTPURLResponse())))
        }
    }
    
    func test_shouldDeliverServerErrorOnServerError() {
        
        let (sut, httpClient) = makeSUT()
        
        expect(sut, toDeliver: .failure(.serverError("Возникла техническая ошибка"))) {
            
            httpClient.complete(with: .success((.serverError, anyHTTPURLResponse())))
        }
    }
    
    func test_shouldDeliverFailureOnNonOkHTTPResponse() throws {
        
        for statusCode in [199, 201, 399, 400, 401, 404] {
            
            let nonOkResponse = anyHTTPURLResponse(with: statusCode)
            let (sut, httpClient) = makeSUT()
            
            expect(sut, toDeliver: .failure(.connectivityError)) {
                
                httpClient.complete(with: .success((.valid, nonOkResponse)))
            }
        }
    }
    
    func test_shouldDeliverInvalidFailureOnEmptyList() {
        
        let (sut, httpClient) = makeSUT()
        
        expect(sut, toDeliver: .failure(.connectivityError)) {
            
            httpClient.complete(with: .success((.emptyDataResponse, anyHTTPURLResponse())))
        }
    }
    
    func test_shouldDeliverResponseWithOne() throws {
        
        let (sut, httpClient) = makeSUT()
        
        expect(sut, toDeliver: .success(.one)) {
            
            httpClient.complete(with: .success((.one, anyHTTPURLResponse())))
        }
    }
    
    func test_shouldDeliverResponse() throws {
        
        let (sut, httpClient) = makeSUT()
        
        expect(sut, toDeliver: .success(.valid)) {
            
            httpClient.complete(with: .success((.valid, anyHTTPURLResponse())))
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = NanoServices.GetServiceCategoryList
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClient: HTTPClientSpy
    ) {
        let httpClient = HTTPClientSpy()
        let sut = NanoServices.makeGetServiceCategoryList(httpClient, { _,_,_ in })
        
        return (sut, httpClient)
    }
    
    private func createRequest(
    ) throws -> URLRequest {
        
        try RequestFactory.createGetServiceCategoryListRequest()
    }
    
    private func expect(
        _ sut: SUT,
        toDeliver expectedResult: NanoServices.GetServiceCategoryListResult,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut {
            XCTAssertNoDiff($0, expectedResult, "Expected \(expectedResult), but got \($0) instead.", file: file, line: line)
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 0.1)
    }
}

private extension RemoteServices.ResponseMapper.GetServiceCategoryListResponse {
    
    static let one: Self = .init(
        categoryGroupList: [
            .init(
                latestPaymentsCategory: .mobile,
                md5Hash: "c16ee4f2d0b7cea6f8b92193bccce4d7",
                name: "Мобильная связь",
                ord: 20,
                paymentFlow: .mobile,
                search: false,
                type: .mobile
            )
        ],
        serial: "1bebd140bc2660211fbba306105479ae"
    )
    
    static let valid: Self = .init(
        categoryGroupList: [
            .init(
                latestPaymentsCategory: nil,
                md5Hash: "2d777a4bb3f53d495026b4884bbedde4",
                name: "Оплата по QR",
                ord: 10,
                paymentFlow: .qr,
                search: false,
                type: .qr
            ),
            .init(
                latestPaymentsCategory: .mobile,
                md5Hash: "c16ee4f2d0b7cea6f8b92193bccce4d7",
                name: "Мобильная связь",
                ord: 20,
                paymentFlow: .mobile,
                search: false,
                type: .mobile
            ),
            .init(
                latestPaymentsCategory: .service,
                md5Hash: "ffc64acafb053c5e6ebc4e9300f7cccc",
                name: "Услуги ЖКХ",
                ord: 30,
                paymentFlow: .standard,
                search: true,
                type: .housingAndCommunalService
            ),
            .init(
                latestPaymentsCategory: .service,
                md5Hash: "c15643f89507e5fd4f5caef8fbd3e4df",
                name: "Интернет, ТВ",
                ord: 40,
                paymentFlow: .standard,
                search: true,
                type: .internet
            ),
            .init(
                latestPaymentsCategory: .transport,
                md5Hash: "23d9ad3ce923f736b8ee4c5a11cb1915",
                name: "Транспорт",
                ord: 50,
                paymentFlow: .transport,
                search: false,
                type: .transport
            ),
            .init(
                latestPaymentsCategory: .taxAndStateService,
                md5Hash: "a49599eb358791b62b8d4c6341a163e5",
                name: "Налоги и госуслуги",
                ord: 60,
                paymentFlow: .taxAndStateServices,
                search: false,
                type: .taxAndStateService
            ),
            .init(
                latestPaymentsCategory: .security,
                md5Hash: "12e2479526b75f3ac2cf2b4bf420626d",
                name: "Охранные системы",
                ord: 70,
                paymentFlow: .standard,
                search: true,
                type: .security
            ),
            .init(
                latestPaymentsCategory: .digitalWallets,
                md5Hash: "39e857d35b8e683526ec4912845f1c55",
                name: "Электронный кошелек",
                ord: 80,
                paymentFlow: .standard,
                search: false,
                type: .digitalWallets
            ),
            .init(
                latestPaymentsCategory: .repaymentLoansAndAccounts,
                md5Hash: "9f37d214d2462f2c5dc952c553613cc6",
                name: "Погашение кредита ",
                ord: 90,
                paymentFlow: .standard,
                search: true,
                type: .repaymentLoansAndAccounts
            ),
            .init(
                latestPaymentsCategory: .socialAndGames,
                md5Hash: "d7d1c6adc224e96343c012ca1fcf1472",
                name: "Развлечения (игры и соц.сети)",
                ord: 100,
                paymentFlow: .standard,
                search: true,
                type: .socialAndGames
            ),
            .init(
                latestPaymentsCategory: .networkMarketing,
                md5Hash: "9a2b90b30cf0e65dccb44f43d3c1e145",
                name: "Сетевой маркетинг",
                ord: 110,
                paymentFlow: .standard,
                search: true,
                type: .networkMarketing
            ),
            .init(
                latestPaymentsCategory: .education,
                md5Hash: "a83b5b005fc16c356b2456d5a514c842",
                name: "Образование",
                ord: 120,
                paymentFlow: .standard,
                search: true,
                type: .education
            ),
            .init(
                latestPaymentsCategory: .charity,
                md5Hash: "f7463aa7646d1e2cfe33f71ab4a72d75",
                name: "Благотворительность",
                ord: 130,
                paymentFlow: .standard,
                search: true,
                type: .charity
            ),
        ],
        serial: "1bebd140bc2660211fbba306105479ae"
    )
}

private extension Data {
    
    static let invalidData: Data = String.invalidData.json
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let emptyListResponse: Data = String.emptyList.json
    static let one: Data = String.one.json
    static let valid: Data = String.valid.json
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
    
    static let emptyDataResponse = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": {}
}
"""
    
    static let emptyList = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "1bebd140bc2660211fbba306105479ae",
    "categoryGroupList": []
  }
}
"""
    
    static let one = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "1bebd140bc2660211fbba306105479ae",
    "categoryGroupList": [
      {
        "type": "mobile",
        "name": "Мобильная связь",
        "ord": 20,
        "md5hash": "c16ee4f2d0b7cea6f8b92193bccce4d7",
        "paymentFlow": "MOBILE",
        "latestPaymentsCategory": "isMobilePayments",
        "search": false
      }
    ]
  }
}
"""
    
    static let valid = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "1bebd140bc2660211fbba306105479ae",
    "categoryGroupList": [
      {
        "type": "qr",
        "name": "Оплата по QR",
        "ord": 10,
        "md5hash": "2d777a4bb3f53d495026b4884bbedde4",
        "paymentFlow": "QR",
        "latestPaymentsCategory": null,
        "search": false
      },
      {
        "type": "mobile",
        "name": "Мобильная связь",
        "ord": 20,
        "md5hash": "c16ee4f2d0b7cea6f8b92193bccce4d7",
        "paymentFlow": "MOBILE",
        "latestPaymentsCategory": "isMobilePayments",
        "search": false
      },
      {
        "type": "housingAndCommunalService",
        "name": "Услуги ЖКХ",
        "ord": 30,
        "md5hash": "ffc64acafb053c5e6ebc4e9300f7cccc",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isServicePayments",
        "search": true
      },
      {
        "type": "internet",
        "name": "Интернет, ТВ",
        "ord": 40,
        "md5hash": "c15643f89507e5fd4f5caef8fbd3e4df",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isServicePayments",
        "search": true
      },
      {
        "type": "transport",
        "name": "Транспорт",
        "ord": 50,
        "md5hash": "23d9ad3ce923f736b8ee4c5a11cb1915",
        "paymentFlow": "TRANSPORT",
        "latestPaymentsCategory": "isTransportPayments",
        "search": false
      },
      {
        "type": "taxAndStateService",
        "name": "Налоги и госуслуги",
        "ord": 60,
        "md5hash": "a49599eb358791b62b8d4c6341a163e5",
        "paymentFlow": "TAX_AND_STATE_SERVICE",
        "latestPaymentsCategory": "isTaxAndStateServicePayments",
        "search": false
      },
      {
        "type": "security",
        "name": "Охранные системы",
        "ord": 70,
        "md5hash": "12e2479526b75f3ac2cf2b4bf420626d",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isSecurityPayments",
        "search": true
      },
      {
        "type": "digitalWallets",
        "name": "Электронный кошелек",
        "ord": 80,
        "md5hash": "39e857d35b8e683526ec4912845f1c55",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isDigitalWalletsPayments",
        "search": false
      },
      {
        "type": "repaymentLoansAndAccounts",
        "name": "Погашение кредита ",
        "ord": 90,
        "md5hash": "9f37d214d2462f2c5dc952c553613cc6",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isRepaymentLoansAndAccountsPayments",
        "search": true
      },
      {
        "type": "socialAndGames",
        "name": "Развлечения (игры и соц.сети)",
        "ord": 100,
        "md5hash": "d7d1c6adc224e96343c012ca1fcf1472",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isSocialAndGamesPayments",
        "search": true
      },
      {
        "type": "networkMarketing",
        "name": "Сетевой маркетинг",
        "ord": 110,
        "md5hash": "9a2b90b30cf0e65dccb44f43d3c1e145",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isNetworkMarketingPayments",
        "search": true
      },
      {
        "type": "education",
        "name": "Образование",
        "ord": 120,
        "md5hash": "a83b5b005fc16c356b2456d5a514c842",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isEducationPayments",
        "search": true
      },
      {
        "type": "charity",
        "name": "Благотворительность",
        "ord": 130,
        "md5hash": "f7463aa7646d1e2cfe33f71ab4a72d75",
        "paymentFlow": "STANDARD_FLOW",
        "latestPaymentsCategory": "isCharityPayments",
        "search": true
      }
    ]
  }
}
"""
}
