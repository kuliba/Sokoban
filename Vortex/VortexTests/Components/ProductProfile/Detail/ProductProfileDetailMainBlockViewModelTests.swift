//
//  ProductProfileDetailMainBlockViewModelTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 01.06.2023.
//

import XCTest
@testable import ForaBank

final class ProductProfileDetailMainBlockViewModelTests: XCTestCase {

    func test_init_loanRepaidAndOwnFundsCorrect() {
        
        let sut = makeSut(configuration: .loanRepaidAndOwnFunds)

        XCTAssertEqual(sut.ownFunds, "0.0")
        XCTAssertEqual(sut.loanLimitCurrent, "0.0")
        XCTAssertEqual(sut.loanLimitTotal, "0.0")
        XCTAssertEqual(sut.progress.progress, 1, accuracy: .ulpOfOne)
    }
    
    // in current implementation init has switch between case .loanRepaidAndOwnFunds and default
    // technically, init with .overdue option covers all other cases
    //TODO: add more init tests in future if current implemtntation changes
    func test_init_overdueAndOwnFundsCorrect() {
        
        let sut = makeSut(configuration: .overdue)

        XCTAssertEqual(sut.debt, "0.0")
        XCTAssertEqual(sut.availableCurrent, "0.0")
        XCTAssertEqual(sut.availableTotal, "0.0")
        XCTAssertEqual(sut.progress.progress, 1, accuracy: .ulpOfOne)
    }
    
    //TODO: init(productLoan: ProductLoanData, loanData: PersonsCreditData, model: Model, action: @escaping () -> Void) tests required
}

//MARK: - loanRepaidAndOwnFunds config

extension ProductProfileDetailMainBlockViewModelTests {
    
    func test_state_loanRepaidAndOwnFundsConfig_balanceIsNil_ownFundsIsNil() {
        
        let sut = makeSut(configuration: .loanRepaidAndOwnFunds, balance: nil, ownFunds: nil)
        
        XCTAssertEqual(sut.ownFunds, "0.0")
        XCTAssertEqual(sut.loanLimitCurrent, "0.0")
        XCTAssertEqual(sut.loanLimitTotal, "0.0")
        XCTAssertEqual(sut.progress.progress, 1, accuracy: .ulpOfOne)
    }
    
    func test_state_loanRepaidAndOwnFundsConfig_balanceZero_ownFundsIsNil() {
        
        let sut = makeSut(configuration: .loanRepaidAndOwnFunds, balance: 0, ownFunds: nil)
        
        XCTAssertEqual(sut.ownFunds, "0.0")
        XCTAssertEqual(sut.loanLimitCurrent, "0.0")
        XCTAssertEqual(sut.loanLimitTotal, "0.0")
        XCTAssertEqual(sut.progress.progress, 1, accuracy: .ulpOfOne)
    }
    
    func test_state_loanRepaidAndOwnFundsConfig_balanceGreaterZero_ownFundsIsNil() {
        
        let sut = makeSut(configuration: .loanRepaidAndOwnFunds, balance: 100, ownFunds: nil)
        
        XCTAssertEqual(sut.ownFunds, "0.0")
        XCTAssertEqual(sut.loanLimitCurrent, "100.0")
        XCTAssertEqual(sut.loanLimitTotal, "100.0")
        XCTAssertEqual(sut.progress.progress, 0, accuracy: .ulpOfOne)
    }
    
    func test_state_loanRepaidAndOwnFundsConfig_balanceZero_ownFundsIsZero() {
        
        let sut = makeSut(configuration: .loanRepaidAndOwnFunds, balance: 0, ownFunds: 0)
        
        XCTAssertEqual(sut.ownFunds, "0.0")
        XCTAssertEqual(sut.loanLimitCurrent, "0.0")
        XCTAssertEqual(sut.loanLimitTotal, "0.0")
        XCTAssertEqual(sut.progress.progress, 1, accuracy: .ulpOfOne)
    }
    
