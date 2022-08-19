//
//  ServerCommandsProductTests.swift
//  ForaBankTests
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
        let expected = ServerCommands.ProductController.GetProductDetails.Response(statusCode: .ok, errorMessage: "string", data: .init(accountNumber: "4081781000000000001", bic: "044525341", corrAccount: "30101810300000000341", inn: "7704113772", kpp: "770401001", payeeName: "Иванов Иван Иванович"))
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductDetails.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }

    //MARK: - GetProductList
    
    func testCreateGetProductList_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "GetProductListResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let date = Date(timeIntervalSince1970: TimeInterval(1630530000000 / 1000))
        let productData = ProductData(id: 10002585800, productType: .card, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: nil, currency: "RUB", mainField: "Gold", additionalField: "Зарплатная", customName: "Моя карта", productName: "VISA REWARDS R-5", openDate: date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: [.init(description: "FFBB36")])
        let expected =  ServerCommands.ProductController.GetProductList.Response(statusCode: .ok, errorMessage: "string", data: [productData])
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetProductList_Response_Decoding_Min() throws {

        // given
        let url = bundle.url(forResource: "GetProductListResponseMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let date = Date(timeIntervalSince1970: TimeInterval(1630530000000 / 1000))
        let productData = ProductData(id: 10002585800, productType: .card, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: nil, currency: "RUB", mainField: "Gold", additionalField: nil, customName: nil, productName: "VISA REWARDS R-5", openDate: date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: [.init(description: "FFBB36")])
        let expected =  ServerCommands.ProductController.GetProductList.Response(statusCode: .ok, errorMessage: "string", data: [productData])
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetProductListByFilter
    
    func testGetProductListByFilter_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "GetProductListByFilterResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let date = Date(timeIntervalSince1970: TimeInterval(1648512000000 / 1000))
        let background: [ColorData] = [.init(description: "FFBB36")]

        let productCard = ProductCardData(id: 10002585800, productType: ProductType.card, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: 1000123, currency: "RUB", mainField: "Gold", additionalField: "Зарплатная", customName: "Моя карта", productName: "VISA REWARDS R-5", openDate: date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: background, accountId: nil, cardId: 10001639855, name: "ВСФ", validThru: date, status: ProductData.Status.notBlocked, expireDate: nil, holderName: nil, product: nil, branch: "АКБ \"ФОРА-БАНК\" (АО)", miniStatement: [.init(account: "string", date: date, amount: 0, currency: "string", purpose: "string")], paymentSystemName: nil, paymentSystemImage: nil, loanBaseParam: nil, statusPc: nil, isMain: nil, externalId: 10000788533)

        let productDeposit = ProductDepositData(id: 10002585800, productType: .deposit, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: 1000123, currency: "RUB", mainField: "Gold", additionalField: "Зарплатная", customName: "Моя карта", productName: "VISA REWARDS R-5", openDate: date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: background, depositProductId: 10000003006, depositId: 10002585800, interestRate: 8.05, accountId: 10004281426, creditMinimumAmount: 2000, minimumBalance: 2000, endDate: date, endDateNf: true)

        let productLoan = ProductLoanData(id: 10002585800, productType: ProductType.loan, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: 1000123, currency: "RUB", mainField: "Gold", additionalField: "Зарплатная", customName: "Моя карта", productName: "VISA REWARDS R-5", openDate: date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: background, currencyNumber: 810, bankProductId: 10000000004, amount: 56305.61, currentInterestRate: 8.61, principalDebt: 2417866.13, defaultPrincipalDebt: 185991.68, totalAmountDebt: 2417866.13, principalDebtAccount: "45507810400001100039", settlementAccount: "40817810700002203359", settlementAccountId: 203359, dateLong: date, strDateLong: "12/27")

        let expected = ServerCommands.ProductController.GetProductListByFilter.Response(statusCode: .ok, errorMessage: "string", data: [productCard, productDeposit, productLoan])
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductListByFilter.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
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
        let date = Date(timeIntervalSince1970: TimeInterval(1630530000000 / 1000))
        
        let productCard = ProductCardData(id: 10002585800, productType: .card, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: nil, currency: "RUB", mainField: "Gold", additionalField: nil, customName: nil, productName: "VISA REWARDS R-5", openDate: date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: [.init(description: "FFBB36")], accountId: nil, cardId: 10001639855, name: "name", validThru: date, status: .active, expireDate: nil, holderName: nil, product: nil, branch: "branch", miniStatement: nil, paymentSystemName: nil, paymentSystemImage: nil, loanBaseParam: nil, statusPc: nil, isMain: nil, externalId: nil)
        
        let expected = ServerCommands.ProductController.GetProductListByFilter.Response(statusCode: .ok, errorMessage: "string", data: [productCard])
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductListByFilter.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetProductListByType

    func testGetProductListByType_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "GetProductListByTypeResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let date = Date(timeIntervalSince1970: TimeInterval(1648512000000 / 1000))
        let background: [ColorData] = [.init(description: "FFBB36")]

        let productCard = ProductCardData(id: 10002585800, productType: ProductType.card, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: 1000123, currency: "RUB", mainField: "Gold", additionalField: "Зарплатная", customName: "Моя карта", productName: "VISA REWARDS R-5", openDate: date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: background, accountId: nil, cardId: 10001639855, name: "ВСФ", validThru: date, status: ProductData.Status.notBlocked, expireDate: nil, holderName: nil, product: nil, branch: "АКБ \"ФОРА-БАНК\" (АО)", miniStatement: [.init(account: "string", date: date, amount: 0, currency: "string", purpose: "string")], paymentSystemName: nil, paymentSystemImage: nil, loanBaseParam: nil, statusPc: nil, isMain: nil, externalId: 10000788533)

        let productAccount = ProductAccountData(id: 10002585800, productType: .account, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: 1000123, currency: "RUB", mainField: "Gold", additionalField: "Зарплатная", customName: "Моя карта", productName: "VISA REWARDS R-5", openDate: date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: background, externalId: 10000788530, name: "ВСФ", dateOpen: date, status: .active, branchName: "АКБ \"ФОРА-БАНК\" (АО)", miniStatement: [.init(date: date, account: "string", currency: "string", amount: 0.0, purpose: "string")])

        let productDeposit = ProductDepositData(id: 10002585800, productType: .deposit, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: 1000123, currency: "RUB", mainField: "Gold", additionalField: "Зарплатная", customName: "Моя карта", productName: "VISA REWARDS R-5", openDate: date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: background, depositProductId: 10000003006, depositId: 10002585800, interestRate: 8.05, accountId: 10004281426, creditMinimumAmount: 2000, minimumBalance: 2000, endDate: date, endDateNf: true)

        let productLoan = ProductLoanData(id: 10002585800, productType: ProductType.loan, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: 1000123, currency: "RUB", mainField: "Gold", additionalField: "Зарплатная", customName: "Моя карта", productName: "VISA REWARDS R-5", openDate: date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: background, currencyNumber: 810, bankProductId: 10000000004, amount: 56305.61, currentInterestRate: 8.61, principalDebt: 2417866.13, defaultPrincipalDebt: 185991.68, totalAmountDebt: 2417866.13, principalDebtAccount: "45507810400001100039", settlementAccount: "40817810700002203359", settlementAccountId: 203359, dateLong: date, strDateLong: "12/27")

        let expected = ServerCommands.ProductController.GetProductListByType.Response(statusCode: .ok, errorMessage: "string", data: .init(serial: "bea36075a58954199a6b8980549f6b69", productList: [productCard, productAccount, productDeposit, productLoan]))
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductListByType.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
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
        let date = Date(timeIntervalSince1970: TimeInterval(1648512000000 / 1000))
        let background: [ColorData] = [.init(description: "FFBB36")]

        let productCard = ProductCardData(id: 10002585800, productType: ProductType.card, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: nil, currency: "RUB", mainField: "Gold", additionalField: nil, customName: nil, productName: "VISA REWARDS R-5", openDate: date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: background, accountId: nil, cardId: 10001639855, name: "ВСФ", validThru: date, status: ProductData.Status.notBlocked, expireDate: nil, holderName: nil, product: nil, branch: "АКБ \"ФОРА-БАНК\" (АО)", miniStatement: nil, paymentSystemName: nil, paymentSystemImage: nil, loanBaseParam: nil, statusPc: nil, isMain: nil, externalId: nil)

        let productAccount = ProductAccountData(id: 10002585800, productType: .account, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: nil, currency: "RUB", mainField: "Gold", additionalField: nil, customName: nil, productName: "VISA REWARDS R-5", openDate: date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: background, externalId: 10000788530, name: "ВСФ", dateOpen: date, status: .active, branchName: nil, miniStatement: [])

        let productDeposit = ProductDepositData(id: 10002585800, productType: .deposit, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: nil, currency: "RUB", mainField: "Gold", additionalField: nil, customName: nil, productName: "VISA REWARDS R-5", openDate: date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: background, depositProductId: 10000003006, depositId: 10002585800, interestRate: 8.05, accountId: 10004281426, creditMinimumAmount: 2000, minimumBalance: 2000, endDate: date, endDateNf: true)

        let productLoan = ProductLoanData(id: 10002585800, productType: ProductType.loan, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: "RUB", mainField: "Gold", additionalField: nil, customName: nil, productName: "VISA REWARDS R-5", openDate: nil, ownerId: 10001639855, branchId: nil, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: background, currencyNumber: nil, bankProductId: 10000000004, amount: 56305.61, currentInterestRate: 8.61, principalDebt: nil, defaultPrincipalDebt: nil, totalAmountDebt: nil, principalDebtAccount: "45507810400001100039", settlementAccount: "40817810700002203359", settlementAccountId: 203359, dateLong: date, strDateLong: "12/27")

        let expected = ServerCommands.ProductController.GetProductListByType.Response(statusCode: .ok, errorMessage: "string", data: .init(serial: "bea36075a58954199a6b8980549f6b69", productList: [productCard, productAccount, productDeposit, productLoan]))

        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductListByType.Response.self, from: json)

        // then
        XCTAssertEqual(result, expected)
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
        XCTAssertEqual(result, expected)
    }
    
    func testGetProductDynamicParamsList_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "GetProductDynamicParamsListGenericTest", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        let productCard = CardDynamicParams(balance: 1000123, balanceRub: 1000123, customName: "Моя карта", status: .active, debtAmount: 56305.61, totalDebtAmount: 56305.61, statusPc: .active)
        let productAccount = AccountDynamicParams(balance: 1000123, balanceRub: 1000123, customName: "Моя карта", status: .active)
        let productDeposit = ProductDynamicParamsData(balance: 1000123, balanceRub: 1000123, customName: "Моя карта")
        let product = ServerCommands.ProductController.GetProductDynamicParamsList.Response.List.DynamicListParams(id: 10000192282, type: .card, dynamicParams: productCard)
        let account = ServerCommands.ProductController.GetProductDynamicParamsList.Response.List.DynamicListParams(id: 10000192282, type: .account, dynamicParams: productAccount)
        let deposit = ServerCommands.ProductController.GetProductDynamicParamsList.Response.List.DynamicListParams(id: 10000192282, type: .deposit, dynamicParams: productDeposit)
        let dynamicProductParamsList = ServerCommands.ProductController.GetProductDynamicParamsList.Response.List(dynamicProductParamsList:  [product, account, deposit])
        
        let expected = ServerCommands.ProductController.GetProductDynamicParamsList.Response(statusCode: .ok, errorMessage: "string", data: dynamicProductParamsList)
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductDynamicParamsList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - Corrupted products data
    
    func testGetProductListByType_Response_Decoding_Corrupted() throws {

        // given
        let url = bundle.url(forResource: "GetProductListByTypeResponseCorrupted", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let date = Date(timeIntervalSince1970: TimeInterval(1648512000000 / 1000))
        let background: [ColorData] = [.init(description: "FFBB36")]

        let productCard = ProductCardData(id: 10002585800, productType: ProductType.card, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: 1000123, currency: "RUB", mainField: "Gold", additionalField: "Зарплатная", customName: "Моя карта", productName: "VISA REWARDS R-5", openDate: date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: background, accountId: nil, cardId: 10001639855, name: "ВСФ", validThru: date, status: ProductData.Status.notBlocked, expireDate: nil, holderName: nil, product: nil, branch: "АКБ \"ФОРА-БАНК\" (АО)", miniStatement: [.init(account: "string", date: date, amount: 0, currency: "string", purpose: "string")], paymentSystemName: nil, paymentSystemImage: nil, loanBaseParam: nil, statusPc: nil, isMain: nil, externalId: 10000788533)

        let productAccount = ProductAccountData(id: 10002585800, productType: .account, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: 1000123, currency: "RUB", mainField: "Gold", additionalField: "Зарплатная", customName: "Моя карта", productName: "VISA REWARDS R-5", openDate: date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: background, externalId: 10000788530, name: "ВСФ", dateOpen: date, status: .active, branchName: "АКБ \"ФОРА-БАНК\" (АО)", miniStatement: [.init(date: date, account: "string", currency: "string", amount: 0.0, purpose: "string")])

        let productDeposit = ProductDepositData(id: 10002585800, productType: .deposit, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: 1000123, currency: "RUB", mainField: "Gold", additionalField: "Зарплатная", customName: "Моя карта", productName: "VISA REWARDS R-5", openDate: date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: background, depositProductId: 10000003006, depositId: 10002585800, interestRate: 8.05, accountId: 10004281426, creditMinimumAmount: 2000, minimumBalance: 2000, endDate: date, endDateNf: true)

        let productLoan = ProductLoanData(id: 10002585800, productType: ProductType.loan, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: 1000123, currency: "RUB", mainField: "Gold", additionalField: "Зарплатная", customName: "Моя карта", productName: "VISA REWARDS R-5", openDate: date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: background, currencyNumber: 810, bankProductId: 10000000004, amount: 56305.61, currentInterestRate: 8.61, principalDebt: 2417866.13, defaultPrincipalDebt: 185991.68, totalAmountDebt: 2417866.13, principalDebtAccount: "45507810400001100039", settlementAccount: "40817810700002203359", settlementAccountId: 203359, dateLong: date, strDateLong: "12/27")

        let expected = ServerCommands.ProductController.GetProductListByType.Response(statusCode: .ok, errorMessage: "string", data: .init(serial: "bea36075a58954199a6b8980549f6b69", productList: [productCard, productAccount, productDeposit, productLoan]))
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductListByType.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}
