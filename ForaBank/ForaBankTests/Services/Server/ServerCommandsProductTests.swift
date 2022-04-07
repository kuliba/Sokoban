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

        let productCard = ProductCardData(id: 10002585800, productType: ProductType.card, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: 1000123, currency: "RUB", mainField: "Gold", additionalField: "Зарплатная", customName: "Моя карта", productName: "VISA REWARDS R-5", openDate: date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: background, cardId: nil, accountId: nil, name: "ВСФ", validThru: date, status: ProductData.Status.notBlocked, expireDate: nil, holderName: nil, product: nil, branch: "АКБ \"ФОРА-БАНК\" (АО)", miniStatement: [.init(account: "string", date: date, amount: 0, currency: "string", purpose: "string")], paymentSystemName: nil, paymentSystemImage: nil, loanBaseParam: nil, statusPc: nil, isMain: nil, externalId: 10000788533)

        let productDeposit = ProductDepositData(id: 10002585800, productType: .deposit, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: 1000123, currency: "RUB", mainField: "Gold", additionalField: "Зарплатная", customName: "Моя карта", productName: "VISA REWARDS R-5", openDate: date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: background, depositProductId: 10000003006, depositId: 10002585800, interestRate: 8.05, accountId: 10004281426, creditMinimumAmount: 2000, minimumBalance: 2000)

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
        
        let number = "1111111111111111"
        let branchId = 2000
        let accountNumber = "40844444444444444444"
        let image = "image"
        let ownerId = 10002053887
        let holderName = "CHALIKYAN GEVORG"
        
        let card = ProductCardData(id: 10000211974, productType: .card, number: number, numberMasked: "4578-XXXX-XXXX-2761", accountNumber: accountNumber, balance: 45460.97, balanceRub: -9566.1800, currency: "USD", mainField: "Platinum", additionalField: "Зарплатная", customName: nil, productName: "VISA PLATINUM R-5", openDate: Date(timeIntervalSince1970: TimeInterval(1648512000000 / 1000)), ownerId: ownerId, branchId: branchId, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: image), largeDesign: .init(description: image), mediumDesign: .init(description: image), smallDesign: .init(description: image), fontDesignColor: .init(description: "FFFFFF"), background: [.init(description: "AAAAAA")], cardId: 10000211974, accountId: 10004467113, name: "ТП Премиал Аккредит Visa Platinum USD", validThru: Date(timeIntervalSince1970: TimeInterval(1806451200000 / 1000)), status: .active, expireDate: "03/27", holderName: "GEVORG CHALIKYAN", product: "VISA PLATINUM R-5", branch: "АКБ \"ФОРА-БАНК\" (АО)", miniStatement: [], paymentSystemName: "VISA", paymentSystemImage: .init(description: image), loanBaseParam: nil, statusPc: .active, isMain: true, externalId: nil)

        let secondCard = ProductCardData(id: 10000211975, productType: .card, number: number, numberMasked: "4578-XXXX-XXXX-0443", accountNumber: accountNumber, balance: 45460.97, balanceRub: 0.0000, currency: "EUR", mainField: "Platinum", additionalField: "Премиальный", customName: nil, productName: "VISA PLATINUM R-5", openDate: Date(timeIntervalSince1970: TimeInterval(1648512000000 / 1000)), ownerId: ownerId, branchId: branchId, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: image), largeDesign: .init(description: image), mediumDesign: .init(description: image), smallDesign: .init(description: image), fontDesignColor: .init(description: "FFFFFF"), background: [.init(description: "AAAAAA")], cardId: 10000211975, accountId: 10004467114, name: "ТП ПРЕМИАЛЬНЫЙ Cred Visa Plat EUR ГОД", validThru: Date(timeIntervalSince1970: TimeInterval(1806451200000 / 1000)), status: .active, expireDate: "03/27", holderName: "GEVORG CHALIKYAN", product: "VISA PLATINUM R-5", branch: "АКБ \"ФОРА-БАНК\" (АО)", miniStatement: [], paymentSystemName: "VISA", paymentSystemImage: .init(description: image), loanBaseParam: nil, statusPc: .active, isMain: true, externalId: nil)
        
        let thirdCard = ProductCardData(id: 10000184511, productType: .card, number: number, numberMasked: "4656-XXXX-XXXX-8008", accountNumber: accountNumber, balance: 45460.97, balanceRub: -200772.3200, currency: "RUB", mainField: "Gold", additionalField: "Миг", customName: "/*/*/*/", productName: "VISA REWARDS R-5", openDate: Date(timeIntervalSince1970: TimeInterval(1631059200000 / 1000)), ownerId: ownerId, branchId: branchId, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: image), largeDesign: .init(description: image), mediumDesign: .init(description: image), smallDesign: .init(description: image), fontDesignColor: .init(description: "FFFFFF"), background: [.init(description: "FFBB36")], cardId: 10000184511, accountId: 10004176990, name: "ТП МИГ Visa Gold", validThru: Date(timeIntervalSince1970: TimeInterval(1790726400000 / 1000)), status: .active, expireDate: "09/26", holderName: holderName, product: "VISA REWARDS R-5", branch: "АКБ \"ФОРА-БАНК\" (АО)", miniStatement: [], paymentSystemName: "VISA", paymentSystemImage: .init(description: image), loanBaseParam: nil, statusPc: .active, isMain: true, externalId: nil)
        
        let fourthCard = ProductCardData(id: 10000184510, productType: .card, number: number, numberMasked: "4656-XXXX-XXXX-8016", accountNumber: accountNumber, balance: 45460.97, balanceRub: 1004.0300, currency: "RUB", mainField: "Gold", additionalField: "Миг", customName: nil, productName: "VISA REWARDS R-5", openDate: Date(timeIntervalSince1970: TimeInterval(1631059200000 / 1000)), ownerId: ownerId, branchId: branchId, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: image), largeDesign: .init(description: image), mediumDesign: .init(description: image), smallDesign: .init(description: image), fontDesignColor: .init(description: "FFFFFF"), background: [.init(description: "FFBB36")], cardId: 10000184510, accountId: 10004177075, name: "ТП МИГ Visa Gold", validThru: Date(timeIntervalSince1970: TimeInterval(1790726400000 / 1000)), status: .active, expireDate: "09/26", holderName: holderName, product: "VISA REWARDS R-5", branch: "АКБ \"ФОРА-БАНК\" (АО)", miniStatement: [], paymentSystemName: "VISA", paymentSystemImage: .init(description: image), loanBaseParam: nil, statusPc: .active, isMain: true, externalId: nil)
        
        let account = ProductAccountData(id: 10004467103, productType: .account, number: number, numberMasked: "40817-810-X-ХXXX-0500046", accountNumber: accountNumber, balance: 1000000000.0000, balanceRub: 1000000000.0000, currency: "RUB", mainField: "Текущий счет", additionalField: nil, customName: nil, productName: "Текущие счета физ.лиц", openDate: Date(timeIntervalSince1970: TimeInterval(1648512000000 / 1000)), ownerId: ownerId, branchId: branchId, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: image), largeDesign: .init(description: image), mediumDesign: .init(description: image), smallDesign: .init(description: image), fontDesignColor: .init(description: "FFFFFF"), background: [.init(description: "6D6D6D")], externalId: 10002053887, name: "ВСФ", dateOpen: Date(timeIntervalSince1970: TimeInterval(1648512000000 / 1000)), status: .notBlocked, branchName: "АКБ \"ФОРА-БАНК\" (АО)", miniStatement: [])
        
        let secondAccount = ProductAccountData(id: 10004467104, productType: .account, number: number, numberMasked: "40817-978-X-ХXXX-0305001", accountNumber: accountNumber, balance: 11111111111.1100, balanceRub: 1169624444444.3300, currency: "EUR", mainField: "Текущий счет", additionalField: nil, customName: nil, productName: "Текущие счета физ.лиц", openDate: Date(timeIntervalSince1970: TimeInterval(1648512000000 / 1000)), ownerId: ownerId, branchId: branchId, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: image), largeDesign: .init(description: image), mediumDesign: .init(description: image), smallDesign: .init(description: image), fontDesignColor: .init(description: "FFFFFF"), background: [.init(description: "6D6D6D")], externalId: 10002053887, name: "ВСФ", dateOpen: Date(timeIntervalSince1970: TimeInterval(1648512000000 / 1000)), status: .notBlocked, branchName: "АКБ \"ФОРА-БАНК\" (АО)", miniStatement: [])
        
        let thirdAccount = ProductAccountData(id: 10004467106, productType: .account, number: number, numberMasked: "40817-840-X-ХXXX-0500016", accountNumber: accountNumber, balance: 58074963627.6500, balanceRub: 5555555555555.5500, currency: "USD", mainField: "Текущий счет", additionalField: nil, customName: nil, productName: "Текущие счета физ.лиц", openDate: Date(timeIntervalSince1970: TimeInterval(1648512000000 / 1000)), ownerId: ownerId, branchId: branchId, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: image), largeDesign: .init(description: image), mediumDesign: .init(description: image), smallDesign: .init(description: image), fontDesignColor: .init(description: "FFFFFF"), background: [.init(description: "6D6D6D")], externalId: 10002053887, name: "ВСФ", dateOpen: Date(timeIntervalSince1970: TimeInterval(1648512000000 / 1000)), status: .notBlocked, branchName: "АКБ \"ФОРА-БАНК\" (АО)", miniStatement: [])
        
        let deposit = ProductDepositData(id: 10002650833, productType: .deposit, number: number, numberMasked:  "04847_224RUB5200/22", accountNumber: accountNumber, balance: 5000.2200, balanceRub: 5000.2200, currency: "RUB", mainField: "СБЕРЕГАТЕЛЬНЫЙ ОН-ЛАЙН", additionalField: nil, customName: nil, productName: "СБЕРЕГАТЕЛЬНЫЙ ОН-ЛАЙН", openDate: Date(timeIntervalSince1970: TimeInterval(1649116800000 / 1000)), ownerId: ownerId, branchId: 10000260261, allowCredit: true, allowDebit: false, extraLargeDesign: .init(description: image), largeDesign: .init(description: image), mediumDesign: .init(description: image), smallDesign: .init(description: image), fontDesignColor: .init(description: "3D3D45"), background: [.init(description: "FF3636")], depositProductId: 10000003006, depositId: 10002650833, interestRate: 0.9500, accountId: 10004467181, creditMinimumAmount: 2000.0000, minimumBalance: 5000.0000)
        
        let mortgage = ProductLoanData(id: 10002455395, productType: .loan, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: "RUB", mainField: "Ипотечный", additionalField: "Ипотечный кредит", customName: nil, productName: "Ф_ИпКред", openDate: nil, ownerId: 10001952730, branchId: nil, allowCredit: false, allowDebit: false, extraLargeDesign: .init(description: image), largeDesign: .init(description: image), mediumDesign: .init(description: image), smallDesign: .init(description: image), fontDesignColor: .init(description: "FFFFFF"), background: [.init(description: "FF9636")], currencyNumber: 2, bankProductId: 10000000268, amount: 2677500.0000, currentInterestRate: 10.0900, principalDebt: 2659410.4200, defaultPrincipalDebt: nil, totalAmountDebt: 2659410.4200, principalDebtAccount: "45507810300001300599", settlementAccount: "40817810400040400264", settlementAccountId: 10004095838, dateLong: Date(timeIntervalSince1970: TimeInterval(2290118400000 / 1000)), strDateLong: "07/42")
        
        let consumerCredit = ProductLoanData(id: 10002513930, productType: .loan, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: "RUB", mainField: "Сотрудник", additionalField: nil, customName: nil, productName: "Ф_ПотКред", openDate: nil, ownerId: 10000606330, branchId: nil, allowCredit: false, allowDebit: false, extraLargeDesign: .init(description: "image"), largeDesign: .init(description: "image"), mediumDesign: .init(description: "image"), smallDesign: .init(description: "image"), fontDesignColor: .init(description: "FFFFFF"), background: [.init(description: "80CBC3")], currencyNumber: 2, bankProductId: 10000000194, amount: 270000.0000, currentInterestRate: 12.8000, principalDebt: 214254.2700, defaultPrincipalDebt: nil, totalAmountDebt: 214254.2700, principalDebtAccount: "45506810600005500708", settlementAccount: "40817810288000001198", settlementAccountId: 10004201268, dateLong: Date(timeIntervalSince1970: TimeInterval(1684368000000 / 1000)), strDateLong: "05/23")
        
        let expected = ServerCommands.ProductController.GetProductListByFilter.Response(statusCode: .ok, errorMessage: "string", data: [card, secondCard, thirdCard, fourthCard, account, secondAccount, thirdAccount, deposit, mortgage, consumerCredit])
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductListByFilter.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetProductListByFilter_Response_Decoding_Min() throws {

        // given
        let url = bundle.url(forResource: "GetProductListByFilterResponseMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let date = Date(timeIntervalSince1970: TimeInterval(1630530000000 / 1000))
        
        let productCard = ProductCardData(id: 10002585800, productType: .card, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: nil, currency: "RUB", mainField: "Gold", additionalField: nil, customName: nil, productName: "VISA REWARDS R-5", openDate: date, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: [.init(description: "FFBB36")], cardId: nil, accountId: nil, name: "name", validThru: date, status: .active, expireDate: nil, holderName: nil, product: nil, branch: "branch", miniStatement: nil, paymentSystemName: nil, paymentSystemImage: nil, loanBaseParam: nil, statusPc: nil, isMain: nil, externalId: nil)
        
        let expected = ServerCommands.ProductController.GetProductListByFilter.Response(statusCode: .ok, errorMessage: "string", data: [productCard])
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductListByFilter.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}