    func test_state_loanRepaidAndOwnFundsConfig_balanceGreaterZero_ownFundsIsZero() {
        
        let sut = makeSut(configuration: .loanRepaidAndOwnFunds, balance: 100, ownFunds: nil)
        
        XCTAssertEqual(sut.ownFunds, "0.0")
        XCTAssertEqual(sut.loanLimitCurrent, "100.0")
        XCTAssertEqual(sut.loanLimitTotal, "100.0")
        XCTAssertEqual(sut.progress.progress, 0, accuracy: .ulpOfOne)
    }
    
    func test_state_loanRepaidAndOwnFundsConfig_balanceGreaterZero_ownFundsGreaterZeroLessBalance() {
        
        let sut = makeSut(configuration: .loanRepaidAndOwnFunds, balance: 100, ownFunds: 50)
        
        XCTAssertEqual(sut.ownFunds, "50.0")
        XCTAssertEqual(sut.loanLimitCurrent, "50.0")
        XCTAssertEqual(sut.loanLimitTotal, "100.0")
        XCTAssertEqual(sut.progress.progress, 0.5, accuracy: .ulpOfOne)
    }
    
    func test_state_loanRepaidAndOwnFundsConfig_balanceGreaterZero_ownFundsGreaterZeroGreaterBalance() {
        
        let sut = makeSut(configuration: .loanRepaidAndOwnFunds, balance: 50, ownFunds: 100)
        
        XCTAssertEqual(sut.ownFunds, "100.0")
        XCTAssertEqual(sut.loanLimitCurrent, "-50.0")
        XCTAssertEqual(sut.loanLimitTotal, "50.0")
        XCTAssertEqual(sut.progress.progress, 2.0, accuracy: .ulpOfOne)
    }
    
    func test_loanRepaidAndOwnFunds_shouldSetBalanceAndAvailableItems() {
        
        let sut = makeSut(
            balance: 100,
            ownFunds: 99,
            totalAvailableAmount: 15,
            currencyCode: "RUB"
        )
        
        XCTAssertNoDiff(sut.items.map(\.type), [
            .ownFunds,
            .loanLimit
        ])
        XCTAssertNoDiff(sut.items.map(\.testPrefix), [
            .legend,
            .legend
        ])
        XCTAssertNoDiff(sut.items.map(\.value), [
            "99,00 ₽",
            "1,00 ₽"
        ])
        XCTAssertNoDiff(sut.items.map(\.testPostfix), [
            .none,
            .value("15,00 ₽")
        ])
    }
}

//MARK: - overdue config, and technically now all other configs

extension ProductProfileDetailMainBlockViewModelTests {
    
    func test_state_overdueConfig_balanceIsNil_totalAvailableAmountZero_debtAmountNil() {
        
        let sut = makeSut(configuration: .overdue, balance: nil, totalAvailableAmount: 0, debtAmount: nil)
        
        XCTAssertEqual(sut.debt, "0.0")
        XCTAssertEqual(sut.availableCurrent, "0.0")
        XCTAssertEqual(sut.availableTotal, "0.0")
        XCTAssertEqual(sut.progress.progress, 1, accuracy: .ulpOfOne)
    }
    
    func test_state_overdueConfig_balanceZero_totalAvailableAmountZero_debtAmountNil() {
        
        let sut = makeSut(configuration: .overdue, balance: 0, totalAvailableAmount: 0, debtAmount: nil)
        
        XCTAssertEqual(sut.debt, "0.0")
        XCTAssertEqual(sut.availableCurrent, "0.0")
        XCTAssertEqual(sut.availableTotal, "0.0")
        XCTAssertEqual(sut.progress.progress, 1, accuracy: .ulpOfOne)
    }
    
