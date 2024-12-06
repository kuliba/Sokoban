//
//  ServerCommandsProductTests.swift
//  VortexTests
//
//  Created by Max Gribov on 01.02.2022.
//

import XCTest
@testable import ForaBank

class ServerCommandsProductTests: XCTestCase {
    
    let bundle = Bundle(for: ServerCommandsTransferTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate
    let formatter = DateFormatter.iso8601
    
    //MARK: - GetProductDetails
    
    func testGetProductDetails_Response_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "GetProductDetailsResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.ProductController.GetProductDetails.Response(
            statusCode: .ok,
            errorMessage: "string",
            data: .init(
                accountNumber: "4081781000000000001",
                bic: "044525341",
                corrAccount: "30101810300000000341",
                inn: "7704113772",
                kpp: "770401001",
                payeeName: "Иванов Иван Иванович",
                maskCardNumber: nil,
                cardNumber: nil
            )
        )
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductDetails.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetProductDetailsFull_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "GetProductDetailsResponseGenericFull", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.ProductController.GetProductDetails.Response(
            statusCode: .ok,
            errorMessage: "string",
            data: .init(
                accountNumber: "4081781000000000001",
                bic: "044525341",
                corrAccount: "30101810300000000341",
                inn: "7704113772",
                kpp: "770401001",
                payeeName: "Иванов Иван Иванович",
                maskCardNumber: "4444 55** **** 1122",
                cardNumber: "4444 5555 6666 1122"
            )
        )
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductDetails.Response.self, from: json)
        
        // then
        XCTAssertNoDiff(result, expected)
    }
    
    //MARK: - GetProductList
    
    func testCreateGetProductList_Response_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "GetProductListResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
                
        let expected =  ServerCommands.ProductController.GetProductList.Response(statusCode: .ok, errorMessage: "string", data: [.productData])
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductList.Response.self, from: json)
        
        // then
        XCTAssertNoDiff(result, expected)
    }
    
    func testGetProductList_Response_Decoding_Min() throws {
        
        // given
        let url = bundle.url(forResource: "GetProductListResponseMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        let expected =  ServerCommands.ProductController.GetProductList.Response(statusCode: .ok, errorMessage: "string", data: [.productDataMin])
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductList.Response.self, from: json)
        
        // then
        XCTAssertNoDiff(result, expected)
    }
    
    //MARK: - GetProductListByFilter
    
    func testGetProductListByFilter_Response_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "GetProductListByFilterResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
                        
        let expected = ServerCommands.ProductController.GetProductListByFilter.Response(statusCode: .ok, errorMessage: "string", data: [productCard, productDeposit, ProductLoanData.productLoan])
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductListByFilter.Response.self, from: json)
        
        // then
        XCTAssertNoDiff(result, expected)
    }
    
    func testGetProductListByFilter_Response_From_Server_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "GetProductListByFilterResponseGeneticTestServer", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        XCTAssertNoThrow(try decoder.decode(ServerCommands.ProductController.GetProductListByFilter.Response.self, from: json))
    }
    
    func testGetProductListByFilter_Response_Decoding_Min() throws {
        
        // given
        let url = bundle.url(forResource: "GetProductListByFilterResponseMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        let expected = ServerCommands.ProductController.GetProductListByFilter.Response(statusCode: .ok, errorMessage: "string", data: [productCardMin])
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductListByFilter.Response.self, from: json)
        
        // then
        XCTAssertNoDiff(result, expected)
    }
    
    //MARK: - GetProductListByType
    
    func testGetProductListByType_Response_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "GetProductListByTypeResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
                        
        let expected = ServerCommands.ProductController.GetProductListByType.Response(statusCode: .ok, errorMessage: "string", data: .init(serial: .serial, productList: [productCard, productAccount, productDeposit, ProductLoanData.productLoan]))
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductListByType.Response.self, from: json)
        
        // then
        XCTAssertNoDiff(result, expected)
    }
    
    func testGetProductListByType_Response_From_Server_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "GetProductListByTypeResponseServer", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        XCTAssertNoThrow(try decoder.decode(ServerCommands.ProductController.GetProductListByType.Response.self, from: json))
    }
    
    func testGetProductListByType_Response_Decoding_Min() throws {
        
        // given
        let url = bundle.url(forResource: "GetProductListByTypeResponseMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
                        
        let expected = ServerCommands.ProductController.GetProductListByType.Response(statusCode: .ok, errorMessage: "string", data: .init(serial: .serial, productList: [productCardMinOther, productAccountMin, productDepositMin, ProductLoanData.productLoanMin]))
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductListByType.Response.self, from: json)
        
        // then
        XCTAssertNoDiff(result, expected)
    }
    
    func testGetProductListByType_Response_Decoding_OnlyDeposits() throws {
        
        // given
        let url = bundle.url(forResource: "GetProductListByTypeResponseOnlyDeposits", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        let expected: [ProductDepositData] = ServerCommands.ProductController.GetProductListByType.Response(statusCode: .ok, errorMessage: "string", data: .init(serial: .serial, productList: [productDeposit1, productDeposit2, productDeposit3])).data?.productList as! [ProductDepositData]
        
        // when
        let result: [ProductDepositData]  = try decoder.decode(ServerCommands.ProductController.GetProductListByType.Response.self, from: json).data?.productList as! [ProductDepositData]
        
        // then
        XCTAssertNoDiff(result, expected)
    }
    
    //MARK: - GetProductDynamicParams
    
    func testGetProductDynamicParams_Response_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "GetProductDynamicParamsGenericTest", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        let productCard = CardDynamicParams(balance: 1000123, balanceRub: 1000123, customName: "Моя карта", status: .active, debtAmount: 56305.61, totalDebtAmount: 56305.61, statusPc: .active)

        let expected = ServerCommands.ProductController.GetProductDynamicParams.Response(statusCode: .ok, errorMessage: "string", data: productCard)
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductDynamicParams.Response.self, from: json)
        
        // then
        XCTAssertNoDiff(result, expected)
    }
        
    //MARK: - Corrupted products data
    
    func testGetProductListByType_Response_Decoding_Corrupted() throws {
        
        // given
        let url = bundle.url(forResource: "GetProductListByTypeResponseCorrupted", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        let productDeposit = ProductDepositData(id: 10002585800, productType: .deposit, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: 1000123, currency: "RUB", mainField: "Gold", additionalField: "Зарплатная", customName: "Моя карта", productName: "VISA REWARDS R-5", openDate: .date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: .background, depositProductId: 10000003006, depositId: 10002585800, interestRate: 8.05, accountId: 10004281426, creditMinimumAmount: 2000, minimumBalance: 2000, endDate: .date, endDateNf: true, isDemandDeposit: true, isDebitInterestAvailable: false, order: 0, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
                
        let expected = ServerCommands.ProductController.GetProductListByType.Response(statusCode: .ok, errorMessage: "string", data: .init(serial: .serial, productList: [productCard, productAccount, productDeposit, ProductLoanData.productLoan]))
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductListByType.Response.self, from: json)
        
        // then
        XCTAssertNoDiff(result, expected)
    }
    
    // MARK: - Helpers
    
    static func makeProductCardData(
        balanceRub: Double? = 1000123,
        additionalField: String? = "Зарплатная",
        customName: String? = "Моя карта",
        date: Date = .date,
        name: String = "ВСФ",
        status: ProductData.Status = .notBlocked,
        branch: String = "АКБ \"ФОРА-БАНК\" (АО)",
        miniStatement: [ProductCardData.PaymentDataItem]? = [.dataItem],
        externalId: Int? = 10000788533
    ) -> ProductCardData {
        
        return .init(id: 10002585800, productType: .card, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: balanceRub, currency: "RUB", mainField: "Gold", additionalField: additionalField, customName: customName, productName: "VISA REWARDS R-5", openDate: date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: .background, accountId: nil, cardId: 10001639855, name: name, validThru: date, status: status, expireDate: nil, holderName: nil, product: nil, branch: branch, miniStatement: miniStatement, paymentSystemName: nil, paymentSystemImage: nil, loanBaseParam: nil, statusPc: nil, isMain: nil, externalId: externalId, order: 0, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
    }
    
    let productCard: ProductCardData = ServerCommandsProductTests.makeProductCardData()

    let productCardMin: ProductCardData = ServerCommandsProductTests.makeProductCardData(
        balanceRub: nil,
        additionalField: nil,
        customName: nil,
        date: .dateMin,
        name: "name",
        status: .active,
        branch: "branch",
        miniStatement: nil,
        externalId: nil
    )
    
    let productCardMinOther: ProductCardData = ServerCommandsProductTests.makeProductCardData(
        balanceRub: nil,
        additionalField: nil,
        customName: nil,
        miniStatement: nil,
        externalId: nil
    )

    static func makeProductAccountData(
        balanceRub: Double? = 1000123,
        additionalField: String? = "Зарплатная",
        customName: String? = "Моя карта",
        branch: String? = "АКБ \"ФОРА-БАНК\" (АО)",
        miniStatement: [ProductCardData.PaymentDataItem]? = [.dataItem]
    ) -> ProductAccountData {
        
        return .init(id: 10002585800, productType: .account, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: balanceRub, currency: "RUB", mainField: "Gold", additionalField: additionalField, customName: customName, productName: "VISA REWARDS R-5", openDate: .date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: .background, externalId: 10000788530, name: "ВСФ", dateOpen: .date, status: .active, branchName: branch, miniStatement: [.init(date: .date, account: "string", currency: "string", amount: 0.0, purpose: "string")], order: 0, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "", detailedRatesUrl: "", detailedConditionUrl: "")
    }

    let productAccount: ProductAccountData = ServerCommandsProductTests.makeProductAccountData()

    let productAccountMin: ProductAccountData = ServerCommandsProductTests.makeProductAccountData(
        balanceRub: nil,
        additionalField: nil,
        customName: nil,
        branch: nil,
        miniStatement: []
    )
    
    static func makeProductDepositData(
        id: Int,
        additionalField: String? = nil,
        customName: String? = nil,
        balance: Double = 1000121,
        balanceRub: Double? = nil,
        isDebitInterestAvailable: Bool? = false
    ) -> ProductDepositData {
        
        return .init(id: id, productType: .deposit, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: balance, balanceRub: balanceRub, currency: "RUB", mainField: "Gold", additionalField: additionalField, customName: customName, productName: "VISA REWARDS R-5", openDate: .date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: .background, depositProductId: 10000003006, depositId: id, interestRate: 8.05, accountId: 10004281426, creditMinimumAmount: 2000, minimumBalance: 2000, endDate: .date, endDateNf: true, isDemandDeposit: true, isDebitInterestAvailable: isDebitInterestAvailable, order: 0, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
    }

    let productDeposit = ServerCommandsProductTests.makeProductDepositData(
        id: 10002585800,
        additionalField: "Зарплатная",
        customName: "Моя карта",
        balance: 1000123,
        balanceRub: 1000123
    )

    let productDepositMin = ServerCommandsProductTests.makeProductDepositData(
        id: 10002585800,
        additionalField: nil,
        customName: nil,
        balance: 1000123,
        balanceRub: nil
    )

    let productDeposit1 = ServerCommandsProductTests.makeProductDepositData(
        id: 10002585801
    )

    let productDeposit2 = ServerCommandsProductTests.makeProductDepositData(
        id: 10002585802,
        balance: 1000122,
        isDebitInterestAvailable: true
    )

    let productDeposit3 = ServerCommandsProductTests.makeProductDepositData(
        id: 10002585803,
        balance: 1000123
    )
}

private extension Date {
    
    static let date: Self = .dateUTC(with: 1648512000000)
    static let dateMin: Self = .dateUTC(with: 1630530000000)
}

private extension Array where Element == ColorData {
    
    static let background: Self = [.init(description: "FFBB36")]
}

private extension ProductCardData.PaymentDataItem {
    
    static let dataItem: Self = .init(
        account: "string",
        date: .date,
        amount: 0,
        currency: "string",
        purpose: "string")
}

private extension ProductData {
    
    static let productData = ProductData(id: 10002585800, productType: .card, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: nil, currency: "RUB", mainField: "Gold", additionalField: "Зарплатная", customName: "Моя карта", productName: "VISA REWARDS R-5", openDate: .dateMin, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: .background, order: 0, isVisible: true, smallDesignMd5hash: "75f3ee3b2d44e5808f41777c613f23c9", smallBackgroundDesignHash: "f8513ccd6cf65bbc9d91a233eeac0e06")
    
    static let productDataMin = ProductData(id: 10002585800, productType: .card, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: nil, currency: "RUB", mainField: "Gold", additionalField: nil, customName: nil, productName: "VISA REWARDS R-5", openDate: .dateMin, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: .background, order: 0, isVisible: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
}

private extension ProductLoanData {
    
    static let productLoan = ProductLoanData(id: 10002585800, productType: ProductType.loan, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: 1000123, currency: "RUB", mainField: "Gold", additionalField: "Зарплатная", customName: "Моя карта", productName: "VISA REWARDS R-5", openDate: .date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: .background, currencyNumber: 810, bankProductId: 10000000004, amount: 56305.61, currentInterestRate: 8.61, principalDebt: 2417866.13, defaultPrincipalDebt: 185991.68, totalAmountDebt: 2417866.13, principalDebtAccount: "45507810400001100039", settlementAccount: "40817810700002203359", settlementAccountId: 203359, dateLong: .date, strDateLong: "12/27", order: 0, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
    
    static let productLoanMin = ProductLoanData(id: 10002585800, productType: ProductType.loan, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: "RUB", mainField: "Gold", additionalField: nil, customName: nil, productName: "VISA REWARDS R-5", openDate: nil, ownerId: 10001639855, branchId: nil, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: .background, currencyNumber: nil, bankProductId: 10000000004, amount: 56305.61, currentInterestRate: 8.61, principalDebt: nil, defaultPrincipalDebt: nil, totalAmountDebt: nil, principalDebtAccount: "45507810400001100039", settlementAccount: "40817810700002203359", settlementAccountId: 203359, dateLong: .date, strDateLong: "12/27", order: 0, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
}

private extension String {
    
    static let serial = "bea36075a58954199a6b8980549f6b69"
}
