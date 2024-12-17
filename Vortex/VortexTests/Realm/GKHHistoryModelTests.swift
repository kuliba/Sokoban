//
//  GKHHistoryModelTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 06.12.2021.
//

import XCTest
import RealmSwift
@testable import ForaBank

class GKHHistoryModelTests: XCTestCase {

    override func setUpWithError() throws {
        
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }

    override func tearDownWithError() throws {
        
        let realm = try Realm()
        try realm.write {

            realm.deleteAll()
        }
    }

    func testIsDataEqual() throws {
        
        // given
        let paymentDate = "01.01.2000"
        let amount = 1000.0
        let puref = "gas"
        let fildName = "test"
        let fieldValue = "value"
        
        // when
        let first = GKHHistoryModel()
        first.paymentDate = paymentDate
        first.amount = amount
        first.puref = puref
        
        let firstListItem = AdditionalListModel()
        firstListItem.fieldName = fildName
        firstListItem.fieldValue = fieldValue
        
        first.additionalList.append(firstListItem)
        
        let second = GKHHistoryModel()
        second.paymentDate = paymentDate
        second.amount = amount
        second.puref = puref
        
        let secondListItem = AdditionalListModel()
        secondListItem.fieldName = fildName
        secondListItem.fieldValue = fieldValue
        
        second.additionalList.append(secondListItem)
        
        XCTAssertTrue(first.isDataEqual(to: second))
    }
}