    func test_state_overdueConfig_balanceGreaterZero_totalAvailableAmountZero_debtAmountNil() {
        
        let sut = makeSut(configuration: .overdue, balance: 100, totalAvailableAmount: 0, debtAmount: nil)
        
        XCTAssertEqual(sut.debt, "0.0")
        XCTAssertEqual(sut.availableCurrent, "100.0")
        XCTAssertEqual(sut.availableTotal, "0.0")
        XCTAssertEqual(sut.progress.progress, 1, accuracy: .ulpOfOne)
    }
    
    func test_state_overdueConfig_balanceGreaterZero_totalAvailableAmountGreaterZeroLessBalance_debtAmountNil() {
        
        let sut = makeSut(configuration: .overdue, balance: 100, totalAvailableAmount: 50, debtAmount: nil)
        
        XCTAssertEqual(sut.debt, "0.0")
        XCTAssertEqual(sut.availableCurrent, "100.0")
        XCTAssertEqual(sut.availableTotal, "50.0")
        XCTAssertEqual(sut.progress.progress, 0, accuracy: .ulpOfOne)
    }
    
    func test_state_overdueConfig_balanceGreaterZero_totalAvailableAmountGreaterZeroGreaterBalance_debtAmountNil() {
        
        let sut = makeSut(configuration: .overdue, balance: 50, totalAvailableAmount: 100, debtAmount: nil)
        
        XCTAssertEqual(sut.debt, "0.0")
        XCTAssertEqual(sut.availableCurrent, "50.0")
        XCTAssertEqual(sut.availableTotal, "100.0")
        XCTAssertEqual(sut.progress.progress, 0, accuracy: .ulpOfOne)
    }
    
    func test_state_overdueConfig_balanceGreaterZero_totalAvailableAmountZero_debtAmountZero() {
        
        let sut = makeSut(configuration: .overdue, balance: 100, totalAvailableAmount: 0, debtAmount: 0)
        
        XCTAssertEqual(sut.debt, "0.0")
        XCTAssertEqual(sut.availableCurrent, "100.0")
        XCTAssertEqual(sut.availableTotal, "0.0")
        XCTAssertEqual(sut.progress.progress, 1, accuracy: .ulpOfOne)
    }
    
    func test_state_overdueConfig_balanceGreaterZero_totalAvailableAmountZero_debtAmountGreaterZeroLessBalance() {
        
        let sut = makeSut(configuration: .overdue, balance: 100, totalAvailableAmount: 0, debtAmount: 50)
        
        XCTAssertEqual(sut.debt, "50.0")
        XCTAssertEqual(sut.availableCurrent, "100.0")
        XCTAssertEqual(sut.availableTotal, "0.0")
        XCTAssertEqual(sut.progress.progress, 1, accuracy: .ulpOfOne)
    }
    
    func test_state_overdueConfig_balanceGreaterZero_totalAvailableAmountZero_debtAmountGreaterZeroGreaterBalance() {
        
        let sut = makeSut(configuration: .overdue, balance: 50, totalAvailableAmount: 0, debtAmount: 100)
        
        XCTAssertEqual(sut.debt, "100.0")
        XCTAssertEqual(sut.availableCurrent, "50.0")
        XCTAssertEqual(sut.availableTotal, "0.0")
        XCTAssertEqual(sut.progress.progress, 1, accuracy: .ulpOfOne)
    }
    
    func test_state_overdueConfig_balanceGreaterZero_totalAvailableAmountGreaterZeroLessBalance_debtAmountGreaterZeroLessBalance() {
        
        let sut = makeSut(configuration: .overdue, balance: 100, totalAvailableAmount: 50, debtAmount: 50)
        
        XCTAssertEqual(sut.debt, "50.0")
        XCTAssertEqual(sut.availableCurrent, "100.0")
        XCTAssertEqual(sut.availableTotal, "50.0")
        XCTAssertEqual(sut.progress.progress, 1, accuracy: .ulpOfOne)
    }
    
