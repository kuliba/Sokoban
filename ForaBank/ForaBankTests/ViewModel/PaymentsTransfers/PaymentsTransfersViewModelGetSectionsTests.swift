//
//  PaymentsTransfersViewModelGetSectionsTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 30.05.2024.
//

@testable import ForaBank
import XCTest

final class PaymentsTransfersViewModelGetSectionsTests: XCTestCase {
    
    func test_updateSections_updateInfoFullPath_updateInfoStatusFlagActive_shouldAddUpdateSections()  {
        
        let (sut, model) = makeSUT(updateInfoStatusFlag: .init(.active))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 3, type: .latestPayments)
        
        model.updateInfo.value.updateValueBy(type: .card, with: false)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 4, type: .updateInfo)
        
        model.updateInfo.value.updateValueBy(type: .loan, with: false)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 4, type: .updateInfo)
        
        model.updateInfo.value.updateValueBy(type: .deposit, with: false)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 4, type: .updateInfo)
        
        model.updateInfo.value.updateValueBy(type: .account, with: false)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 4, type: .updateInfo)
        
        model.updateInfo.value.updateValueBy(type: .card, with: true)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 4, type: .updateInfo)
        
        model.updateInfo.value.updateValueBy(type: .loan, with: true)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 4, type: .updateInfo)
        
        model.updateInfo.value.updateValueBy(type: .deposit, with: true)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 4, type: .updateInfo)
        
        model.updateInfo.value.updateValueBy(type: .account, with: true)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 3, type: .latestPayments)
    }
    
    func test_updateSections_updateInfoFullPath_updateInfoStatusFlagInActive_shouldAddUpdateSections()  {
        
        let (sut, model) = makeSUT(updateInfoStatusFlag: .init(.inactive))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 3, type: .latestPayments)
        
        model.updateInfo.value.updateValueBy(type: .card, with: false)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 3, type: .latestPayments)
        
        model.updateInfo.value.updateValueBy(type: .loan, with: false)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 3, type: .latestPayments)
        
        model.updateInfo.value.updateValueBy(type: .deposit, with: false)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 3, type: .latestPayments)
        
        model.updateInfo.value.updateValueBy(type: .account, with: false)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 3, type: .latestPayments)
        
        model.updateInfo.value.updateValueBy(type: .card, with: true)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 3, type: .latestPayments)
        
        model.updateInfo.value.updateValueBy(type: .loan, with: true)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 3, type: .latestPayments)
        
        model.updateInfo.value.updateValueBy(type: .deposit, with: true)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 3, type: .latestPayments)
        
        model.updateInfo.value.updateValueBy(type: .account, with: true)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 3, type: .latestPayments)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        updateInfoStatusFlag: UpdateInfoStatusFeatureFlag = .init(.inactive),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: PaymentsTransfersViewModel,
        model: Model
    ) {
        let model: Model = .mockWithEmptyExcept()
        
        let sut = PaymentsTransfersViewModel(
            model: model,
            flowManager: .preview,
            userAccountNavigationStateManager: .preview,
            sberQRServices: .empty(),
            qrViewModelFactory: .preview(),
            paymentsTransfersFactory: .preview,
            updateInfoStatusFlag: updateInfoStatusFlag
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(model, file: file, line: line)
        
        return (sut, model)
    }
    
    private func assert(
        sections: [PaymentsTransfersSectionViewModel],
        count: Int,
        type: PaymentsTransfersSectionType,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        XCTAssertNoDiff(
            sections.count,
            count,
            "\nExpected \(count), but got \(sections.count) instead.",
            file: file, line: line
        )
        
        XCTAssertNoDiff(
            sections.first?.type,
            type,
            "\nExpected \(type), but got \(String(describing: sections.first?.type)) instead.",
            file: file, line: line
        )
    }
}
