//
//  ProductDepositDataTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 17.05.2023.
//

import XCTest
@testable import ForaBank

class ProductDepositDataTests: XCTestCase {
    
    let balance   = 100.00
    let sumPayPrc = 100.00
    
    var pastDate = Date(timeIntervalSince1970: 0)
    var expirationDate: Date? {
        
        let date = Date()
        var components = DateComponents()
        components.setValue(1, for: .month)
        guard let expirationDate = Calendar.current.date(byAdding: components, to: date) else {
            return nil
        }
        return expirationDate
    }
}

extension ProductDepositDataTests {
    
    func test_demandDeposit_shouldSetup_valueAllowCredit() {
        
        // given
        let endDate: Date? = nil
        let demandDeposit = true
        
        // when
        let deposit = Self.mutableDeposit(endDate: endDate,
                                          demandDeposit: demandDeposit)
        
        // then
        XCTAssertEqual(deposit.isCanReplenish, true)
    }
    
    func test_deposits_shouldSetupReplanish_onEndDateUp() {
        
        // given
        let endDate = Date()
        let demandDeposit = false
        
        // when
        let deposit = Self.mutableDeposit(endDate: endDate,
                                          demandDeposit: demandDeposit)
        
        // then
        XCTAssertEqual(deposit.isCanReplenish, false)
    }
    
    func test_deposits_shouldSetupReplanish_onPastEndDate() {
        
        // given
        let endDate = pastDate
        let demandDeposit = false
    
        // when
        let deposit = Self.mutableDeposit(endDate: endDate,
                                          demandDeposit: demandDeposit)
        
        // then
        XCTAssertEqual(deposit.isCanReplenish, false)
    }
    
    func test_deposits_shouldSetupReplanish_onFutureEndDate() {
        
        // given
        let expirationDate = expirationDate
        let demandDeposit: Bool = false
        
        // when
        let deposit = Self.mutableDeposit(endDate: expirationDate,
                                          demandDeposit: demandDeposit)
        
        // then
        XCTAssertEqual(deposit.isCanReplenish, true)
    }
    
    func test_deposits_shouldCloseDeposit_onEndDateNf() {
        
        // given
        let endDateNf = false
        let endDate: Date? = nil
        let demandDeposit = false
        
        // when
        let deposit = Self.mutableDeposit(endDateNf: endDateNf,
                                          endDate: endDate,
                                          demandDeposit: demandDeposit)
        
        // then
        XCTAssertEqual(deposit.isCanClosedDeposit, true)
    }
    
    func test_deposits_shouldDepositType_onForahit() {
        
        // given
        let endDateNf = false
        let endDate: Date? = nil
        let demandDeposit = false
        
        // when
        let deposit = Self.mutableDeposit(endDateNf: endDateNf,
                                          endDate: endDate,
                                          demandDeposit: demandDeposit)
        
        // then
        XCTAssertEqual(deposit.depositType, .forahit)
    }
    
}

//MARK: test availableTransferType

extension ProductDepositDataTests {
    
    //MARK: tests DemanDeposit
    func test_demandDeposits_shouldAvailableTransferType_onRemains() {
        
        // given
        let endDateNf = false
        let endDate: Date? = nil
        let demandDeposit = true
        let depositInfo = Self.mutableDepositInfo(sumPayPrc: sumPayPrc)
        
        // when
        let deposit = Self.mutableDeposit(endDateNf: endDateNf,
                                          endDate: endDate,
                                          demandDeposit: demandDeposit)
        let transferType = deposit.availableTransferType(with: depositInfo)
        
        //then
        XCTAssertEqual(transferType, .remains)
    }
  
    //MARK: tests ForaHit
    func test_forahitDeposits_shouldAvailableTransferType_onClose() {
        
        // given
        let endDateNf = true
        let endDate: Date? = nil
        let demandDeposit = false
        let depositInfo = Self.mutableDepositInfo(sumPayPrc: sumPayPrc)
        
        // when
        let deposit = Self.mutableDeposit(endDateNf: endDateNf,
                                          endDate: endDate,
                                          demandDeposit: demandDeposit)
        
        let transferType = deposit.availableTransferType(with: depositInfo)
        
        //then
        XCTAssertEqual(transferType, .close(balance))
    }
    
    func test_forahitDeposits_shouldAvailableTransferType_onInterest() {
        
        // given
        let endDateNf = true
        let endDate: Date? = nil
        let demandDeposit = false
        let depositInfo: DepositInfoDataItem? = nil
        
        let deposit = Self.mutableDeposit(endDateNf: endDateNf,
                                          endDate: endDate,
                                          demandDeposit: demandDeposit)
        
        // when
        let transferType = deposit.availableTransferType(with: depositInfo)
        
        //then
        XCTAssertEqual(transferType, .interest(0))
    }
    
    func test_forahitDeposits_shouldAvailableTransferType_ForaHit_onEndDate_ValueNil() {
        
        // given
        let endDateNf = false
        let endDate: Date? = nil
        let demandDeposit = false
        let depositInfo = Self.mutableDepositInfo(sumPayPrc: sumPayPrc)
        
        // when
        let deposit = Self.mutableDeposit(endDateNf: endDateNf,
                                          endDate: endDate,
                                          demandDeposit: demandDeposit)
        
        let transferType = deposit.availableTransferType(with: depositInfo)
        
        //then
        XCTAssertEqual(transferType, .remains)
    }
    
