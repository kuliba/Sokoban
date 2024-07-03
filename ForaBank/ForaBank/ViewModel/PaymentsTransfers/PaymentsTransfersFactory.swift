//
//  PaymentsTransfersFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.05.2024.
//

import SwiftUI

struct PaymentsTransfersFactory {
    
    let makeUtilitiesViewModel: MakeUtilitiesViewModel
    let makeProductProfileViewModel: MakeProductProfileViewModel
    let makeTemplatesListViewModel: MakeTemplatesListViewModel
    let makeSections: MakePaymentsTransfersSections
    let makeAlertDataUpdateFailureViewModel: MakeAlertDataUpdateFailureViewModel
}

extension PaymentsTransfersFactory {
    #warning("move to PaymentsTransfersFlowReducerFactory")
    struct MakeUtilitiesPayload {
        
        let type: PTSectionPaymentsView.ViewModel.PaymentsType
        let navLeadingAction: () -> Void
        let navTrailingAction: () -> Void
        let addCompany: () -> Void
        let requisites: () -> Void
    }
    
    enum UtilitiesVM {
        
        case legacy(PaymentsServicesViewModel)
        case utilities
    }
    
    typealias MakeUtilitiesViewModel = (MakeUtilitiesPayload, @escaping (UtilitiesVM) -> Void) -> Void
    
    typealias MakeProductProfileViewModel = (ProductData, String, @escaping () -> Void) -> ProductProfileViewModel?
    
    typealias DismissAction = () -> Void
    typealias MakeTemplatesListViewModel = (@escaping DismissAction) -> TemplatesListViewModel
    
    typealias MakePaymentsTransfersSections = () -> [PaymentsTransfersSectionViewModel]
    typealias MakeAlertDataUpdateFailureViewModel = (@escaping DismissAction) -> Alert.ViewModel?
}

extension PaymentsTransfersFactory {
    
    static let preview: Self = {
        
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
            updateInfoStatusFlag: .init(.inactive)
        )
        return .init(
            makeUtilitiesViewModel: { _,_ in },
            makeProductProfileViewModel: productProfileViewModel,
            makeTemplatesListViewModel: { _ in .sampleComplete },
            makeSections: { Model.emptyMock.makeSections(flag: .init(.inactive)) },
            makeAlertDataUpdateFailureViewModel: { _ in nil }
        )
    }()
}