    func test_state_overdueConfig_balanceGreaterZero_totalAvailableAmountGreaterZeroGreaterBalance_debtAmountGreaterZeroGreaterBalance() {
        
        let sut = makeSut(configuration: .overdue, balance: 50, totalAvailableAmount: 100, debtAmount: 100)
        
        XCTAssertEqual(sut.debt, "100.0")
        XCTAssertEqual(sut.availableCurrent, "50.0")
        XCTAssertEqual(sut.availableTotal, "100.0")
        XCTAssertEqual(sut.progress.progress, 1, accuracy: .ulpOfOne)
    }
    
    // MARK: - TEST Balance/CreditLimit/ownFunds
    
    func test_init_loanRepaidAndOwnFunds_creditLimitCalculation() {
        
        let (balance, ownFunds) = (1000.0, 300.0)
        
        let sut = makeSut(configuration: .loanRepaidAndOwnFunds, balance: balance, ownFunds: ownFunds, totalAvailableAmount: balance)
        
        XCTAssertEqual(sut.items[0].type, .ownFunds)
        XCTAssertEqual(sut.items[0].value, "300.0")
        XCTAssertEqual(sut.items[1].type, .loanLimit)
        XCTAssertEqual(sut.items[1].value, "700.0")
        XCTAssertEqual(sut.items[1].testPostfix, .value("1000.0"))
    }
    
    func test_init_loanRepaidAndOwnFunds_zeroBalance() {
        let sut = makeSut(configuration: .loanRepaidAndOwnFunds, balance: 0, ownFunds: 0, totalAvailableAmount: 0)
        
        XCTAssertEqual(sut.items[0].type, .ownFunds)
        XCTAssertEqual(sut.items[0].value, "0.0")
        XCTAssertEqual(sut.items[1].type, .loanLimit)
        XCTAssertEqual(sut.items[1].value, "0.0")
        XCTAssertEqual(sut.items[1].testPostfix, .value("0.0"))
        XCTAssertEqual(sut.progress.progress, 1, accuracy: .ulpOfOne)
    }
    
    func test_init_loanRepaidAndOwnFunds_ownFundsGreaterThanBalance() {
        
        let (balance, ownFunds) = (1000.0, 1500.0)
        let sut = makeSut(configuration: .loanRepaidAndOwnFunds, balance: balance, ownFunds: ownFunds, totalAvailableAmount: balance)
        
        XCTAssertEqual(sut.items[0].type, .ownFunds)
        XCTAssertEqual(sut.items[0].value, "1500.0")
        XCTAssertEqual(sut.items[1].type, .loanLimit)
        XCTAssertEqual(sut.items[1].value, "-500.0")
        XCTAssertEqual(sut.items[1].testPostfix, .value("1000.0"))
    }
    
    func test_init_loanRepaidAndOwnFunds_progressCalculation() {
        let balance = 1000.0
        let ownFunds = 250.0
        
        let sut = makeSut(configuration: .loanRepaidAndOwnFunds, balance: balance, ownFunds: ownFunds, totalAvailableAmount: balance)
        
        XCTAssertEqual(sut.progress.progress, 0.25, accuracy: .ulpOfOne)
        XCTAssertEqual(sut.progress.primaryColor, .mainColorsRed)
        XCTAssertEqual(sut.progress.secondaryColor, .mainColorsWhite)
    }
}

//MARK: - Helpers

private extension ProductProfileDetailMainBlockViewModelTests {
    
    // TODO: fix to use currency
    func makeSut(
        configuration: ProductProfileDetailView.ViewModel.Configuration = .loanRepaidAndOwnFunds,
        balance: Double? = nil,
        ownFunds: Double? = nil,
        totalAvailableAmount: Double = 0,
        currencyCode: String? = nil,
        debtAmount: Double? = nil
    ) -> ProductProfileDetailView.ViewModel.MainBlockViewModel {
        
        let loanData: ProductCardData.LoanBaseParamInfoData = .makeLoanBaseParamInfoData(
            currencyCode: currencyCode,
            availableExceedLimit: balance,
            ownFunds: ownFunds,
            debtAmount: debtAmount,
            totalAvailableAmount: totalAvailableAmount
        )
        let productCard = ProductCardData.make(balance: balance, loanBaseParam: loanData)
        
        return .init(configuration: configuration, productCard: productCard, loanData: loanData, amountFormatted: Self.amountFormattedStub(amount:currency:style:), action: {})
    }
    
