//
//  Model+makeSectionsTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 30.05.2024.
//

@testable import ForaBank
import XCTest

final class Model_makeSectionsTests: XCTestCase {
 
    // TODO: вернуть после оптимизации запросов UpdateInfo.swift:10
 /*   func test_updateFailureInfoSection_shouldBecomeFirstOnCardsUpdateFailure_flagActive() {
        
        assert(
            flag: .active,
            productTypesUpdateFailure: [.card],
            before: (3, .latestPayments),
            after:  (4, .updateFailureInfo))
    }

    func test_updateFailureInfoSection_shouldNotAppearOnAllProductsUpdateSuccess_flagActive() {
        
        assert(
            flag: .active,
            productTypesUpdateFailure: [],
            before: (3, .latestPayments),
            after:  (3, .latestPayments))
    }
 */
    func test_updateFailureInfoSection_shouldNotAppearFirstOnCardsUpdateFailure_flagInactive() {
        
        assert(
            flag: .inactive,
            productTypesUpdateFailure: [.card],
            before: (3, .latestPayments),
            after:  (3, .latestPayments))
    }

    func test_updateFailureInfoSection_shouldNotAppearOnAllProductsUpdateSuccess_flagInactive() {
        
        assert(
            flag: .inactive,
            productTypesUpdateFailure: [],
            before: (3, .latestPayments),
            after:  (3, .latestPayments))
    }
    
    // TODO: вернуть после оптимизации запросов UpdateInfo.swift:10

/*    func test_updateFailureInfoSection_shouldBecomeFirstIfLeastOneTypeUpdateFailure_flagActive() {
        
        assert(
            flag: .active,
            productTypesUpdateFailure: [.card],
            before: (3, .latestPayments),
            after:  (4, .updateFailureInfo))
    }
*/
    func test_updateFailureInfoSection_shouldNotAppearFirstIfLeastOneTypeUpdateFailure_flagInactive() {
        
        assert(
            flag: .inactive,
            productTypesUpdateFailure: [.card],
            before: (3, .latestPayments),
            after:  (3, .latestPayments))
    }

    func test_makeSections_onlyCorporateCards_ShouldReturnFirstDisableForCorCardsSection () {
        
        let sut = makeSUT(products: [
            .card : [
                makeCardProduct(id: 1, cardType: .corporate),
                makeCardProduct(id: 2, cardType: .individualBusinessman),
                makeCardProduct(id: 3, cardType: .individualBusinessmanMain),
            ]])
        let sectionBeforeUpdate = sut.makeSections(flag: .init(.inactive))
        
        assert(sections: sectionBeforeUpdate, count: 4, firstType: .disableForCorCards)
    }
    
    func test_makeSections_notOnlyCorporateCards_ShouldReturnFirstLatestPaymentsSection () {
        
        let sut = makeSUT(products: [
            .card : [
                makeCardProduct(id: 1, cardType: .corporate),
                makeCardProduct(id: 2, cardType: .individualBusinessman),
                makeCardProduct(id: 3, cardType: .individualBusinessmanMain),
                makeCardProduct(id: 4, cardType: .main),
            ]])
        let sectionBeforeUpdate = sut.makeSections(flag: .init(.inactive))
        
        assert(sections: sectionBeforeUpdate, count: 3, firstType: .latestPayments)
    }

    // MARK: - Helpers

    private func makeSUT(
        products: ProductsData = [:],
        file: StaticString = #file,
        line: UInt = #line
    ) -> Model {
        
        let model: Model = .mockWithEmptyExcept()
        model.products.value = products
        
        trackForMemoryLeaks(model, file: file, line: line)
        
        return model
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
        before: (Int, PaymentsTransfersSectionType),
        after: (Int, PaymentsTransfersSectionType),
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sectionBeforeUpdate = model.makeSections(flag: .init(flag))
        
        assert(sections: sectionBeforeUpdate, count: before.0, firstType: before.1)

        updatedAllTypeSuccessExcept(types: productTypesUpdateFailure, model)

        let sectionAfterUpdate = model.makeSections(flag: .init(flag))

        assert(sections: sectionAfterUpdate, count: after.0, firstType: after.1)
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
