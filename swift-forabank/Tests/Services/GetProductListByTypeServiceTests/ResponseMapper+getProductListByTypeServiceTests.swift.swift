//
//  ResponseMapper+getProductListByTypeServiceTests.swift
//
//
//  Created by Disman Dmitry on 13.03.2024.
//

import XCTest
@testable import GetProductListByTypeService

typealias Result = ResponseMapper.GetProductListByTypeResult

final class ResponseMapper_getProductListByTypeServiceTests: XCTestCase {
    
    func test_map_returnInvalidErrorOnDataEmptyAndStatusCode200() {
        
        XCTAssertNoDiff(
            map(statusCode: 200, data: Data(String.emptyData.utf8)),
            getProductListByTypeInvalidError(dataString: String.emptyData)
        )
    }
    
    func test_map_returnInvalidErrorOnErrorDataAndStatusCode200() {
        
        XCTAssertNoDiff(
            map(statusCode: 200, data: Data(String.errorData.utf8)),
            getProductListByTypeInvalidError(dataString: String.errorData)
        )
    }
    
    func test_map_returnServer404WithMessageOnDataWithError404() {
        
        XCTAssertNoDiff(
            map(statusCode: 200, data: Data(String.error404.utf8)),
            getProductListByTypeServerError(
                statusCode: 404,
                errorMessage: "404: Не найден запрос к серверу"
            )
        )
    }
    
    func test_map_returnAccountOnAccountData() throws {
        
        let result = try XCTUnwrap(map(data: JSON(for: .account))).get()
                
        XCTAssertNoDiff(result, .account)
    }
    
    func test_map_returnCardOnCardData() throws {
        
        let result = try XCTUnwrap(map(data: JSON(for: .card))).get()
                
        XCTAssertNoDiff(result, .card)
    }

    func test_map_returnDepositOnDepositData() throws {
        
        let result = try XCTUnwrap(map(data: JSON(for: .deposit))).get()
                
        XCTAssertNoDiff(result, .deposit)
    }
    
    func test_map_returnLoanOnLoanData() throws {
        
        let result = try XCTUnwrap(map(data: JSON(for: .loan))).get()
                
        XCTAssertNoDiff(result, .loan)
    }
    
    func test_map_statusPC23_returnStatusPCBlockedUnlockNotAvailable() throws {
        
        let result = try XCTUnwrap(map(data: JSON(by: .createJson(with: "23")))).get()
                
        XCTAssertNoDiff(result, .createCard(with: .blockedUnlockNotAvailable))
    }
    
    func test_map_statusPC21_returnStatusPCBlockedByClient() throws {
        
        let result = try XCTUnwrap(map(data: JSON(by: .createJson(with: "21")))).get()
                
        XCTAssertNoDiff(result, .createCard(with: .blockedByClient))
    }

    // MARK: - Helpers
    
    private func map(
        statusCode: Int = 200,
        data: Data
    ) -> Result {
        
        ResponseMapper.mapGetProductListByTypeResponse(
            data,
            anyHTTPURLResponse(statusCode: statusCode)
        )
    }
    
    private func JSON(for productType: ProductResponse.ProductType) throws -> Data {
        
        switch productType {
        case .account:
            return try Data(contentsOf: XCTUnwrap(accountStub))

        case .card:
            return try Data(contentsOf: XCTUnwrap(cardStub))

        case .deposit:
            return try Data(contentsOf: XCTUnwrap(depositStub))

        case .loan:
            return try Data(contentsOf: XCTUnwrap(loanStub))

        }
    }
    
    private func JSON(by string: String) -> Data {
        
        return Data(string.utf8)
    }
    
    private let accountStub = Bundle.module.url(forResource: "GetProductListByType_Account_Response", withExtension: "json")!
    private let cardStub = Bundle.module.url(forResource: "GetProductListByType_Card_Response", withExtension: "json")!
    private let depositStub = Bundle.module.url(forResource: "GetProductListByType_Deposit_Response", withExtension: "json")!
    private let loanStub = Bundle.module.url(forResource: "GetProductListByType_Loan_Response", withExtension: "json")!
}

private extension ResponseMapper_getProductListByTypeServiceTests {
    
