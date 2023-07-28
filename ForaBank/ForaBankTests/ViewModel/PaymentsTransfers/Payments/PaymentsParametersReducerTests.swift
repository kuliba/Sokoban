//
//  PaymentsParametersReducerTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 23.06.2023.
//

import XCTest
@testable import ForaBank

final class PaymentsParametersReducerTests: XCTestCase {

    func test_reduceEmptyListWithEmptyListAnyTransfer_emptyList() {
        
        let sut = makeSUT()
        
        XCTAssertTrue(sut.reduce([], ([], unsupportedType())).isEmpty)
    }
    
    func test_reduceUniqueList_withUniqueList_nilCase_resultFirstItemsThenOther() {
        
        let sut = makeSUT()
        let params = makeParams([.successStatus, .successTitle])
        let newParams = makeParams([.successLogo, .successActionButton])
        
        let result = sut.reduce(params, (newParams, unsupportedType()))
        
        XCTAssertEqual(result.map(\.id), (params + newParams).map(\.id))
    }
    
    func test_reduceList_withListContainsPrevListItems_nilCase_resultUnionOfTwoLists_newItemsReplacesOld() throws {
        
        let sut = makeSUT()
        let params = makeParams([.successStatus, .successTitle])
        let newParams = makeParams([.successTitle, .successActionButton], value: "value")
        
        let result = sut.reduce(params, (newParams, unsupportedType()))
        
        XCTAssertEqual(result.map(\.id), makeIDs([.successStatus, .successTitle, .successActionButton]))
        let successTitleParam = try XCTUnwrap(result.parameter(forIdentifier: .successTitle))
        XCTAssertEqual(successTitleParam.value, "value")
    }

    func test_reduceList_withLogoItem_contactsAddressing_logoItemInTheRightPlace() {
        
        let sut = makeSUT()
        let params = makeParams([.successStatus, .successTitle, .successAmount, .successTransferNumber, .successAdditionalButtons, .successActionButton])
        let newParams = makeParams([.successLogo])
        
        let result = sut.reduce(params, (newParams, contactAddressing()))

        XCTAssertEqual(result.map(\.id), makeIDs([.successStatus, .successTitle, .successAmount, .successLogo, .successTransferNumber, .successAdditionalButtons, .successActionButton]))
    }
    
    func test_reduceList_withLogoItem_contactsAddressing_logoItemReplacesOldLogoItem() throws {
        
        let sut = makeSUT()
        let params = makeParams([.successStatus, .successTitle, .successAmount, .successLogo, .successTransferNumber, .successAdditionalButtons, .successActionButton])
        let newParams = makeParams([.successLogo], value: "value")
        
        let result = sut.reduce(params, (newParams, contactAddressing()))

        XCTAssertEqual(result.map(\.id), makeIDs([.successStatus, .successTitle, .successAmount, .successLogo, .successTransferNumber, .successAdditionalButtons, .successActionButton]))
        let successLogoParam = try XCTUnwrap(result.parameter(forIdentifier: .successLogo))
        XCTAssertEqual(successLogoParam.value, "value")
    }
    
    //MARK: - Helpers
    
    func makeSUT() -> PaymentsParametersReducer.Type {
        
        PaymentsParametersReducer.self
    }
    
    func unsupportedType() -> OperationDetailData.TransferEnum {
        
        return .accountClose
    }
    
    func contactAddressing() -> OperationDetailData.TransferEnum {
        
        return .contactAddressing
    }
    
    func makeParams(_ identifiers: [Payments.Parameter.Identifier], value: Payments.Parameter.Value = nil) -> [PaymentsParameterRepresentable] {
        
        identifiers.map { Payments.ParameterMock(id: $0.rawValue, value: value) }
    }
    
    func makeIDs(_ identifiers: [Payments.Parameter.Identifier]) -> [Payments.Parameter.ID] {
        
        identifiers.map(\.rawValue)
    }
}


