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
            productTypesUpdateSuccess: ProductType.allCases,
            productTypesUpdateFailure: [ProductType.card],
            countBeforeUpdate: 3,
            firstTypeBeforeUpdate: .latestPayments,
            countAfterUpdate: 4,
            firstTypeAfterUpdate: .updateFailureInfo)
    }

    func test_updateFailureInfoSection_shouldNotAppearFirstIfLeastOneTypeUpdateFailure_flagInactive() {
        
        assert(
            flag: .inactive,
            productTypesUpdateSuccess: ProductType.allCases,
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
        
        XCTAssertNoDiff(
            sectionBeforeUpdate.count,
            countBeforeUpdate,
            "\nBefore: \nExpected \(countBeforeUpdate), but got \(sectionBeforeUpdate.count) instead.",
            file: file, line: line
        )
        
        XCTAssertNoDiff(
            sectionBeforeUpdate.first?.type,
            firstTypeBeforeUpdate,
            "\nBefore: \nExpected \(firstTypeBeforeUpdate), but got \(String(describing: sectionBeforeUpdate.first?.type)) instead.",
            file: file, line: line
        )
        
        model.updateInfo.value.setValue(isUpdated, for: productType)
        let sectionAfterUpdate = model.makeSections(flag: .init(flag))

        XCTAssertNoDiff(
            sectionAfterUpdate.count,
            countAfterUpdate,
            "\nAfter: \nExpected \(countAfterUpdate), but got \(sectionAfterUpdate.count) instead.",
            file: file, line: line
        )
        
        XCTAssertNoDiff(
            sectionAfterUpdate.first?.type,
            firstTypeAfterUpdate,
            "\nAfter: \nExpected \(firstTypeAfterUpdate), but got \(String(describing: sectionAfterUpdate.first?.type)) instead.",
            file: file, line: line
        )
    }
    
    private func assert(
        model: Model = .mockWithEmptyExcept(),
        flag: UpdateInfoStatusFeatureFlag.RawValue = .inactive,
        productTypesUpdateSuccess: [ProductType],
        productTypesUpdateFailure: [ProductType],
        countBeforeUpdate: Int,
        firstTypeBeforeUpdate: PaymentsTransfersSectionType,
        countAfterUpdate: Int,
        firstTypeAfterUpdate: PaymentsTransfersSectionType,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        let sectionBeforeUpdate = model.makeSections(flag: .init(flag))
        
        XCTAssertNoDiff(
            sectionBeforeUpdate.count,
            countBeforeUpdate,
            "\nBefore: \nExpected \(countBeforeUpdate), but got \(sectionBeforeUpdate.count) instead.",
            file: file, line: line
        )
        
        XCTAssertNoDiff(
            sectionBeforeUpdate.first?.type,
            firstTypeBeforeUpdate,
            "\nBefore: \nExpected \(firstTypeBeforeUpdate), but got \(String(describing: sectionBeforeUpdate.first?.type)) instead.",
            file: file, line: line
        )
        
        for productType in productTypesUpdateSuccess {
            model.updateInfo.value.setValue(true, for: productType)
        }
        
        for productType in productTypesUpdateSuccess {
            model.updateInfo.value.setValue(false, for: productType)
        }

        let sectionAfterUpdate = model.makeSections(flag: .init(flag))

        XCTAssertNoDiff(
            sectionAfterUpdate.count,
            countAfterUpdate,
            "\nAfter: \nExpected \(countAfterUpdate), but got \(sectionAfterUpdate.count) instead.",
            file: file, line: line
        )
        
        XCTAssertNoDiff(
            sectionAfterUpdate.first?.type,
            firstTypeAfterUpdate,
            "\nAfter: \nExpected \(firstTypeAfterUpdate), but got \(String(describing: sectionAfterUpdate.first?.type)) instead.",
            file: file, line: line
        )
    }
}