    static func amountFormattedStub(amount: Double, currency: String?, style: Model.AmountFormatStyle) -> String? {
        
        guard let currency else {
            return nil
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.locale = .init(identifier: "ru_RU")
        
        return formatter.string(from: NSNumber(value: amount))
    }
}

private extension ProductProfileDetailView.ViewModel.MainBlockViewModel {
    
    var ownFunds: String? {
        
        guard let ownFundsItem = items.first(where: { $0.type == .ownFunds }) else {
            return nil
        }
        
        return ownFundsItem.value
    }
    
    var loanLimitCurrent: String? {
        
        guard let loanLimitItem = items.first(where: { $0.type == .loanLimit }) else {
            return nil
        }
        
        return loanLimitItem.value
    }
    
    var loanLimitTotal: String? {
        
        guard let loanLimitItem = items.first(where: { $0.type == .loanLimit }),
              case let .value(value) = loanLimitItem.postfix else {
            return nil
        }
        
        return value
    }
    
    var debt: String? {
        
        guard let debtItem = items.first(where: { $0.type == .debt }) else {
            return nil
        }
        
        return debtItem.value
    }
    
    var availableCurrent: String? {
        
        guard let availableItem = items.first(where: { $0.type == .available }) else {
            return nil
        }
        
        return availableItem.value
    }
    
    var availableTotal: String? {
        
        guard let availableItem = items.first(where: { $0.type == .available }),
              case let .value(value) = availableItem.postfix else {
            return nil
        }
        
        return value
    }
}

private extension ProductCardData.LoanBaseParamInfoData {
    
    static func makeLoanBaseParamInfoData(
        loanId: Int = 0,
        clientId: Int = 0,
        number: String = "",
        currencyId: Int? = nil,
        currencyNumber: Int? = nil,
        currencyCode: String? = nil,
        minimumPayment: Double? = nil,
        gracePeriodPayment: Double? = nil,
        overduePayment: Double? = nil,
        availableExceedLimit: Double? = nil,
        ownFunds: Double? = nil,
        debtAmount: Double? = nil,
        totalAvailableAmount: Double = 0,
        totalDebtAmount: Double? = nil) -> ProductCardData.LoanBaseParamInfoData {
        
        .init(loanId: loanId,
              clientId: clientId,
              number: number,
              currencyId: currencyId,
              currencyNumber: currencyNumber,
              currencyCode: currencyCode,
              minimumPayment: minimumPayment,
              gracePeriodPayment: gracePeriodPayment,
              overduePayment: overduePayment,
              availableExceedLimit: availableExceedLimit,
              ownFunds: ownFunds,
              debtAmount: debtAmount,
              totalAvailableAmount: totalAvailableAmount,
              totalDebtAmount: totalDebtAmount)
    }
}

private extension ProductCardData {
    
    static func make(
        balance: Double?,
        loanBaseParam: LoanBaseParamInfoData? = nil
    ) -> ProductCardData {
        
        .init(id: 0, productType: .card, number: nil, numberMasked: nil, accountNumber: nil, balance: balance, balanceRub: nil, currency: "", mainField: "", additionalField: nil, customName: nil, productName: "", openDate: nil, ownerId: 0, branchId: nil, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], accountId: nil, cardId: 0, name: "", validThru: Date(), status: .active, expireDate: nil, holderName: nil, product: nil, branch: "", miniStatement: nil, paymentSystemName: nil, paymentSystemImage: nil, loanBaseParam: loanBaseParam, statusPc: nil, isMain: nil, externalId: nil, order: 0, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
    }
}

private extension ProductProfileDetailView.ViewModel.AmountViewModel {
    
