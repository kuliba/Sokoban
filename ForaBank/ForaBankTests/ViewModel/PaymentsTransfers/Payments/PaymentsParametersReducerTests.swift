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
        
        XCTAssertTrue(reduce([], ([], unsupportedType())).isEmpty)
    }
    
    func test_reduceUniqueList_withUniqueList_nilCase_resultFirstItemsThenOther() {
        
        let params = makeParams([.successStatus, .successTitle])
        let newParams = makeParams([.successLogo, .successActionButton])
        
        let result = reduce(params, (newParams, unsupportedType()))
        
        XCTAssertEqual(result.map(\.id), (params + newParams).map(\.id))
    }
    
    func test_reduceList_withListContainsPrevListItems_nilCase_resultUnionOfTwoLists_newItemsReplacesOld() throws {
        
        let params = makeParams([.successStatus, .successTitle])
        let newParams = makeParams([.successTitle, .successActionButton], value: "value")
        
        let result = reduce(params, (newParams, unsupportedType()))
        
        XCTAssertEqual(result.map(\.id), makeIDs([.successStatus, .successTitle, .successActionButton]))
        let successTitleParam = try XCTUnwrap(result.parameter(forIdentifier: .successTitle))
        XCTAssertEqual(successTitleParam.value, "value")
    }
    
    func test_reduceList_withLogoItem_contactsAddressing_shouldInsertLogoItemIntoCorrectPlace() {
        
        let params = makeParams([.successStatus, .successTitle, .successAmount, .successTransferNumber, .successAdditionalButtons, .successActionButton])
        let newParams = makeParams([.successLogo])
        
        let result = reduce(params, (newParams, contactAddressing()))
        
        XCTAssertEqual(result.map(\.id), makeIDs([.successStatus, .successTitle, .successAmount, .successLogo, .successTransferNumber, .successAdditionalButtons, .successActionButton]))
    }
    
    func test_reduceList_withLogoItem_contactsAddressing_logoItemReplacesOldLogoItem() throws {
        
        let params = makeParams([.successStatus, .successTitle, .successAmount, .successLogo, .successTransferNumber, .successAdditionalButtons, .successActionButton])
        let newParams = makeParams([.successLogo], value: "value")
        
        let result = reduce(params, (newParams, contactAddressing()))
        
        XCTAssertEqual(result.map(\.id), makeIDs([.successStatus, .successTitle, .successAmount, .successLogo, .successTransferNumber, .successAdditionalButtons, .successActionButton]))
        let successLogoParam = try XCTUnwrap(result.parameter(forIdentifier: .successLogo))
        XCTAssertEqual(successLogoParam.value, "value")
    }
    
    func test_reduce_shouldSetOrderWithOptionsButtonsBeforeActionButton_direct_empty() {
        
        let params = makeParams([.successTitle, .successStatus, .successActionButton, .successOptionButtons, .successAdditionalButtons])
        
        let result = reduce(params, ([], direct()))
        
        XCTAssertNoDiff(result.map(\.id), makeIDs([.successStatus, .successTitle, .successOptionButtons, .successAdditionalButtons, .successActionButton]))
    }
    
    func test_reduce_shouldSetOrderWithOptionsButtonsBeforeActionButton_direct() {

        let params = makeParams([.successTitle, .successStatus, .successActionButton, .successOptionButtons, .successAdditionalButtons])
        let newParams = makeParams([.successLogo], value: "value")

        let result = reduce(params, (newParams, direct()))
        
        XCTAssertNoDiff(result.map(\.id), makeIDs([.successStatus, .successTitle, .successLogo, .successOptionButtons, .successAdditionalButtons, .successActionButton]))
    }
    
    func test_reduce_shouldSetOrderWithOptionsButtonsBeforeActionButton_contactAddressless_empty() {

        let params = makeParams([.successTitle, .successStatus, .successActionButton, .successOptionButtons, .successOptions, .successAdditionalButtons])
        
        let result = reduce(params, ([], contactAddressless()))
        
        XCTAssertNoDiff(result.map(\.id), makeIDs([.successStatus, .successTitle, .successOptions, .successOptionButtons, .successAdditionalButtons, .successActionButton]))
    }
    
    func test_reduce_shouldSetOrderWithOptionsButtonsBeforeActionButton_contactAddressless() {

        let params = makeParams([.successTitle, .successStatus, .successActionButton, .successOptionButtons, .successOptions, .successAdditionalButtons])
        let newParams = makeParams([.successLogo], value: "value")

        let result = reduce(params, (newParams, contactAddressless()))
        
        XCTAssertNoDiff(result.map(\.id), makeIDs([.successStatus, .successTitle, .successLogo, .successOptions, .successOptionButtons, .successAdditionalButtons, .successActionButton]))
    }
    
    //MARK: - Helpers
    
    private func reduce(
        _ state: [PaymentsParameterRepresentable],
        _ action: (
            new: [PaymentsParameterRepresentable],
            case: some PaymentsParametersReducerCase)
    ) -> [PaymentsParameterRepresentable] {
        
        PaymentsParametersReducer.reduce(state, action)
    }
    
    private func contactAddressless() -> OperationDetailData.TransferEnum {
        
        return .contactAddressing
    }
    
    private func direct() -> OperationDetailData.TransferEnum {
        
        return .direct
    }
    
    private func unsupportedType() -> OperationDetailData.TransferEnum {
        
        return .accountClose
    }
    
    private func contactAddressing() -> OperationDetailData.TransferEnum {
        
        return .contactAddressing
    }
    
    private func makeParams(
        _ identifiers: [Payments.Parameter.Identifier],
        value: Payments.Parameter.Value = nil
    ) -> [PaymentsParameterRepresentable] {
        
        identifiers.map {
            
            Payments.ParameterMock(id: $0.rawValue, value: value)
        }
    }
    
    private func makeIDs(
        _ identifiers: [Payments.Parameter.Identifier]
    ) -> [Payments.Parameter.ID] {
        
        identifiers.map(\.rawValue)
    }
}
