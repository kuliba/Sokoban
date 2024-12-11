//
//  ResponseMapper_mapGetProductListByTypeV7ResponseTests.swift
//
//
//  Created by Andryusina Nataly on 28.10.2024.
//

import XCTest
import GetProductListByTypeV7Service
import RemoteServices

final class ResponseMapper_mapGetProductListByTypeV7ResponseTests: XCTestCase {
    
    func test_map_returnInvalidErrorOnDataEmptyAndStatusCode200() {
        
        XCTAssertNoDiff(
            map(statusCode: 200, data: Data(String.emptyData.utf8)),
            .failure(.invalid(statusCode: 200, data: Data(String.emptyData.utf8)))
        )
    }
    
    func test_map_returnInvalidErrorOnErrorDataAndStatusCode200() {
        
        XCTAssertNoDiff(
            map(statusCode: 200, data: Data(String.errorData.utf8)),
            .failure(.invalid(statusCode: 200, data: Data(String.errorData.utf8))))
    }
    
    func test_map_returnServer404WithMessageOnDataWithError404() {
        
        XCTAssertNoDiff(
            map(statusCode: 200, data: Data(String.error404.utf8)),
            .failure(.server(statusCode: 404, errorMessage: "404: Не найден запрос к серверу"))
        )
    }
    
    func test_map_returnEmptyProductsOnEmptyList() throws {
        
        XCTAssertNoDiff(try mapResult(Data(String.emptyList.utf8)), .init(list: [], serial: "04ba222dd6021a0e41582c669cb8e9a4"))
    }
    
    func test_map_returnAccountOnAccountData() throws {
        
        XCTAssertNoDiff(try mapResult(json(for: .account)), .init(list: .accounts, serial: "111"))
    }
    
    func test_map_returnCardsOnCardsData() throws {
        
        XCTAssertNoDiff(try mapResult(json(for: .card)), .init(list: .cards, serial: "111"))
    }
    
    func test_map_returnDepositOnDepositData() throws {
        
        XCTAssertNoDiff(try mapResult(json(for: .deposit)), .init(list: .deposits, serial: "111"))
    }
    
    func test_map_returnLoanOnLoanData() throws {
        
        XCTAssertNoDiff(try mapResult(json(for: .loan)), .init(list: .loans, serial: "111"))
    }
    
    // MARK: - Helpers
    
    private typealias Response = ResponseMapper.GetProductListByTypeV7Response
    private typealias MappingResult = ResponseMapper.MappingResult<Response>
    private typealias ProductsResponse = ResponseMapper.GetProductListByTypeV7Data
    
    private func map(
        statusCode: Int = 200,
        data: Data
    ) -> MappingResult {
        
        ResponseMapper.mapGetProductListByTypeV7Response(
            data,
            anyHTTPURLResponse(statusCode: statusCode)
        )
    }
    
    private func mapResult(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) throws -> Response {
        
        try ResponseMapper.mapGetProductListByTypeV7Response(data, httpURLResponse).get()
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

private extension Array where Element == ResponseMapper.GetProductListByTypeV7Data {
    
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

private extension ResponseMapper.GetProductListByTypeV7Data {
    
    init(
        id: Int,
        productType: ProductType,
        uniqueProperties: UniqueProperties
    ) {
        self.init(
            commonProperties: .init(
                id: id,
                productType: productType,
                productState: [
                    .default,
                    .notVisible
                ],
                order: 0,
                visibility: true,
                number: "40817810623000001135",
                numberMasked: "40817-810-X-ХXXX-0001135",
                accountNumber: "40817810623000001135",
                currency: "RUB",
                mainField: "Текущий",
                additionalField: nil,
                customName: nil,
                productName: "Текущие счета физ.лиц",
                balance: 22601.59,
                balanceRUB: 22601.59,
                openDate: 1596402000000,
                ownerId: 10002053887,
                branchId: 2000,
                allowDebit: true,
                allowCredit: true,
                fontDesignColor: "FFFFFF",
                smallDesignMd5Hash: "9cd404ac011454ad95146de6560dd794",
                mediumDesignMd5Hash: "121b73bb50858e76e33b176686d8e940",
                largeDesignMd5Hash: "2a3bf21fe2b8e28f3944ab0968f6759d",
                xlDesignMd5Hash: "bf552f2c1d4d174decf46b7acd115068",
                smallBackgroundDesignHash: "714bbb74c410e835ce7f8e47dafe27a6",
                background: [
                    "FF3636"
                ]),
            uniqueProperties: uniqueProperties)
    }
}

extension ResponseMapper.GetProductListByTypeV7Data.UniqueProperties {
    
    static func account() -> Self {
        
        .account(
            .init(
                name: "ВСФ",
                externalID: 10002053887,
                dateOpen: 1596402000000,
                status: .notBlocked,
                branchName: #"АКБ "ИННОВАЦИИ-БИЗНЕСА" (АО)"#,
                detailedRatesUrl: "https://www.vortex.ru/user-upload/tarif-fl-ul/Moscow_Kotelniki_OrekhovoZuevo_Reutov_Tver_tarifi.pdf",
                detailedConditionUrl: "https://www.vortex.ru/dkbo/dkbo.pdf",
                isSavingAccount: true,
                interestRate: "interestRate"
            )
        )
    }
    
    static func deposit(
        depositProductID: Int,
        depositID: Int
    ) -> Self {
        
        .deposit(
            .init(
                depositProductID: depositProductID,
                depositID: depositID,
                interestRate: 7.1,
                accountID: 20000102037,
                creditMinimumAmount: 2000.0,
                minimumBalance: 5000.0,
                endDate: 1709154000000,
                endDateNF: false,
                demandDeposit: false,
                isDebitInterestAvailable: false
            )
        )
    }
    
    static func card(
        cardId: Int,
        cardType: ResponseMapper.GetProductListByTypeV7Data.CardType
    ) -> Self {
        
        .card(
            .init(
                cardID: cardId,
                idParent: nil,
                accountID: 10004177075,
                cardType: cardType,
                statusCard: .active,
                loanBaseParam: .init(
                    loanID: 20000059293,
                    clientID: 10002053887,
                    number: "БК-240305/5200/1",
                    currencyID: 2,
                    currencyNumber: 810,
                    currencyCode: "RUB",
                    minimumPayment: 0.0,
                    gracePeriodPayment: 0.0,
                    overduePayment: 0.0,
                    availableExceedLimit: 0.0,
                    ownFunds: 280027.57,
                    debtAmount: -280027.57,
                    totalAvailableAmount: 100000.0,
                    totalDebtAmount: -280027.57
                ),
                statusPC: .active,
                name: "ВСФ",
                validThru: 1790715600000,
                status: .active,
                expireDate: "09/26",
                holderName: "CHALIKYAN GEVORG",
                product: "VISA REWARDS R-5",
                branch: #"АКБ "ИННОВАЦИИ-БИЗНЕСА" (АО)"#,
                paymentSystemName: "VISA",
                paymentSystemImageMd5Hash: "d7516b59941d5acd06df25a64ea32660"
            )
        )
    }
    
    static func loan() -> Self {
        
        .loan(
            .init(
                currencyNumber: 2,
                bankProductID: 10000000194,
                amount: 500000.0,
                currentInterestRate: 17.5,
                principalDebt: 488423.84,
                defaultPrincipalDebt: nil,
                totalAmountDebt: 488423.84,
                principalDebtAccount: "45507810700001300403",
                settlementAccount: "40817810110010000262",
                settlementAccountId: 20000004912,
                dateLong: 1853182800000,
                strDateLong: "09/28"
            )
        )
    }
}
