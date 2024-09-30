//
//  ProductStatementsStorageTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 09.06.2022.
//

import XCTest
@testable import ForaBank

class ProductStatementsStorageTests: XCTestCase {
    
    let calendar = Calendar.current
}

//MARK: - Updated

extension ProductStatementsStorageTests {
    
    func testUpdated_No_Intersect_No_Override() throws {
        
        // given
        let startDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!
        let initialPeriod = Period(start: startDate, end: endDate)
        
        let firstStatementDate =  Date.date(year: 2022, month: 4, day: 11, calendar: calendar)!
        let firstStatement = ProductStatementData(id: "1", date: firstStatementDate, amount: 100, operationType: .debit, tranDate: nil)
        let lastStatementDate = Date.date(year: 2022, month: 5, day: 9, calendar: calendar)!
        let lastStatement = ProductStatementData(id: "2", date: lastStatementDate, amount: 200, operationType: .debit, tranDate: nil)
        let storage = ProductStatementsStorage(period: initialPeriod, statements: [firstStatement, lastStatement])
        
        let updateStart = endDate
        let updateEnd = Date.date(year: 2022, month: 5, day: 30, calendar: calendar)!
        let updatePeriod = Period(start: updateStart, end: updateEnd)
        
        let updateStatementDate = Date.date(year: 2022, month: 5, day: 20, calendar: calendar)!
        let updateStatement = ProductStatementData(id: "3", date: updateStatementDate, amount: 300, operationType: .debit, tranDate: nil)
        
        let update = ProductStatementsStorage.Update(period: updatePeriod, statements: [updateStatement], direction: .latest, limitDate: updateEnd)
        
        // when
        let result = storage.updated(with: update, historyLimitDate: nil)
        
        // then
        XCTAssertEqual(result.period, Period(start: startDate, end: updateEnd))
        XCTAssertEqual(result.statements.count, 3)
        XCTAssertEqual(result.statements[0].date, firstStatementDate)
        XCTAssertEqual(result.statements[1].date, lastStatementDate)
        XCTAssertEqual(result.statements[2].date, updateStatementDate)
    }
    
    func testUpdated_Intersect_Ovveride() throws {
        
        // given
        let startDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!
        let initialPeriod = Period(start: startDate, end: endDate)
        
        let firstStatementDate = startDate
        let firstStatement = ProductStatementData(id: "1", date: firstStatementDate, amount: 100, operationType: .debit, tranDate: nil)
        let lastStatementDate = endDate
        let lastStatement = ProductStatementData(id: "2", date: lastStatementDate, amount: 200, operationType: .debit, tranDate: nil)
        let storage = ProductStatementsStorage(period: initialPeriod, statements: [firstStatement, lastStatement])
        
        let updateStart = Date.date(year: 2022, month: 4, day: 20, calendar: calendar)!
        let updateEnd = Date.date(year: 2022, month: 5, day: 30, calendar: calendar)!
        let updatePeriod = Period(start: updateStart, end: updateEnd)
        
        let updateStatementTranDate = Date.date(year: 2022, month: 5, day: 15, calendar: calendar)!
        let updateStatement = ProductStatementData(id: "2", date: lastStatementDate, amount: 200, operationType: .debit, tranDate: updateStatementTranDate)
        
        let update = ProductStatementsStorage.Update(period: updatePeriod, statements: [updateStatement], direction: .latest, limitDate: updateEnd)
        
        // when
        let result = storage.updated(with: update, historyLimitDate: nil)
        
        // then
        XCTAssertEqual(result.period, Period(start: startDate, end: updateEnd))
        XCTAssertEqual(result.statements.count, 2)
        XCTAssertEqual(result.statements[0].date, firstStatementDate)
        XCTAssertEqual(result.statements[1].tranDate, updateStatementTranDate)
    }
}

//MARK: - Latest Period

extension ProductStatementsStorageTests {
    
