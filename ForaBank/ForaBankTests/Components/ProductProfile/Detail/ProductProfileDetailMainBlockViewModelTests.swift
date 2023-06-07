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
    
    func test_state_loanRepainAndOwnFundsConfig_balanceIsNil_ownFundsIsNill() {
        
        let sut = makeSut(configuration: .loanRepaidAndOwnFunds, balance: nil, ownFunds: nil)
        
        XCTAssertEqual(sut.ownFunds, "0.0")
        XCTAssertEqual(sut.loanLimitCurrent, "0.0")
        XCTAssertEqual(sut.loanLimitTotal, "0.0")
        XCTAssertEqual(sut.progress.progress, 1, accuracy: .ulpOfOne)
    }
    
    func test_state_loanRepainAndOwnFundsConfig_balanceZero_ownFundsIsNill() {
        
        let sut = makeSut(configuration: .loanRepaidAndOwnFunds, balance: 0, ownFunds: nil)
        
        XCTAssertEqual(sut.ownFunds, "0.0")
        XCTAssertEqual(sut.loanLimitCurrent, "0.0")
        XCTAssertEqual(sut.loanLimitTotal, "0.0")
        XCTAssertEqual(sut.progress.progress, 1, accuracy: .ulpOfOne)
    }
    
    func test_state_loanRepainAndOwnFundsConfig_balanceGreaterZero_ownFundsIsNill() {
        
        let sut = makeSut(configuration: .loanRepaidAndOwnFunds, balance: 100, ownFunds: nil)
        
        XCTAssertEqual(sut.ownFunds, "0.0")
        XCTAssertEqual(sut.loanLimitCurrent, "100.0")
        XCTAssertEqual(sut.loanLimitTotal, "100.0")
        XCTAssertEqual(sut.progress.progress, 0, accuracy: .ulpOfOne)
    }
    
    func test_state_loanRepainAndOwnFundsConfig_balanceZero_ownFundsIsZero() {
        
        let sut = makeSut(configuration: .loanRepaidAndOwnFunds, balance: 0, ownFunds: 0)
        
        XCTAssertEqual(sut.ownFunds, "0.0")
        XCTAssertEqual(sut.loanLimitCurrent, "0.0")
        XCTAssertEqual(sut.loanLimitTotal, "0.0")
        XCTAssertEqual(sut.progress.progress, 1, accuracy: .ulpOfOne)
    }
    
    func test_state_loanRepainAndOwnFundsConfig_balanceGreaterZero_ownFundsIsZero() {
        
        let sut = makeSut(configuration: .loanRepaidAndOwnFunds, balance: 100, ownFunds: nil)
        
        XCTAssertEqual(sut.ownFunds, "0.0")
        XCTAssertEqual(sut.loanLimitCurrent, "100.0")
        XCTAssertEqual(sut.loanLimitTotal, "100.0")
        XCTAssertEqual(sut.progress.progress, 0, accuracy: .ulpOfOne)
    }
    
    func test_state_loanRepainAndOwnFundsConfig_balanceGreaterZero_ownFundsGreaterZeroLessBalance() {
        
        let sut = makeSut(configuration: .loanRepaidAndOwnFunds, balance: 100, ownFunds: 50)
        
        XCTAssertEqual(sut.ownFunds, "50.0")
        XCTAssertEqual(sut.loanLimitCurrent, "100.0")
        XCTAssertEqual(sut.loanLimitTotal, "100.0")
        XCTAssertEqual(sut.progress.progress, 0.5, accuracy: .ulpOfOne)
    }
    
    func test_state_loanRepainAndOwnFundsConfig_balanceGreaterZero_ownFundsGreaterZeroGreaterBalance() {
        
        let sut = makeSut(configuration: .loanRepaidAndOwnFunds, balance: 50, ownFunds: 100)
        
        XCTAssertEqual(sut.ownFunds, "100.0")
        XCTAssertEqual(sut.loanLimitCurrent, "50.0")
        XCTAssertEqual(sut.loanLimitTotal, "50.0")
        XCTAssertEqual(sut.progress.progress, 2.0, accuracy: .ulpOfOne)
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
    
}

//MARK: - Helpers

private extension ProductProfileDetailMainBlockViewModelTests {
    
    func makeSut(
        configuration: ProductProfileDetailView.ViewModel.Configuration = .loanRepaidAndOwnFunds,
        balance: Double? = nil,
        ownFunds: Double? = nil,
        totalAvailableAmount: Double = 0,
        debtAmount: Double? = nil
    ) -> ProductProfileDetailView.ViewModel.MainBlockViewModel {
        
        let productCard = ProductCardData.make(balance: balance)
        let loanData = ProductCardData.LoanBaseParamInfoData.makeLoanBaseParamInfoData(availableExceedLimit: balance, ownFunds: ownFunds, debtAmount: debtAmount, totalAvailableAmount: totalAvailableAmount)
        
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
    
    static func make(balance: Double?) -> ProductCardData {
        
        .init(id: 0, productType: .card, number: nil, numberMasked: nil, accountNumber: nil, balance: balance, balanceRub: nil, currency: "", mainField: "", additionalField: nil, customName: nil, productName: "", openDate: nil, ownerId: 0, branchId: nil, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], accountId: nil, cardId: 0, name: "", validThru: Date(), status: .active, expireDate: nil, holderName: nil, product: nil, branch: "", miniStatement: nil, paymentSystemName: nil, paymentSystemImage: nil, loanBaseParam: nil, statusPc: nil, isMain: nil, externalId: nil, order: 0, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
    }
}

