//
//  ResponseMapper_getProductListByTypeV6ServiceTests.swift
//
//
//  Created by Andryusina Nataly on 14.08.2024.
//

import XCTest
@testable import GetProductListByTypeV6Service

typealias Result = ResponseMapper.GetProductListByTypeV6Result

final class ResponseMapper_getProductListByTypeV6ServiceTests: XCTestCase {
    
    func test_map_returnInvalidErrorOnDataEmptyAndStatusCode200() {
        
        XCTAssertNoDiff(
            map(statusCode: 200, data: Data(String.emptyData.utf8)),
            getProductListByTypeV6InvalidError(dataString: String.emptyData)
        )
    }
    
    func test_map_returnInvalidErrorOnErrorDataAndStatusCode200() {
        
        XCTAssertNoDiff(
            map(statusCode: 200, data: Data(String.errorData.utf8)),
            getProductListByTypeV6InvalidError(dataString: String.errorData)
        )
    }
    
    func test_map_returnServer404WithMessageOnDataWithError404() {
        
        XCTAssertNoDiff(
            map(statusCode: 200, data: Data(String.error404.utf8)),
            getProductListByTypeV6ServerError(
                statusCode: 404,
                errorMessage: "404: Не найден запрос к серверу"
            )
        )
    }
    
    func test_map_returnEmptyProductsOnEmptyList() throws {
       
        let result = try XCTUnwrap(map(statusCode: 200, data: Data(String.emptyList.utf8))).get()

        XCTAssertNoDiff(result, .init(serial: "04ba222dd6021a0e41582c669cb8e9a4", products: []))
    }
    
    func test_map_returnAccountOnAccountData() throws {
        
        let results = try XCTUnwrap(map(data: json(for: .account))).get()
        var expectedResults: [ProductsResponse] = [
            .init(
                serial: "111",
                products: .accounts)]
        
        assert([results], equals: &expectedResults)
    }
    
    func test_map_returnCardsOnCardsData() throws {
        
        let results = try XCTUnwrap(map(data: json(for: .card))).get()
        var expectedResults: [ProductsResponse] = [
            .init(
                serial: "111",
                products: .cards
            )]
        assert([results], equals: &expectedResults)
    }

    func test_map_returnDepositOnDepositData() throws {
        
        let results = try XCTUnwrap(map(data: json(for: .deposit))).get()
        var expectedResults: [ProductsResponse] = [
            .init(
                serial: "111",
                products: .deposits)]

        assert([results], equals: &expectedResults)
    }
    
    func test_map_returnLoanOnLoanData() throws {
        
        let results = try XCTUnwrap(map(data: json(for: .loan))).get()
                
        var expectedResults: [ProductsResponse] = [
            .init(
                serial: "111",
                products: .loans)]

        assert([results], equals: &expectedResults)
    }
    
    func test_map_statusPC23_returnStatusPCBlockedUnlockNotAvailable() throws {
        
        let result = try XCTUnwrap(map(data: json(by: .createJson(with: "23")))).get()
                
        XCTAssertNoDiff(result, .createCard(with: .blockedUnlockNotAvailable))
    }
    
    func test_map_statusPC21_returnStatusPCBlockedByClient() throws {
        
        let result = try XCTUnwrap(map(data: json(by: .createJson(with: "21")))).get()
                
        XCTAssertNoDiff(result, .createCard(with: .blockedByClient))
    }

    // MARK: - Helpers
    
    private func map(
        statusCode: Int = 200,
        data: Data
    ) -> Result {
        
        ResponseMapper.mapGetProductListByTypeV6Response(
            data,
            anyHTTPURLResponse(statusCode: statusCode)
        )
    }
    
    private func json(for productType: ProductsResponse.ProductType) throws -> Data {
        
        switch productType {
        case .account:
            return try Data(contentsOf: XCTUnwrap(accountJson))

        case .card:
            return try Data(contentsOf: XCTUnwrap(cardJson))

        case .deposit:
            return try Data(contentsOf: XCTUnwrap(depositJson))

        case .loan:
            return try Data(contentsOf: XCTUnwrap(loanJson))

        }
    }
    
    private func json(by string: String) -> Data {
        
        return Data(string.utf8)
    }
    
    func getProductListByTypeV6InvalidError(dataString: String?) -> Result {
        
        guard let dataString else {
            
            return .failure(.invalid(statusCode: 200, data: Data()))
        }
        
        return .failure(.invalid(statusCode: 200, data: Data(dataString.utf8)))
    }
    
    func getProductListByTypeV6ServerError(
        statusCode: Int,
        errorMessage: String
    ) -> Result {
        
        return .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
    }
    
    private let accountJson = Bundle.module.url(forResource: "GetProductListByType_Account_Response", withExtension: "json")!
    private let cardJson = Bundle.module.url(forResource: "GetProductListByType_Card_Response", withExtension: "json")!
    private let depositJson = Bundle.module.url(forResource: "GetProductListByType_Deposit_Response", withExtension: "json")!
    private let loanJson = Bundle.module.url(forResource: "GetProductListByType_Loan_Response", withExtension: "json")!
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
            "productList":[]
        }
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

private extension ProductsResponse {
    
    static func createCard(with status: StatusPC) -> Self {
        
        .init(
            serial: "serial",
            products: [
                ProductsResponse.Product(
                    commonProperties: ProductsResponse.CommonProperties(
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
                        ProductsResponse.Card(
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

private extension Array where Element == ProductsResponse.Product {
    
    static let cards: Self = [
        .init(id: 10003827714, productType: .card, uniqueProperties: .card(cardId: 10000184510, cardType: .regular)),
        .init(id: 10003827715, productType: .card, uniqueProperties: .card(cardId: 10000184511, cardType: .individualBusinessman)),
        .init(id: 10003827716, productType: .card, uniqueProperties: .card(cardId: 10000184512, cardType: .individualBusinessmanMain)),
        .init(id: 10003827717, productType: .card, uniqueProperties: .card(cardId: 10000184513, cardType: .additionalCorporate)),
    ]
    
    static let accounts: Self = [ .init(id: 10003827714, productType: .account, uniqueProperties: .account())]
    
    static let deposits: Self = [ .init(id: 10003827714, productType: .deposit, uniqueProperties: .deposit(depositProductID: 1, depositID: 2))]
    
    static let loans: Self = [ .init(id: 10003827714, productType: .loan, uniqueProperties: .loan())]
}
