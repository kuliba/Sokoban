//
//  RootViewModelFactoryServiceCategoryTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 05.12.2024.
//

@testable import Vortex
import SerialComponents
import XCTest

class RootViewModelFactoryServiceCategoryTests: RootViewModelFactoryTests {
    
    typealias Stamped = SerialStamped<String, [ServiceCategory]>
    typealias StampedResult = Result<Stamped, Error>
    
    func serial() -> String { "1bebd140bc2660211fbba306105479ae" }
    
    func categories() -> [ServiceCategory] {
        
        [.stub(
            latestPaymentsCategory: "isMobilePayments",
            md5Hash: "c16ee4f2d0b7cea6f8b92193bccce4d7",
            name: "Мобильная связь",
            ord: 20,
            flow: .mobile,
            hasSearch: false,
            type: "mobile"
        ),
         .stub(
            latestPaymentsCategory: "isServicePayments",
            md5Hash: "ffc64acafb053c5e6ebc4e9300f7cccc",
            name: "Услуги ЖКХ",
            ord: 30,
            flow: .standard,
            hasSearch: true,
            type: "housingAndCommunalService"
         ),
         .stub(
            latestPaymentsCategory: "isServicePayments",
            md5Hash: "c15643f89507e5fd4f5caef8fbd3e4df",
            name: "Интернет, ТВ",
            ord: 40,
            flow: .standard,
            hasSearch: true,
            type: "internet"
         )]
    }
    
    func stampedCategories() -> Stamped {
        
        return .init(value: categories(), serial: serial())
    }
    
    func getServiceCategoryListJSON() -> Data {
        
        return .init(String.getServiceCategoryListJSON.utf8)
    }
    
    func getOperatorsListByParamJSON() -> Data {
        
        return .init(String.getOperatorsListByParamJSON.utf8)
    }
    
    func makeCodableServiceCategory(
        latestPaymentsCategory: CodableServiceCategory.LatestPaymentsCategory? = nil,
        md5Hash: String = anyMessage(),
        name: String = anyMessage(),
        ord: Int = .random(in: 1...100),
        paymentFlow: CodableServiceCategory.PaymentFlow = .standard,
        hasSearch: Bool = .random(),
        type: CodableServiceCategory.CategoryType = "education"
    ) -> CodableServiceCategory {
        
        return .init(
            latestPaymentsCategory: latestPaymentsCategory,
            md5Hash: md5Hash,
            name: name,
            ord: ord,
            paymentFlow: paymentFlow,
            hasSearch: hasSearch,
            type: type
        )
    }
}

// MARK: - Stubs

private extension String {
    
    static let getServiceCategoryListJSON = """
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
      }
    ]
  }
}
"""
    
    static let getOperatorsListByParamJSON = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "e484a0fa6826200868cb821394efa1ef",
    "operatorList": [
      {
        "type": "housingAndCommunalService",
        "atributeList": [
          {
            "md5hash": "1efeda3c9130101d4d88113853b03bb5",
            "juridicalName": "ТОВАРИЩЕСТВО СОБСТВЕННИКОВ НЕДВИЖИМОСТИ ЧИСТОПОЛЬСКАЯ 61 А",
            "customerId": "12604",
            "serviceList": [],
            "inn": "1657251193"
          },
          {
            "md5hash": "1efeda3c9130101d4d88113853b03bb5",
            "juridicalName": "ООО  ИЛЬИНСКОЕ ЖКХ",
            "customerId": "17651",
            "serviceList": [],
            "inn": "3704561992"
          },
          {
            "md5hash": "1efeda3c9130101d4d88113853b03bb5",
            "juridicalName": "ООО МЕТАЛЛЭНЕРГОФИНАНС",
            "customerId": "21121",
            "serviceList": [],
            "inn": "4217039402"
          }
        ]
      }
    ]
  }
}
"""
}

// MARK: - Helpers

extension HTTPClientSpy {
    
    private var lastPathComponents: [String?] {
        
        requests.map(\.url?.lastPathComponent)
    }
    
    func expectRequests(
        withLastPathComponents expectedLastPathComponents: [String],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(lastPathComponents, expectedLastPathComponents, "Expected request(s) with \(expectedLastPathComponents) as lastPathComponents, but got \(self.lastPathComponents) instead.", file: file, line: line)
    }
    
    func expectRequests(
        withQueryValueFor name: String,
        match expectedLastPathComponents: [String],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let lastPathComponents = lastPathComponentsWithQueryValue(for: name)
        
        XCTAssertNoDiff(lastPathComponents, expectedLastPathComponents, "Expected request(s) with \(expectedLastPathComponents) as lastPathComponents, but got \(self.lastPathComponents) instead.", file: file, line: line)
    }
}

private extension String {
    
    static let standard = "STANDARD_FLOW"
}