    var testPrefix: TestPrefix? {
        
        switch prefix {
        case .legend: return .legend
        case .none:   return .none
        }
    }
    
    var testPostfix: TestPostfix? {
        
        switch postfix {
        
        case .none:
            return .none

        case .checkmark:
            return .checkmark
        
        case .info:
            return .info
        
        case let .value(value):
            return .value(value)
        }
    }
    
    enum TestPrefix {
        
        case legend
    }
    enum TestPostfix: Equatable {
        
        case checkmark
        case info
        case value(String)
    }
}

private extension ProductCardData {
    
    private static func makeProductCardData(
        id: Int = 10000184510,
        productType: ProductType = .card,
        number: String = "4656260144018016",
        numberMasked: String = "4656-XXXX-XXXX-8016",
        accountNumber: String = "40817810952005000640",
        balance: Double? = 50011,
        balanceRub: Double? = 50011,
        currency: String = "RUB",
        mainField: String = "Gold",
        additionalField: String = "Миг",
        customName: String? = "reg0тесттесттесттестте",
        productName: String = "VISA REWARDS R-5",
        openDate: Date = Date.dateUTC(with: 1631048400000),
        ownerId: Int = 10002053887,
        branchId: Int = 2000,
        allowCredit: Bool = true,
        allowDebit: Bool = true,
        extraLargeDesign: SVGImageData = SVGImageData(description: "e383a49e15aeec6d9c51ee6f4897ad16"),
        largeDesign: SVGImageData = SVGImageData(description: "b7fd0a13ae9bb8b70b0dd92082ce91f6"),
        mediumDesign: SVGImageData = SVGImageData(description: "98cbe7f6396bed6004dd01e2f7c37db2"),
        smallDesign: SVGImageData = SVGImageData(description: "7e7beff3d0827be85b8259135643bf62"),
        fontDesignColor: ColorData = ColorData(description: "FFFFFF"),
        background: [ColorData] = [ColorData(description: "FFBB36")],
        accountId: Int = 10004177075,
        cardId: Int = 10000184510,
        name: String = "ТП МИГ Visa Gold_",
        validThru: Date = Date.dateUTC(with: 1790715600000),
        status: Status = .active,
        expireDate: String = "09/26",
        holderName: String = "CHALIKYAN GEVORG",
        product: String = "VISA REWARDS R-5",
        branch: String = #"АКБ "ФОРА-БАНК" (АО)"#,
        miniStatement: [PaymentDataItem]? = nil,
        paymentSystemName: String = "VISA",
        paymentSystemImage: SVGImageData = SVGImageData(description: "d7516b59941d5acd06df25a64ea32660"),
        loanBaseParam: LoanBaseParamInfoData? = nil,
        statusPc: StatusPC = .active,
        isMain: Bool = false,
        externalId: Int? = nil,
        order: Int = 0,
        visibility: Bool = true,
        smallDesignMd5hash: String = "7e7beff3d0827be85b8259135643bf62",
        smallBackgroundDesignHash: String = "b0c85ac844ee9758af64ad2c066d5191",
        statusCard: StatusCard? = .active,
        cardType: CardType? = .regular,
        idParent: Int? = nil
    ) -> ProductCardData {
        
        return ProductCardData(
            id: id,
            productType: productType,
            number: number,
            numberMasked: numberMasked,
            accountNumber: accountNumber,
            balance: balance,
            balanceRub: balanceRub,
            currency: currency,
            mainField: mainField,
            additionalField: additionalField,
            customName: customName,
            productName: productName,
            openDate: openDate,
            ownerId: ownerId,
            branchId: branchId,
            allowCredit: allowCredit,
            allowDebit: allowDebit,
            extraLargeDesign: extraLargeDesign,
            largeDesign: largeDesign,
            mediumDesign: mediumDesign,
            smallDesign: smallDesign,
            fontDesignColor: fontDesignColor,
            background: background,
            accountId: accountId,
            cardId: cardId,
            name: name,
            validThru: validThru,
            status: status,
            expireDate: expireDate,
            holderName: holderName,
            product: product,
            branch: branch,
            miniStatement: miniStatement,
            paymentSystemName: paymentSystemName,
            paymentSystemImage: paymentSystemImage,
            loanBaseParam: loanBaseParam,
            statusPc: statusPc,
            isMain: isMain,
            externalId: externalId,
            order: order,
            visibility: visibility,
            smallDesignMd5hash: smallDesignMd5hash,
            smallBackgroundDesignHash: smallBackgroundDesignHash,
            statusCard: statusCard,
            cardType: cardType,
            idParent: idParent
        )
    }
    
