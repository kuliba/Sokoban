//
//  Model+makeSectionsTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 30.05.2024.
//

@testable import ForaBank
import XCTest

final class Model_makeSectionsTests: XCTestCase {
    
    func test_updateFailureInfoSection_shouldBecomeFirstOnCardsUpdateFailure_flagActive() {
        
        assert(
            flag: .active,
            productType: .card,
            isUpdated: false,
            countBeforeUpdate: 3,
            firstTypeBeforeUpdate: .latestPayments,
            countAfterUpdate: 4,
            firstTypeAfterUpdate: .updateFailureInfo)
    }

    func test_updateFailureInfoSection_shouldNotAppearOnCardsUpdateSuccess_flagActive() {
        
        assert(
            flag: .active,
            productType: .card,
            isUpdated: true,
            countBeforeUpdate: 3,
            firstTypeBeforeUpdate: .latestPayments,
            countAfterUpdate: 3,
            firstTypeAfterUpdate: .latestPayments)
    }
    
    func test_updateFailureInfoSection_shouldNotAppearFirstOnCardsUpdateFailure_flagInActive() {
        
        assert(
            flag: .inactive,
            productType: .card,
            isUpdated: false,
            countBeforeUpdate: 3,
            firstTypeBeforeUpdate: .latestPayments,
            countAfterUpdate: 3,
            firstTypeAfterUpdate: .latestPayments)
    }

    func test_updateFailureInfoSection_shouldNotAppearOnCardsUpdateSuccess_flagInActive() {
        
        assert(
            flag: .inactive,
            productType: .card,
            isUpdated: true,
            countBeforeUpdate: 3,
            firstTypeBeforeUpdate: .latestPayments,
            countAfterUpdate: 3,
            firstTypeAfterUpdate: .latestPayments)
    }
    
    func test_updateFailureInfoSection_shouldBecomeFirstIfLeastOneTypeUpdateFailure_flagActive() {
        
        assert(
            flag: .active,
            productTypesUpdateFailure: [ProductType.card],
            countBeforeUpdate: 3,
            firstTypeBeforeUpdate: .latestPayments,
            countAfterUpdate: 4,
            firstTypeAfterUpdate: .updateFailureInfo)
    }

    func test_updateFailureInfoSection_shouldNotAppearFirstIfLeastOneTypeUpdateFailure_flagInactive() {
        
        assert(
            flag: .inactive,
            productTypesUpdateFailure: [ProductType.card],
            countBeforeUpdate: 3,
            firstTypeBeforeUpdate: .latestPayments,
            countAfterUpdate: 3,
            firstTypeAfterUpdate: .latestPayments)
    }

    // MARK: - Helpers

    private func assert(
        model: Model = .mockWithEmptyExcept(),
        flag: UpdateInfoStatusFeatureFlag.RawValue = .inactive,
        productType: ProductType,
        isUpdated: Bool,
        countBeforeUpdate: Int,
        firstTypeBeforeUpdate: PaymentsTransfersSectionType,
        countAfterUpdate: Int,
        firstTypeAfterUpdate: PaymentsTransfersSectionType,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        let sectionBeforeUpdate = model.makeSections(flag: .init(flag))
        
        assert(sections: sectionBeforeUpdate, count: countBeforeUpdate, firstType: firstTypeBeforeUpdate)
        
        model.updateInfo.value.setValue(isUpdated, for: productType)
        let sectionAfterUpdate = model.makeSections(flag: .init(flag))

        assert(sections: sectionAfterUpdate, count: countAfterUpdate, firstType: firstTypeAfterUpdate)
    }
        
    private func assert(
        sections: [PaymentsTransfersSectionViewModel],
        count: Int,
        firstType: PaymentsTransfersSectionType,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        XCTAssertNoDiff(
            sections.count,
            count,
            "\nBefore: \nExpected \(count), but got \(sections.count) instead.",
            file: file, line: line
        )
        
        XCTAssertNoDiff(
            sections.first?.type,
            firstType,
            "\nBefore: \nExpected \(firstType), but got \(String(describing: sections.first?.type)) instead.",
            file: file, line: line
        )
    }
    
    private func assert(
        model: Model = .mockWithEmptyExcept(),
        flag: UpdateInfoStatusFeatureFlag.RawValue = .inactive,
        productTypesUpdateFailure: [ProductType],
        countBeforeUpdate: Int,
        firstTypeBeforeUpdate: PaymentsTransfersSectionType,
        countAfterUpdate: Int,
        firstTypeAfterUpdate: PaymentsTransfersSectionType,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        let sectionBeforeUpdate = model.makeSections(flag: .init(flag))
        
        assert(sections: sectionBeforeUpdate, count: countBeforeUpdate, firstType: firstTypeBeforeUpdate)

        updatedAllTypeSuccessExcept(types: productTypesUpdateFailure, model)

        let sectionAfterUpdate = model.makeSections(flag: .init(flag))

        assert(sections: sectionAfterUpdate, count: countAfterUpdate, firstType: firstTypeAfterUpdate)
    }
    
    private func updatedAllTypeSuccessExcept(
        types productTypesUpdateFailure: [ProductType],
        _ model: Model
    ) {
        for productType in ProductType.allCases {
            model.updateInfo.value.setValue(true, for: productType)
        }
        
        for productType in productTypesUpdateFailure {
            model.updateInfo.value.setValue(false, for: productType)
        }
    }
}