    func testLatestPeriod() throws {
        
        // given
        let startDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!
        
        let initialPeriod = Period(start: startDate, end: endDate)
        let storage = ProductStatementsStorage(period: initialPeriod, statements: [])
        
        let limitDate = Date.date(year: 2022, month: 6, day: 1, calendar: calendar)!
        
        // when
        guard let result = storage.latestPeriod(days: 5, limitDate: limitDate) else {
            XCTFail()
            return
        }
        
        // then
        let resultStart = calendar.dateComponents([.year, .month, .day], from: result.start)
        XCTAssertEqual(resultStart.year, 2022)
        XCTAssertEqual(resultStart.month, 5)
        XCTAssertEqual(resultStart.day, 10)
        
        let resultEnd = calendar.dateComponents([.year, .month, .day], from: result.end)
        XCTAssertEqual(resultEnd.year, 2022)
        XCTAssertEqual(resultEnd.month, 5)
        XCTAssertEqual(resultEnd.day, 15)
    }
    
    func testLatestPeriod_Limit_Hitted() throws {
        
        // given
        let startDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!
        
        let initialPeriod = Period(start: startDate, end: endDate)
        let storage = ProductStatementsStorage(period: initialPeriod, statements: [])
        
        let limitDate = Date.date(year: 2022, month: 6, day: 1, calendar: calendar)!
        
        // when
        guard let result = storage.latestPeriod(days: 100, limitDate: limitDate) else {
            XCTFail()
            return
        }
        
        // then
        let resultStart = calendar.dateComponents([.year, .month, .day], from: result.start)
        XCTAssertEqual(resultStart.year, 2022)
        XCTAssertEqual(resultStart.month, 5)
        XCTAssertEqual(resultStart.day, 10)
        
        let resultEnd = calendar.dateComponents([.year, .month, .day], from: result.end)
        XCTAssertEqual(resultEnd.year, 2022)
        XCTAssertEqual(resultEnd.month, 6)
        XCTAssertEqual(resultEnd.day, 1)
    }
    
    func testLatestPeriod_Limit_Incorrect() throws {
        
        // given
        let startDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!
        
        let initialPeriod = Period(start: startDate, end: endDate)
        let storage = ProductStatementsStorage(period: initialPeriod, statements: [])
        
        let limitDate = Date.date(year: 2022, month: 3, day: 1, calendar: calendar)!
        
        // when
        let result = storage.latestPeriod(days: 100, limitDate: limitDate)
        
        // then
        XCTAssertNil(result)
    }
}

//MARK: - Eldest Period

extension ProductStatementsStorageTests {
    
    func testEldestPeriod() throws {
        
        // given
        let startDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!
        
        let initialPeriod = Period(start: startDate, end: endDate)
        let storage = ProductStatementsStorage(period: initialPeriod, statements: [])
        
        let limitDate = Date.date(year: 2022, month: 1, day: 1, calendar: calendar)!
        
        // when
        guard let result = storage.eldestPeriod(days: 5, limitDate: limitDate) else {
            XCTFail()
            return
        }
        
        // then
        let resultStart = calendar.dateComponents([.year, .month, .day], from: result.start)
        XCTAssertEqual(resultStart.year, 2022)
        XCTAssertEqual(resultStart.month, 4)
        XCTAssertEqual(resultStart.day, 5)
        
        let resultEnd = calendar.dateComponents([.year, .month, .day], from: result.end)
        XCTAssertEqual(resultEnd.year, 2022)
        XCTAssertEqual(resultEnd.month, 4)
        XCTAssertEqual(resultEnd.day, 10)
    }
    
