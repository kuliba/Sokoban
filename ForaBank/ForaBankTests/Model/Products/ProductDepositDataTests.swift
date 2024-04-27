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
    
    //MARK: - test encode
    
    func test_encoding_endDateNil() throws {
        
        // given
        let command = ServerCommands.ProductController.GetProductListByType.Response.List(
            serial: "",
            productList: [Self.interestDeposit(
                endDate: nil,
                demandDeposit: true)]
        )
        
        // when
        let encoder = JSONEncoder.serverDate
        
        let result = try encoder.encode(command.productList)
        let resultString = String(decoding: result, as: UTF8.self)
        
        // then
        XCTAssertEqual(resultString, .interestDeposit)
    }
    
    func test_encoding_endDateNotNil() throws {
        
        let endDate = Date()
        
        // given
        let command = ServerCommands.ProductController.GetProductListByType.Response.List(
            serial: "",
            productList: [Self.interestDeposit(
                endDate: endDate,
                demandDeposit: true)]
        )
        
        // when
        let encoder = JSONEncoder.serverDate
        
        let result = try encoder.encode(command.productList)
        let resultString = String(decoding: result, as: UTF8.self)
        
        // then
        XCTAssertNoDiff(resultString, .interestDeposit(by: endDate))
    }
    
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
    
    //MARK: test availableTransferType
    
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
        let transferType = deposit.availableTransferType(with: depositInfo, deposit: deposit)
        
        //then
        XCTAssertEqual(transferType, .remains)
    }
  
    //MARK: tests otherDeposits
    
    func test_otherDeposits_shouldAvailableTransferType_onEndDateNf() throws {
        
        // given
        let endDateNf = true
        let endDate = pastDate
        let demandDeposit = false
        let depositId = 10000001870
        let depositInfo = Self.mutableDepositInfo(sumPayPrc: sumPayPrc)
        
        let deposit = Self.mutableDeposit(
            depositId: depositId,
            endDateNf: endDateNf,
            endDate: endDate,
            demandDeposit: demandDeposit,
            balance: 10
        )
        
        // when
        let transferType = deposit.availableTransferType(with: depositInfo, deposit: deposit)
        
        //then
        let balance = try XCTUnwrap(deposit.balance)
        XCTAssertEqual(transferType, .close(balance))
    }
    
    func test_otherDeposits_shouldAvailableTransferType_onEndDate_WithOutBalance() {
        
        // given
        let endDateNf = true
        let endDate = pastDate
        let demandDeposit = false
        let depositId = 10000001870
        let depositInfo: DepositInfoDataItem? = nil
        
        let deposit = Self.mutableDeposit(
            depositId: depositId,
            endDateNf: endDateNf,
            endDate: endDate,
            demandDeposit: demandDeposit
        )
        
        // when
        let transferType = deposit.availableTransferType(with: depositInfo, deposit: deposit)
        
        //then
        XCTAssertEqual(transferType, nil)
    }
    
    //MARK: tests interestDeposit
    func test_interestDeposits_shouldAvailableTransferType_onClose() {
        
        // given
        let endDateNf = true
        let endDate: Date? = nil
        let demandDeposit = false
        let depositInfo = Self.mutableDepositInfo(sumPayPrc: sumPayPrc)
        
        // when
        let deposit = Self.interestDeposit(endDateNf: endDateNf,
                                           endDate: endDate,
                                           demandDeposit: demandDeposit)
        
        let transferType = deposit.availableTransferType(with: depositInfo, deposit: deposit)
        
        //then
        XCTAssertEqual(transferType, .close(balance))
    }
    
    func test_interestDeposit_shouldAvailableTransferType_onInterest() {
        
        // given
        let endDateNf = true
        let endDate: Date? = nil
        let demandDeposit = false
        let depositInfo: DepositInfoDataItem? = nil
        
        let deposit = Self.interestDeposit(endDateNf: endDateNf,
                                           endDate: endDate,
                                           demandDeposit: demandDeposit)
        
        // when
        let transferType = deposit.availableTransferType(with: depositInfo, deposit: deposit)
        
        //then
        XCTAssertEqual(transferType, .interest(0))
    }
    
    func test_interestDeposit_shouldAvailableTransferType_ForaHit_onEndDate_ValueNil() {
        
        // given
        let endDateNf = false
        let endDate: Date? = nil
        let demandDeposit = false
        let depositInfo = Self.mutableDepositInfo(sumPayPrc: sumPayPrc)
        
        // when
        let deposit = Self.interestDeposit(endDateNf: endDateNf,
                                           endDate: endDate,
                                           demandDeposit: demandDeposit)
        
        let transferType = deposit.availableTransferType(with: depositInfo, deposit: deposit)
        
        //then
        XCTAssertEqual(transferType, .remains)
    }
    
    func test_interestDeposit_shouldAvailableTransferType_ForaHit_onEndDateExpired_withPercents() {
        
        // given
        let endDateNf = false
        let endDate = expirationDate
        let demandDeposit = false
        let depositInfo = Self.mutableDepositInfo(sumPayPrc: sumPayPrc)
        
        let deposit = Self.interestDeposit(endDateNf: endDateNf,
                                           endDate: endDate,
                                           demandDeposit: demandDeposit)
        
        // when
        let transferType = deposit.availableTransferType(with: depositInfo, deposit: deposit)
        
        //then
        XCTAssertEqual(transferType, .interest(sumPayPrc))
    }
    
    func test_interestDeposit_shouldAvailableTransferType_ForaHit_onEndDateNorExpired_withPercents() {
        
        // given
        let endDateNf = false
        let endDate = expirationDate
        let demandDeposit = false
        let depositInfo: DepositInfoDataItem? = nil
        
        let deposit = Self.interestDeposit(endDateNf: endDateNf,
                                           endDate: endDate,
                                           demandDeposit: demandDeposit)
        
        // when
        let transferType = deposit.availableTransferType(with: depositInfo, deposit: deposit)
        
        //then
        XCTAssertEqual(transferType, .interest(0))
    }
    
    func test_interestDeposit_shouldAvailableTransferType_ForaHit_onEndDateNotExpired_withPercents() {
        
        // given
        let endDateNf = false
        let endDate = pastDate
        let demandDeposit = false
        let depositInfo = Self.mutableDepositInfo(sumPayPrc: sumPayPrc)
        
        let deposit = Self.interestDeposit(endDateNf: endDateNf,
                                           endDate: endDate,
                                           demandDeposit: demandDeposit)
        
        // when
        let transferType = deposit.availableTransferType(with: depositInfo, deposit: deposit)
        
        //then
        XCTAssertEqual(transferType, .remains)
    }
}