    func getProductListByTypeInvalidError(dataString: String?) -> Result {
        
        guard let dataString else {
            
            return .failure(.invalid(statusCode: 200, data: Data()))
        }
        
        return .failure(.invalid(statusCode: 200, data: Data(dataString.utf8)))
    }
    
    func getProductListByTypeServerError(
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
    
    static func createJson(with statusPC: String) -> Self {
      
        return 
"""
        {
          "statusCode": 0,
          "errorMessage": null,
          "data": {
            "serial": "serial",
            "productList": [
              {
                "number": "4",
                "numberMasked": "4",
                "balance": 0,
                "currency": "RUB",
                "productType": "CARD",
                "productName": "productName",
                "ownerID": 4,
                "accountNumber": "4",
                "allowDebit": true,
                "allowCredit": true,
                "customName": "customName",
                "fontDesignColor": "FFFFFF",
                "mainField": "mainField",
                "additionalField": "additionalField",
                "smallDesignMd5hash": "smallDesignMd5hash",
                "mediumDesignMd5hash": "mediumDesignMd5hash",
                "background": [
                  "FFBB36"
                ],
                "openDate": 1631048400000,
                "branchId": 2000,
                "visibility": true,
                "order": 0,
                "smallBackgroundDesignHash": "smallBackgroundDesignHash",
                "productState": [
                  "DEFAULT",
                  "NOT_ACTIVATION",
                  "BLOCKED",
                  "NOT_VISIBILITY",
                  "BLOCKED_NOT_VISIBILITY"
                ],
                "cardID": 4,
                "accountID": 4,
                "name": "name",
                "validThru": 1790715600000,
                "status": "Действует",
                "expireDate": "09/26",
                "holderName": "holderName",
                "product": "product",
                "branch": "branch",
                "miniStatement": [],
                "paymentSystemName": "paymentSystemName",
                "paymentSystemImageMd5Hash": "paymentSystemImageMd5Hash",
                "idParent": null,
                "cardType": "REGULAR",
                "statusCard": "ACTIVE",
                "loanBaseParam": null,
                "largeDesignMd5hash": "largeDesignMd5hash",
                "id": 4,
                "balanceRUB": 0,
                "XLDesignMd5hash": "XLDesignMd5hash",
                "statusPC": "\(statusPC)"
      }
    ]
  }
}
"""
    }
}

private extension ProductResponse {
    
    static func createCard(with status: StatusPC) -> Self {
        
        .init(
            serial: "serial",
            products: [
                ProductResponse.Product(
                    commonProperties: ProductResponse.CommonProperties(
                        id: 4,
                        productType: .card,
                        productState: [
                            .default,
                            .notActivated,
                            .blocked,
                            .notVisible,
                            .blockedNotVisible
                        ],
                        order: 0,
                        visibility: true,
                        number: "4",
                        numberMasked: "4",
                        accountNumber: "4",
                        currency: "RUB",
                        mainField: "mainField",
                        additionalField: "additionalField",
                        customName: "customName",
                        productName: "productName",
                        balance: 0,
                        balanceRUB: 0,
                        openDate: 1631048400000,
                        ownerId: 4,
                        branchId: 2000,
                        allowDebit: true,
                        allowCredit: true,
                        fontDesignColor: "FFFFFF",
                        smallDesignMd5Hash: "smallDesignMd5hash",
                        mediumDesignMd5Hash: "mediumDesignMd5hash",
                        largeDesignMd5Hash: "largeDesignMd5hash",
                        xlDesignMd5Hash: "XLDesignMd5hash",
                        smallBackgroundDesignHash: "smallBackgroundDesignHash",
                        background: [
                            "FFBB36"
                        ]
                    ),
                    uniqueProperties: .card(
                        ProductResponse.Card(
                            cardID: 4,
                            idParent: nil,
                            accountID: 4,
                            cardType: .regular,
                            statusCard: .active,
                            loanBaseParam: nil,
                            statusPC: status,
                            name: "name",
                            validThru: 1790715600000,
                            status: .active,
                            expireDate: "09/26",
                            holderName: "holderName",
                            product: "product",
                            branch: "branch",
                            paymentSystemName: "paymentSystemName",
                            paymentSystemImageMd5Hash: "paymentSystemImageMd5Hash"
                        )
                    )
                )])
    }
}