    func testEldestPeriod_Limit_Hitted() throws {
        
        // given
        let startDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!
        
        let initialPeriod = Period(start: startDate, end: endDate)
        let storage = ProductStatementsStorage(period: initialPeriod, statements: [])
        
        let limitDate = Date.date(year: 2022, month: 1, day: 1, calendar: calendar)!
        
        // when
        guard let result = storage.eldestPeriod(days: 100, limitDate: limitDate) else {
            XCTFail()
            return
        }
        
        // then
        let resultStart = calendar.dateComponents([.year, .month, .day], from: result.start)
        XCTAssertEqual(resultStart.year, 2022)
        XCTAssertEqual(resultStart.month, 1)
        XCTAssertEqual(resultStart.day, 1)
        
        let resultEnd = calendar.dateComponents([.year, .month, .day], from: result.end)
        XCTAssertEqual(resultEnd.year, 2022)
        XCTAssertEqual(resultEnd.month, 4)
        XCTAssertEqual(resultEnd.day, 10)
    }
    
    func testEldestPeriod_Limit_Incorrect() throws {
        
        // given
        let startDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!
        
        let initialPeriod = Period(start: startDate, end: endDate)
        let storage = ProductStatementsStorage(period: initialPeriod, statements: [])
        
        let limitDate = Date.date(year: 2022, month: 5, day: 1, calendar: calendar)!
        
        // when
        let result = storage.eldestPeriod(days: 100, limitDate: limitDate)
        
        // then
        XCTAssertNil(result)
    }
    
}

//MARK: - isHistoryComplete

extension ProductStatementsStorageTests {
    
    func testIsHistoryComplete_With_Update_Eldest_True() throws {
        
        // given
        let startDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!
        
        let period = Period(start: startDate, end: endDate)
        
        let limitDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let update = ProductStatementsStorage.Update(period: period, statements: [], direction: .eldest, limitDate: limitDate)
        
        // when
        let result = ProductStatementsStorage(with: update, historyLimitDate: limitDate).hasMoreHistoryToShow
        
        // then
        XCTAssertTrue(result)
    }
    
    func testIsHistoryComplete_With_Update_Eldest_False() throws {
        
        // given
        let startDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!
        
        let period = Period(start: startDate, end: endDate)
        
        let limitDate = Date.date(year: 2022, month: 3, day: 10, calendar: calendar)!
        let update = ProductStatementsStorage.Update(period: period, statements: [], direction: .eldest, limitDate: limitDate)
        
        // when
        let result = ProductStatementsStorage(with: update, historyLimitDate: limitDate)
        
        // then
        XCTAssertFalse(result.hasMoreHistoryToShow)
    }
    
    func testIsHistoryComplete_With_Update_Latest_True() throws {
        
        // given
        let startDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 6, day: 10, calendar: calendar)!
        
        let period = Period(start: startDate, end: endDate)
        
        let limitDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!
        let update = ProductStatementsStorage.Update(period: period, statements: [], direction: .latest, limitDate: limitDate)
        
        // when
        let result = ProductStatementsStorage(with: update, historyLimitDate: limitDate).hasMoreHistoryToShow
        
        // then
        XCTAssertTrue(result)
    }
}

//MARK: - History Limit Date

extension ProductStatementsStorageTests {
    
    func testHistoryLimitDateForProduct_Date() throws{
        
        // given
        let openDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let product = ProductData(id: 0, productType: .card, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: "RUB", mainField: "CARD", additionalField: nil, customName: nil, productName: "CARD", openDate: openDate, ownerId: 1, branchId: nil, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], order: 1, isVisible: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
        
        // when
        let result = ProductStatementsStorage.historyLimitDate(for: product)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, openDate)
    }
    
    func testHistoryLimitDate_BankOpenDate() throws{
        
        // given
        let product = ProductData(id: 0, productType: .card, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: "RUB", mainField: "CARD", additionalField: nil, customName: nil, productName: "CARD", openDate: nil, ownerId: 1, branchId: nil, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], order: 1, isVisible: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
        let bankOpenDate = Date.date(year: 1992, month: 5, day: 27, calendar: calendar)!
        
        // when
        let result = ProductStatementsStorage.historyLimitDate(for: product)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, bankOpenDate)
    }
}
