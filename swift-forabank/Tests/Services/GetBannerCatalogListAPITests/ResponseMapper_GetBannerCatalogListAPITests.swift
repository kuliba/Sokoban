//
//  ResponseMapper_GetBannerCatalogListAPITests.swift
//
//
//  Created by Andryusina Nataly on 29.08.2024.
//

import XCTest
@testable import GetBannerCatalogListAPI

typealias Result = ResponseMapper.GetBannerCatalogListResult

final class ResponseMapper_GetBannerCatalogListAPITests: XCTestCase {
    
    func test_map_returnInvalidErrorOnDataEmptyAndStatusCode200() {
        
        XCTAssertNoDiff(
            map(statusCode: 200, data: Data(String.emptyData.utf8)),
            getBannerCatalogListInvalidError(dataString: String.emptyData)
        )
    }
    
    func test_map_returnInvalidErrorOnErrorDataAndStatusCode200() {
        
        XCTAssertNoDiff(
            map(statusCode: 200, data: Data(String.errorData.utf8)),
            getBannerCatalogListInvalidError(dataString: String.errorData)
        )
    }
    
    func test_map_returnServer404WithMessageOnDataWithError404() {
        
        XCTAssertNoDiff(
            map(statusCode: 200, data: Data(String.error404.utf8)),
            getBannerCatalogListServerError(
                statusCode: 404,
                errorMessage: "404: Не найден запрос к серверу"
            )
        )
    }
    
    func test_map_returnEmptyProductsOnEmptyList() throws {
        
        let result = try XCTUnwrap(map(statusCode: 200, data: Data(String.emptyList.utf8))).get()
        
        XCTAssertNoDiff(result, .init(serial: "04ba222dd6021a0e41582c669cb8e9a4", bannerCatalogList: []))
    }
    
    func test_map_actionNil_shouldDeliverValidData() throws {
        
        let result = try XCTUnwrap(map(statusCode: 200, data: Data(String.actionNil.utf8))).get()
        
        XCTAssertNoDiff(result, .init(serial: "", bannerCatalogList: [
            .init(
                productName: "Турбо",
                conditions: ["Выгода 5% на топливо в приложении «Турбо»"],
                imageLink: "imageLink",
                orderLink: "orderLink",
                conditionLink: "conditionLink",
                action: nil)
        ]))
    }
    
    func test_map_actionMigTransfer_shouldDeliverValidData() throws {
        
        let result = try XCTUnwrap(map(statusCode: 200, data: Data(String.actionMigTransfer.utf8))).get()
        
        XCTAssertNoDiff(result, .init(serial: "", bannerCatalogList: [
            .init(
                productName: "Переводы МИГ",
                conditions: ["Мгновенные переводы в Армению. Комиссия 1%"],
                imageLink: "imageLink",
                orderLink: "orderLink",
                conditionLink: "conditionLink",
                action: .init(type: .migTransfer("AM")))
        ]))
    }
    
    func test_map_actionDeposits_shouldDeliverValidData() throws {
        
        let result = try XCTUnwrap(map(statusCode: 200, data: Data(String.actionDeposits.utf8))).get()
        
        XCTAssertNoDiff(result, .init(serial: "", bannerCatalogList: [
            .init(
                productName: "Выгодные вклады",
                conditions: ["Выгодные вклады 1%"],
                imageLink: "imageLink",
                orderLink: "orderLink",
                conditionLink: "conditionLink",
                action: .init(type: .depositsList))
        ]))
    }
    
    func test_map_actionContactTransfer_shouldDeliverValidData() throws {
        
        let result = try XCTUnwrap(map(statusCode: 200, data: Data(String.actionContactTransfer.utf8))).get()
        
        XCTAssertNoDiff(result, .init(serial: "", bannerCatalogList: [
            .init(
                productName: "Переводы за границу",
                conditions: ["Переводы за границу"],
                imageLink: "imageLink",
                orderLink: "orderLink",
                conditionLink: "conditionLink",
                action: .init(type: .contact("KG")))
        ]))
    }
    
    func test_map_actionOpenDeposit_shouldDeliverValidData() throws {
        
        let result = try XCTUnwrap(map(statusCode: 200, data: Data(String.actionDepositOpen.utf8))).get()
        
        XCTAssertNoDiff(result, .init(serial: "", bannerCatalogList: [
            .init(
                productName: "Выгодные вклады2",
                conditions: ["Выгодные вклады2"],
                imageLink: "imageLink",
                orderLink: "orderLink",
                conditionLink: "conditionLink",
                action: .init(type: .openDeposit(10000003792)))
        ]))
    }