private extension ProductDepositDataTests {
    
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
    
    static func mutableDeposit(
        depositId: Int = 10000003792,
        endDateNf: Bool = false,
        endDate: Date?,
        demandDeposit: Bool,
        balance: Double? = nil,
        isDebitInterestAvailable: Bool? = false
    ) -> ProductDepositData {
        
        return ProductDepositData(id: 30,
                                  productType: .deposit,
                                  number: nil,
                                  numberMasked: nil,
                                  accountNumber: nil,
                                  balance: balance,
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
                                  isDebitInterestAvailable: isDebitInterestAvailable,
                                  order: 0,
                                  visibility: true,
                                  smallDesignMd5hash: "",
                                  smallBackgroundDesignHash: "")
    }
    
    static func interestDeposit(
        depositId: Int = 111111111,
        endDateNf: Bool = false,
        endDate: Date?,
        demandDeposit: Bool,
        isDebitInterestAvailable: Bool? = true
    ) -> ProductDepositData {
        
        return mutableDeposit(
            depositId: depositId,
            endDateNf: endDateNf,
            endDate: endDate,
            demandDeposit: demandDeposit,
            isDebitInterestAvailable: isDebitInterestAvailable
        )
    }
}

private extension String {
    
    static let interestDeposit = "[{\"XLDesign\":\"\",\"mainField\":\"Dep\",\"branchId\":0,\"allowCredit\":true,\"allowDebit\":true,\"largeDesign\":\"\",\"mediumDesign\":\"\",\"minimumBalance\":0,\"smallDesignMd5hash\":\"\",\"endDate_nf\":false,\"currency\":\"RUB\",\"ownerID\":0,\"background\":[],\"depositProductID\":111111111,\"depositID\":0,\"smallDesign\":\"\",\"productType\":\"DEPOSIT\",\"isDebitInterestAvailable\":true,\"demandDeposit\":true,\"visibility\":true,\"smallBackgroundDesignHash\":\"\",\"id\":30,\"accountID\":0,\"mediumDesignMd5Hash\":\"\",\"accountNumber\":null,\"creditMinimumAmount\":0,\"interestRate\":0,\"productName\":\"Dep\",\"fontDesignColor\":\"\",\"order\":0,\"largeDesignMd5Hash\":\"\",\"xlDesignMd5Hash\":\"\"}]"
    
    static func interestDeposit(
        by endDate: Date
    ) -> String {
        
        return "[{\"mainField\":\"Dep\",\"accountNumber\":null,\"id\":30,\"background\":[],\"currency\":\"RUB\",\"creditMinimumAmount\":0,\"isDebitInterestAvailable\":true,\"smallBackgroundDesignHash\":\"\",\"endDate_nf\":false,\"demandDeposit\":true,\"ownerID\":0,\"depositID\":0,\"xlDesignMd5Hash\":\"\",\"allowDebit\":true,\"largeDesignMd5Hash\":\"\",\"mediumDesignMd5Hash\":\"\",\"smallDesignMd5hash\":\"\",\"fontDesignColor\":\"\",\"productType\":\"DEPOSIT\",\"depositProductID\":111111111,\"branchId\":0,\"order\":0,\"mediumDesign\":\"\",\"interestRate\":0,\"visibility\":true,\"largeDesign\":\"\",\"productName\":\"Dep\",\"allowCredit\":true,\"minimumBalance\":0,\"smallDesign\":\"\",\"accountID\":0,\"XLDesign\":\"\",\"endDate\":\(endDate.secondsSince1970UTC)}]"
    }
}
