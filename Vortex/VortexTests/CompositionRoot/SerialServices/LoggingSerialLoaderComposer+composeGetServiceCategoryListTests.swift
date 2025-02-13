//
//  LoggingSerialLoaderComposer+composeGetServiceCategoryListTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 15.10.2024.
//

@testable import Vortex
import VortexTools
import RemoteServices
import SerialComponents
import XCTest

final class LoggingSerialLoaderComposer_composeGetServiceCategoryListTests: LocalAgentTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, httpClient) = makeSUT()
        
        XCTAssertEqual(httpClient.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - load
    
    func test_load_shouldDeliverNilOnHTTPClientFailure() {
        
        let (sut, httpClient) = makeSUT()
        
        expect(
            load: compose(sut).load,
            delivers: { XCTAssertNil($0) },
            on: httpClient.complete(with: anyError())
        )
    }
    
    func test_load_shouldDeliverValueOnHTTPClientSuccess() {
        
        let (sut, httpClient) = makeSUT()
        
        expect(
            load: compose(sut).load,
            delivers: { XCTAssertNotNil($0) },
            on: httpClient.complete(with: .live_20240822)
        )
    }
    
    func test_load_shouldDeliverSameOnSecondLoadOnHTTPClientSuccess() {
        
        let (sut, httpClient) = makeSUT()
        
        expect(
            load: compose(sut).load,
            delivers: { XCTAssertNoDiff($0, .one) },
            on: httpClient.complete(with: .one)
        )
        
        expect(
            load: compose(sut).load,
            delivers: { XCTAssertNoDiff($0, .one) },
            on: ()
        )
    }
    
    func test_load_shouldNotCallHTTPClientOnSecondLoadOnHTTPClientSuccess() {
        
        let (sut, httpClient) = makeSUT()
        
        expect(
            load: compose(sut).load,
            on: httpClient.complete(with: .one)
        )
        
        expect(
            load: compose(sut).load,
            delivers: { XCTAssertNoDiff($0, .one) },
            on: ()
        )
        
        XCTAssertEqual(httpClient.callCount, 1)
    }
    
    // MARK: - reload
    
    func test_reload_shouldDeliverNilOnHTTPClientFailure() {
        
        let (sut, httpClient) = makeSUT()
        
        expect(
            load: compose(sut).reload,
            delivers: { XCTAssertNil($0) },
            on: httpClient.complete(with: anyError())
        )
    }
    
    func test_reload_shouldDeliverValueOnHTTPClientSuccess() {
        
        let (sut, httpClient) = makeSUT()
        
        expect(
            load: compose(sut).reload,
            delivers: { XCTAssertNotNil($0) },
            on: httpClient.complete(with: .live_20240822)
        )
    }
    
    func test_reload_shouldDeliverDifferentValueOnSecondHTTPClientSuccess() {
        
        let (sut, httpClient) = makeSUT()
        let reload = compose(sut).reload
        
        expect(
            load: reload,
            delivers: { XCTAssertNoDiff($0, .one) },
            on: httpClient.complete(with: .one)
        )
        
        expect(
            load: reload,
            delivers: { XCTAssertNoDiff($0, .two) },
            on: httpClient.complete(with: .two, at: 1)
        )
    }
    
    // MARK: - mix
    
    func test_load_shouldDeliverDifferentValueAfterReload() {
        
        let (sut, httpClient) = makeSUT()
        let (load, reload) = compose(sut)
        
        expect(
            load: load,
            delivers: { XCTAssertNoDiff($0, .one) },
            on: httpClient.complete(with: .one)
        )
        
        expect(
            load: reload,
            delivers: { XCTAssertNoDiff($0, .two) },
            on: httpClient.complete(with: .two, at: 1)
        )
        
        expect(
            load: load,
            delivers: { XCTAssertNoDiff($0, .two) },
            on: ()
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = LoggingSerialLoaderComposer
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClient: HTTPClientSpy
    ) {
        let httpClient = HTTPClientSpy()
        let sut = SUT(
            httpClient: httpClient,
            localAgent: localAgent,
            logger: LoggerSpy() // TODO: - add tests for logging
        )
        
        return (sut, httpClient)
    }
    
    private func compose(
        _ sut: SUT
    ) -> (load: Load<ServiceCategory>, reload: Load<ServiceCategory>) {
        
        return sut.composeGetServiceCategoryList()
    }
    
    private func expect<T>(
        load: Load<T>,
        _ description: String = "wait for load completion",
        timeout: TimeInterval = 0.1,
        delivers assert: @escaping ([T]?) -> Void = { _ in },
        on action: @autoclosure () -> Void
    ) {
        let exp = expectation(description: description)
        
        load {
            
            assert($0)
            exp.fulfill()
        }
        
        // await for actor thread-hop
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
}

// MARK: - stubs

private extension Array where Element == ServiceCategory {
    
    static let one: Self = [
        .init(
            latestPaymentsCategory: "isMobilePayments",
            md5Hash: "c16ee4f2d0b7cea6f8b92193bccce4d7",
            name: "Мобильная связь",
            ord: 20,
            paymentFlow: .mobile,
            hasSearch: false,
            type: "mobile"
        )
    ]
    
    static let two: Self = [
        .init(
            latestPaymentsCategory: "isEducationPayments",
            md5Hash: "a83b5b005fc16c356b2456d5a514c842",
            name: "Образование",
            ord: 120,
            paymentFlow: .standard,
            hasSearch: true,
            type: "education"
        ),
        .init(
            latestPaymentsCategory: "isCharityPayments",
            md5Hash: "f7463aa7646d1e2cfe33f71ab4a72d75",
            name: "Благотворительность",
            ord: 130,
            paymentFlow: .standard,
            hasSearch: true,
            type: "charity"
        )
    ]
}

private extension Data {
    
    static let one: Self = String.one.json
    static let two: Self = String.two.json
    static let live_20240822: Self = String.live_20240822.json
}

private extension String {
    
    var json: Data { .init(utf8) }
    
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
    
    static let two = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "84bf007c17787f15f95b7cddafd8f340",
    "categoryGroupList": [
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
    static let live_20240822 = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "84bf007c17787f15f95b7cddafd8f340",
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
        "latestPaymentsCategory": "isInternetPayments",
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
        "name": "Погашение кредита",
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

private extension String {
    
    static let standard = "STANDARD_FLOW"
}