    static let cardStub1_default = makeProductCardData(productType: .loan)
    
    static let cardStub2_balance0 = makeProductCardData(
        id: 10000184511,
        number: "4656260144018008",
        numberMasked: "4656-XXXX-XXXX-8008",
        accountNumber: "40817810552005000639",
        balance: 0,
        balanceRub: 0,
        customName: "reg1",
        accountId: 10004176990,
        cardId: 10000184511,
        order: 1
    )
    
    static let cardStub3_BalanceIsNegative = makeProductCardData(
        id: 10000184511,
        number: "4656260144018008",
        numberMasked: "4656-XXXX-XXXX-8008",
        accountNumber: "40817810552005000639",
        balance: 160000,
        balanceRub: 160000,
        customName: "reg1",
        accountId: 10004176990,
        cardId: 10000184511,
        order: 1
    )
    
    static let cardStub4_balanceIsNil = makeProductCardData(
        balance: nil,
        balanceRub: nil
    )
}

private extension ProductCardData.LoanBaseParamInfoData {
    
    static func makeLoanBaseParamInfoData(
        loanId: Int = 20000058545,
        clientId: Int = 10002266732,
        number: String = "БК-231129/3500/2",
        currencyId: Int = 2,
        currencyNumber: Int = 810,
        currencyCode: String = "RUB",
        minimumPayment: Double = 0,
        gracePeriodPayment: Double = 0,
        overduePayment: Double = 0,
        availableExceedLimit: Double = 50000.0,
        ownFunds: Double = 0,
        debtAmount: Double = 0,
        totalAvailableAmount: Double = 50000.0,
        totalDebtAmount: Double = 0
    ) -> ProductCardData.LoanBaseParamInfoData {
        
        return .init(
            loanId: loanId,
            clientId: clientId,
            number: number,
            currencyId: currencyId,
            currencyNumber: currencyNumber,
            currencyCode: currencyCode,
            minimumPayment: minimumPayment,
            gracePeriodPayment: gracePeriodPayment,
            overduePayment: overduePayment,
            availableExceedLimit: availableExceedLimit,
            ownFunds: ownFunds,
            debtAmount: debtAmount,
            totalAvailableAmount: totalAvailableAmount,
            totalDebtAmount: totalDebtAmount
        )
    }
    
    static func makeLoanBaseParamInfoDataWithZeroBalanceAndDebt() -> ProductCardData.LoanBaseParamInfoData {
        
        return makeLoanBaseParamInfoData(
            availableExceedLimit: 330000.0,
            debtAmount: -50000,
            totalAvailableAmount: 250000.0,
            totalDebtAmount: -150000
        )
    }
    
    static func makeLoanBaseParamInfoData_MinPaymentMade_WithDebt() -> ProductCardData.LoanBaseParamInfoData {
        
        return makeLoanBaseParamInfoData(
            minimumPayment: 4444,
            gracePeriodPayment: 5555,
            overduePayment: 6666,
            availableExceedLimit: 330000.0,
            debtAmount: 57000,
            totalAvailableAmount: 250000.0,
            totalDebtAmount: 65000
        )
    }
}