    func test_forahitDeposits_shouldAvailableTransferType_ForaHit_onEndDateExpired_withPercents() {
        
        // given
        let endDateNf = false
        let endDate = expirationDate
        let demandDeposit = false
        let depositInfo = Self.mutableDepositInfo(sumPayPrc: sumPayPrc)
        
        let deposit = Self.mutableDeposit(endDateNf: endDateNf,
                                          endDate: endDate,
                                          demandDeposit: demandDeposit)
        
        // when
        let transferType = deposit.availableTransferType(with: depositInfo)
        
        //then
        XCTAssertEqual(transferType, .interest(sumPayPrc))
    }
    
    func test_forahitDeposits_shouldAvailableTransferType_ForaHit_onEndDateNorExpired_withPercents() {
        
        // given
        let endDateNf = false
        let endDate = expirationDate
        let demandDeposit = false
        let depositInfo: DepositInfoDataItem? = nil

        let deposit = Self.mutableDeposit(endDateNf: endDateNf,
                                          endDate: endDate,
                                          demandDeposit: demandDeposit)
        
        // when
        let transferType = deposit.availableTransferType(with: depositInfo)
        
        //then
        XCTAssertEqual(transferType, .interest(0))
    }
    
    func test_forahitDeposits_shouldAvailableTransferType_ForaHit_onEndDateNotExpired_withPercents() {
        
        // given
        let endDateNf = false
        let endDate = pastDate
        let demandDeposit = false
        let depositInfo = Self.mutableDepositInfo(sumPayPrc: sumPayPrc)

        let deposit = Self.mutableDeposit(endDateNf: endDateNf,
                                          endDate: endDate,
                                          demandDeposit: demandDeposit)
        
        // when
        let transferType = deposit.availableTransferType(with: depositInfo)
        
        //then
        XCTAssertEqual(transferType, .remains)
    }
    
    //MARK: tests otherDeposits
    
    func test_otherDeposits_shouldAvailableTransferType_onEndDateNf() {
        
        // given
        let endDateNf = true
        let endDate = pastDate
        let demandDeposit = false
        let depositId = 10000001870
        let depositInfo = Self.mutableDepositInfo(sumPayPrc: sumPayPrc)
        
        let deposit = Self.mutableDeposit(depositId: depositId,
                                          endDateNf: endDateNf,
                                          endDate: endDate,
                                          demandDeposit: demandDeposit)
        
        // when
        let transferType = deposit.availableTransferType(with: depositInfo)
        
        //then
        XCTAssertEqual(transferType, .close(depositInfo.balance))
    }
    
    func test_otherDeposits_shouldAvailableTransferType_onEndDate_WithOuthBalance() {
        
        // given
        let endDateNf = true
        let endDate = pastDate
        let demandDeposit = false
        let depositId = 10000001870
        let depositInfo: DepositInfoDataItem? = nil
        
        let deposit = Self.mutableDeposit(depositId: depositId,
                                          endDateNf: endDateNf,
                                          endDate: endDate,
                                          demandDeposit: demandDeposit)
        
        // when
        let transferType = deposit.availableTransferType(with: depositInfo)
        
        //then
        XCTAssertEqual(transferType, nil)
    }
}

extension ProductDepositDataTests {
    
    static func mutableDepositInfo(sumPayPrc: Double) -> DepositInfoDataItem {
        
        return DepositInfoDataItem(id: 0,
                                   initialAmount: 100,
                                   termDay: nil,
                                   interestRate: 100,
                                   sumPayInt: 100,
                                   sumCredit: 100,
                                   sumDebit: 100,
                                   sumAccInt: 100,
                                   balance: 100,
                                   sumPayPrc: sumPayPrc,
                                   dateOpen: Date(),
                                   dateEnd: nil,
                                   dateNext: nil)
    }
    
    static func mutableDeposit(depositId: Int = 10000003792, endDateNf: Bool = false, endDate: Date?, demandDeposit: Bool) -> ProductDepositData {
        
        return ProductDepositData(id: 30,
                                  productType: .loan,
                                  number: nil,
                                  numberMasked: nil,
                                  accountNumber: nil,
                                  balance: nil,
                                  balanceRub: nil,
                                  currency: "RUB",
                                  mainField: "Dep",
                                  additionalField: nil,
                                  customName: nil,
                                  productName: "Dep",
                                  openDate: nil,
                                  ownerId: 0,
                                  branchId: 0,
                                  allowCredit: true,
                                  allowDebit: true,
                                  extraLargeDesign: .init(description: ""),
                                  largeDesign: .init(description: ""),
                                  mediumDesign: .init(description: ""),
                                  smallDesign: .init(description: ""),
                                  fontDesignColor: .init(description: ""),
                                  background: [],
                                  depositProductId: depositId,
                                  depositId: 0,
                                  interestRate: 0,
                                  accountId: 0,
                                  creditMinimumAmount: 0,
                                  minimumBalance: 0,
                                  endDate: endDate,
                                  endDateNf: endDateNf,
                                  isDemandDeposit: demandDeposit,
                                  order: 0,
                                  visibility: true,
                                  smallDesignMd5hash: "",
                                  smallBackgroundDesignHash: "")
    }
}
