//
//  PaymentsTransfersViewModelGetSectionsTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 30.05.2024.
//

@testable import ForaBank
import XCTest
import SwiftUI

final class PaymentsTransfersViewModelGetSectionsTests: XCTestCase {
    
    func test_makeSections_empty_shouldMakeEmptySections() {
        
        let sut = makeSUT(
            flag: .active,
            sections: [])
        
        XCTAssertTrue(sut.sections.isEmpty)
    }
    
    func test_makeSections_oneSection_shouldMakeOneSection() {
        
        let sut = makeSUT(
            flag: .active,
            sections: [PTSectionTransfersView.ViewModel()])
        
        assert(sections: sut.sections, count: 1, first: .transfers)
    }
    
    func test_makeSections_moreSection_shouldMakeMoreSection() {
        
        let sut = makeSUT(
            flag: .active,
            sections: [
                PTSectionPaymentsView.ViewModel(),
                PTSectionTransfersView.ViewModel()
            ])
        
        assert(sections: sut.sections, count: 2, first: .payments)
    }
        
    // MARK: - Helpers
    
    private func makeSUT(
        flag: UpdateInfoStatusFeatureFlag.RawValue = .inactive,
        sections: [PaymentsTransfersSectionViewModel],
        file: StaticString = #file,
        line: UInt = #line
    ) -> PaymentsTransfersViewModel
    {
        let model: Model = .mockWithEmptyExcept()
        
        let sut = PaymentsTransfersViewModel(
            model: model,
            makeFlowManager: { _ in .preview },
            userAccountNavigationStateManager: .preview,
            sberQRServices: .empty(),
            qrViewModelFactory: .preview(),
            paymentsTransfersFactory: makeProductProfileViewModel(
                flag: flag,
                sections: sections,
                model: model
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(model, file: file, line: line)
        
        return sut
    }
    
    private func makeProductProfileViewModel(
        flag: UpdateInfoStatusFeatureFlag.RawValue = .inactive,
        sections: [PaymentsTransfersSectionViewModel],
        model: Model
    ) -> PaymentsTransfersFactory {
        
        let productProfileViewModel = ProductProfileViewModel.make(
            with: .emptyMock,
            fastPaymentsFactory: .legacy,
            makeUtilitiesViewModel: { _,_ in }, 
            makeTemplatesListViewModel: { _ in .sampleComplete },
            makePaymentsTransfersFlowManager: { _ in .preview },
            userAccountNavigationStateManager: .preview,
            sberQRServices: .empty(),
            productProfileServices: .preview,
            qrViewModelFactory: .preview(),
            cvvPINServicesClient: HappyCVVPINServicesClient(),
            productNavigationStateManager: ProductProfileFlowManager.preview,
            makeCardGuardianPanel: ProductProfileViewModelFactory.makeCardGuardianPanelPreview,
            makeSubscriptionsViewModel: { _,_  in .preview},
            updateInfoStatusFlag: .init(.inactive),
            makePaymentProviderServicePickerFlowModel: PaymentProviderServicePickerFlowModel.preview, 
            makeServicePaymentBinder: ServicePaymentBinder.preview
        )
        
        return .init(
            makeAlertDataUpdateFailureViewModel: { _ in nil },
            makePaymentProviderServicePickerFlowModel: PaymentProviderServicePickerFlowModel.preview,
            makeProductProfileViewModel: productProfileViewModel,
            makeSections: { sections },
            makeServicePaymentBinder: ServicePaymentBinder.preview,
            makeTemplatesListViewModel: { _ in .sampleComplete },
            makeUtilitiesViewModel: { _,_ in }
        )
    }
    
    private func assert(
        sections: [PaymentsTransfersSectionViewModel],
        count: Int,
        first: PaymentsTransfersSectionType,
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
            first,
            "\nExpected \(first), but got \(String(describing: sections.first?.type)) instead.",
            file: file, line: line
        )
    }
}
