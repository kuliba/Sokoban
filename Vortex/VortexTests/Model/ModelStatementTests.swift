//
//  ModelStatementTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 17.10.2022.
//

import XCTest
@testable import ForaBank

class ModelStatementTests: XCTestCase {
    
    let statementsRequestDays: Int = 30
    let statementslatestDaysOffset: Int = 7
    let calendar = Calendar.current
}

//MARK: - Statements Request Parameters

extension ModelStatementTests {
    
    func testStatementsRequestParameters_Latest_No_Storage() {
        
        // given
        let currentDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        
        // when
        let result = Model.statementsRequestParameters(storage: nil, product: Self.product, direction: .latest, days: statementsRequestDays, currentDate: currentDate, latestDaysOffset: statementslatestDaysOffset)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.period, Period(start: Date.date(year: 2022, month: 3, day: 11, calendar: calendar)!, end: currentDate))
        XCTAssertEqual(DirectionTest(direction: result?.direction), .latest)
        XCTAssertEqual(result?.limitDate, currentDate)
    }
    
    func testStatementsRequestParameters_Latest_Storage_No_Override() {
        
        // given
        let currentDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        
        let storageStartDate = Date.date(year: 2022, month: 1, day: 1, calendar: calendar)!
        let storageEndDate = Date.date(year: 2022, month: 2, day: 10, calendar: calendar)!
        let storagePeriod = Period(start: storageStartDate, end: storageEndDate)
        
        let storage = ProductStatementsStorage(period: storagePeriod, statements: [], historyLimitDate: nil)
        
        // when
        let result = Model.statementsRequestParameters(storage: storage, product: Self.product, direction: .latest, days: statementsRequestDays, currentDate: currentDate, latestDaysOffset: statementslatestDaysOffset)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.period, Period(start: Date.date(year: 2022, month: 2, day: 10, calendar: calendar)!, end: Date.date(year: 2022, month: 3, day: 12, calendar: calendar)!))
        XCTAssertEqual(DirectionTest(direction: result?.direction), .latest)
        XCTAssertEqual(result?.limitDate, currentDate)
    }
    
    func testStatementsRequestParameters_Latest_Storage_Override() {
        
        // given
        let currentDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        
        let storageStartDate = Date.date(year: 2022, month: 1, day: 1, calendar: calendar)!
        let storageEndDate = Date.date(year: 2022, month: 4, day: 9, calendar: calendar)!
        let storagePeriod = Period(start: storageStartDate, end: storageEndDate)
        
        let storage = ProductStatementsStorage(period: storagePeriod, statements: [], historyLimitDate: nil)
        
        // when
        let result = Model.statementsRequestParameters(storage: storage, product: Self.product, direction: .latest, days: statementsRequestDays, currentDate: currentDate, latestDaysOffset: statementslatestDaysOffset)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.period, Period(start: Date.date(year: 2022, month: 4, day: 2, calendar: calendar)!, end: Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!))
        XCTAssertEqual(DirectionTest(direction: result?.direction), .latest)
        XCTAssertEqual(result?.limitDate, currentDate)
    }
    
    func testStatementsRequestParameters_Eldest() {
        
        // given
        let currentDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let bankOpenDate = Date.date(year: 1992, month: 5, day: 27, calendar: calendar)!
        
        let storageStartDate = Date.date(year: 2022, month: 3, day: 1, calendar: calendar)!
        let storageEndDate = Date.date(year: 2022, month: 4, day: 9, calendar: calendar)!
        let storagePeriod = Period(start: storageStartDate, end: storageEndDate)
        
        let storage = ProductStatementsStorage(period: storagePeriod, statements: [], historyLimitDate: nil)
        
        // when
        let result = Model.statementsRequestParameters(storage: storage, product: Self.product, direction: .eldest, days: statementsRequestDays, currentDate: currentDate, latestDaysOffset: statementslatestDaysOffset)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.period, Period(start: Date.date(year: 2022, month: 1, day: 30, calendar: calendar)!, end: Date.date(year: 2022, month: 3, day: 1, calendar: calendar)!))
        XCTAssertEqual(DirectionTest(direction: result?.direction), .eldest)
        XCTAssertEqual(result?.limitDate, bankOpenDate)
    }
    
    func testStatementsRequestParameters_Eldest_Nil() {
        
        // given
        let currentDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let bankOpenDate = Date.date(year: 1992, month: 5, day: 27, calendar: calendar)!
        
        let storageEndDate = Date.date(year: 2022, month: 4, day: 9, calendar: calendar)!
        let storagePeriod = Period(start: bankOpenDate, end: storageEndDate)
        
        let storage = ProductStatementsStorage(period: storagePeriod, statements: [], historyLimitDate: nil)
        
        // when
        let result = Model.statementsRequestParameters(storage: storage, product: Self.product, direction: .eldest, days: statementsRequestDays, currentDate: currentDate, latestDaysOffset: statementslatestDaysOffset)
        
        // then
        XCTAssertNil(result)
    }
}

extension ModelStatementTests {
    
    static let product = ProductData(id: 0, productType: .card, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: "RUB", mainField: "CARD", additionalField: nil, customName: nil, productName: "CARD", openDate: nil, ownerId: 1, branchId: nil, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], order: 1, isVisible: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
}


 
private enum DirectionTest: Equatable {
    
    case latest
    case eldest
    case custom
    
    init(direction: Period.Direction?) {
        
        switch direction {
        case .custom:
            self = .custom
        case .eldest:
            self = .eldest
        case .latest:
            self = .latest
        case .none:
            self = .custom
        }
    }
}