    func test_map_actionLanding_shouldDeliverValidData() throws {
        
        let result = try XCTUnwrap(map(statusCode: 200, data: Data(String.actionLanding.utf8))).get()
        
        XCTAssertNoDiff(result, .init(serial: "", bannerCatalogList: [
            .init(
                productName: "Маркетплейс",
                conditions: ["Выгодно"],
                imageLink: "imageLink",
                orderLink: "",
                conditionLink: "",
                action: .init(type: .landing("market_showcase")))
        ]))
    }

    // MARK: - Helpers
    
    private func map(
        statusCode: Int = 200,
        data: Data
    ) -> Result {
        
        ResponseMapper.mapGetBannerCatalogListResponse(
            data,
            anyHTTPURLResponse(statusCode: statusCode)
        )
    }
    
    func getBannerCatalogListInvalidError(dataString: String?) -> Result {
        
        guard let dataString else {
            
            return .failure(.invalid(statusCode: 200, data: Data()))
        }
        
        return .failure(.invalid(statusCode: 200, data: Data(dataString.utf8)))
    }
    
    func getBannerCatalogListServerError(
        statusCode: Int,
        errorMessage: String
    ) -> Result {
        
        return .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
    }
    
}

private extension String {
    
    static let emptyData: Self = """
    {
      "statusCode": 0,
      "errorMessage": null,
      "data": null
    }
"""
    static let errorData: Self = """
    {
      "statusCode": 0,
      "errorMessage": null,
      "data": {
        "key": "value"
        }
    }
"""
    static let error404: Self = """
    {
      "statusCode":404,
      "errorMessage":"404: Не найден запрос к серверу",
      "data":null
    }
"""
    
    static let emptyList: Self = """
    {
        "statusCode":0,
        "errorMessage":null,
        "data":{
            "serial":"04ba222dd6021a0e41582c669cb8e9a4",
            "BannerCatalogList":[]
        }
    }
"""
    
    static let actionNil: Self = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "",
    "BannerCatalogList": [
      {
        "productName": "Турбо",
        "txtСondition": [
          "Выгода 5% на топливо в приложении «Турбо»"
        ],
        "imageLink": "imageLink",
        "orderLink": "orderLink",
        "conditionLink": "conditionLink",
        "action": null
      }
    ]
  }
}
"""
    
    static let actionMigTransfer: Self = """
    {
      "statusCode": 0,
      "errorMessage": null,
      "data": {
        "serial": "",
        "BannerCatalogList": [
          {
            "productName": "Переводы МИГ",
            "txtСondition": [
              "Мгновенные переводы в Армению. Комиссия 1%"
            ],
            "imageLink": "imageLink",
            "orderLink": "orderLink",
            "conditionLink": "conditionLink",
            "action": {
              "type": "MIG_TRANSFER",
              "countryId": "AM"
            }
          }
        ]
      }
    }
    """
    
    static let actionDeposits: Self = """
    {
      "statusCode": 0,
      "errorMessage": null,
      "data": {
        "serial": "",
        "BannerCatalogList": [
          {
            "productName": "Выгодные вклады",
            "txtСondition": [
              "Выгодные вклады 1%"
            ],
            "imageLink": "imageLink",
            "orderLink": "orderLink",
            "conditionLink": "conditionLink",
            "action": {
              "type": "DEPOSITS"
            }
          }
        ]
      }
    }
    """
    
    static let actionContactTransfer: Self = """
    {
      "statusCode": 0,
      "errorMessage": null,
      "data": {
        "serial": "",
        "BannerCatalogList": [
          {
            "productName": "Переводы за границу",
            "txtСondition": [
              "Переводы за границу"
            ],
            "imageLink": "imageLink",
            "orderLink": "orderLink",
            "conditionLink": "conditionLink",
            "action": {
              "type": "CONTACT_TRANSFER",
              "countryId": "KG"
            }
          }
        ]
      }
    }
    """
    
    static let actionDepositOpen: Self = """
    {
      "statusCode": 0,
      "errorMessage": null,
      "data": {
        "serial": "",
        "BannerCatalogList": [
          {
            "productName": "Выгодные вклады2",
            "txtСondition": [
              "Выгодные вклады2"
            ],
            "imageLink": "imageLink",
            "orderLink": "orderLink",
            "conditionLink": "conditionLink",
            "action": {
              "type": "DEPOSIT_OPEN",
              "depositProductID": "10000003792"
            }
          }
        ]
      }
    }
    """
    
    static let actionLanding: Self = """
    {
      "statusCode": 0,
      "errorMessage": null,
      "data": {
        "serial": "",
        "BannerCatalogList": [
          {
            "productName": "Маркетплейс",
            "txtСondition": [
              "Выгодно"
            ],
            "imageLink": "imageLink",
            "action": {
              "type": "LANDING",
              "target": "market_showcase"
            }
          }
        ]
      }
    }
    """
}
