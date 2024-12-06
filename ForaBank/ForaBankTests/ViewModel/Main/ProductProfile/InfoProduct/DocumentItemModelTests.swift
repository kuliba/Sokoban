//
//  DocumentItemModelTests.swift
//  VortexTests
//
//  Created by Andryusina Nataly on 20.06.2023.
//

import Foundation

import XCTest
@testable import ForaBank

final class DocumentItemModelTests: XCTestCase {
    
    typealias ItemModel = InfoProductViewModel.DocumentItemModel
    
    //MARK: - test init
    
    func test_init_documentItemModel_shouldSetValuesForAccountNumber() {
        
        let sut = makeSUT(
            id: .accountNumber,
            subtitle: "accountNumber subtitle",
            valueForCopy: "accountNumber valueForCopy"
        )
        
        XCTAssertNoDiff(sut.title, "Номер счета")
        XCTAssertNoDiff(sut.titleForInformer, "Номер счета")
        XCTAssertNoDiff(sut.subtitle, "accountNumber subtitle")
        XCTAssertNoDiff(sut.valueForCopy, "accountNumber valueForCopy")
    }
    
    func test_init_documentItemModel_shouldSetValuesForBic() {
        
        let sut = makeSUT(
            id: .bic,
            subtitle: "some subtitle",
            valueForCopy: "some valueForCopy"
            
        )
        
        XCTAssertNoDiff(sut.title, "БИК")
        XCTAssertNoDiff(sut.titleForInformer, "БИК")
        XCTAssertNoDiff(sut.subtitle, "some subtitle")
        XCTAssertNoDiff(sut.valueForCopy, "some valueForCopy")
    }
    
    func test_init_documentItemModel_shouldSetValuesForСorrAccount() {
        
        let sut = makeSUT(id: .corrAccount)
        
        XCTAssertNoDiff(sut.title, "Корреспондентский счет")
        XCTAssertNoDiff(sut.titleForInformer, "Корреспондентский счет")
    }
    
    func test_init_documentItemModel_shouldSetValuesForINN() {
        
        let sut = makeSUT(id: .inn)
        
        XCTAssertNoDiff(sut.title, "ИНН")
        XCTAssertNoDiff(sut.titleForInformer, "ИНН")
    }
    
    func test_init_documentItemModel_shouldSetValuesForKPP() {
        
        let sut = makeSUT(id: .kpp)
        
        XCTAssertNoDiff(sut.title, "КПП")
        XCTAssertNoDiff(sut.titleForInformer, "КПП")
    }
    
    func test_init_documentItemModel_shouldSetValuesForPayeeName() {
        
        let sut = makeSUT(id: .payeeName)
        
        XCTAssertNoDiff(sut.title, "Получатель")
        XCTAssertNoDiff(sut.titleForInformer, "Получатель")
    }
    
    func test_init_documentItemModel_shouldSetValuesForNumber() {
        
        let sut = makeSUT(id: .number)
        
        XCTAssertNoDiff(sut.title, "Номер карты")
        XCTAssertNoDiff(sut.titleForInformer, "Номер карты")
    }
    
    func test_init_documentItemModel_shouldSetValuesForNumberMasked() {
        
        let sut = makeSUT(id: .numberMasked)
        
        XCTAssertNoDiff(sut.title, "Номер карты")
        XCTAssertNoDiff(sut.titleForInformer, "Номер карты")
    }
    
    func test_init_documentItemModel_shouldSetValuesForHolder() {
        
        let sut = makeSUT(id: .holderName)
        
        XCTAssertNoDiff(sut.title, "Держатель карты")
        XCTAssertNoDiff(sut.titleForInformer, "Держатель карты")
    }
    
    func test_init_documentItemModel_shouldSetValuesForExpirationDate() {
        
        let sut = makeSUT(id: .expirationDate)
        
        XCTAssertNoDiff(sut.title, "Карта действует до")
        XCTAssertNoDiff(sut.titleForInformer, "Срок действия карты")
    }
    
    func test_init_documentItemModel_shouldSetValuesForCVV_empty() {
        
        let sut = makeSUT(id: .cvv, valueForCopy: "")
        
        XCTAssertNoDiff(sut.title, .cvvTitle)
        XCTAssertNoDiff(sut.titleForInformer, .cvvTitle)
        XCTAssertNoDiff(sut.valueForCopy, "")
    }
    
    func test_init_documentItemModel_shouldSetValuesForCVV_nonEmpty() {
        
        let sut = makeSUT(id: .cvv, valueForCopy: "any value")
        
        XCTAssertNoDiff(sut.title, .cvvTitle)
        XCTAssertNoDiff(sut.titleForInformer, .cvvTitle)
        XCTAssertNoDiff(sut.valueForCopy, "any value")
    }
    
    func test_init_documentItemModel_shouldSetValuesForCVVMasked_empty() {
        
        let sut = makeSUT(id: .cvvMasked, valueForCopy: "")
        
        XCTAssertNoDiff(sut.title, .cvvTitle)
        XCTAssertNoDiff(sut.titleForInformer, .cvvTitle)
        XCTAssertNoDiff(sut.valueForCopy, "")
    }
    
   func test_init_documentItemModel_shouldSetValuesForCVVMasked_nonEmpty() {
        
        let sut = makeSUT(id: .cvvMasked, valueForCopy: "any value")
        
        XCTAssertNoDiff(sut.title, .cvvTitle)
        XCTAssertNoDiff(sut.titleForInformer, .cvvTitle)
        XCTAssertNoDiff(sut.valueForCopy, "any value")
    }
    
    // MARK: - Helpers
    
    func makeSUT(
        id: ItemModel.ID,
        subtitle: String = "subtitle",
        valueForCopy: String = "valueForCopy"
    ) -> ItemModel {
        
        return .init(
            id: id,
            subtitle: subtitle,
            valueForCopy: valueForCopy
        )
    }
}
