//
//  PaymentsTransfersFactory.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 29.01.2024.
//

import Foundation

struct PaymentsTransfersFactory {
    
    let makeUtilitiesViewModel: MakeUtilitiesViewModel
    let makeProductProfileViewModel: MakeProductProfileViewModel
    let makeTemplatesListViewModel: MakeTemplatesListViewModel
}

extension PaymentsTransfersFactory {
    
    typealias MakeUtilitiesViewModel = ((PaymentsServicesViewModel) -> Void) -> Void
    
    typealias MakeProductProfileViewModel = (ProductData, String, @escaping () -> Void) -> ProductProfileViewModel?
    
    typealias DismissAction = () -> Void
    typealias MakeTemplatesListViewModel = (@escaping DismissAction) -> TemplatesListViewModel
}

extension PaymentsTransfersFactory {
    
    static let preview: Self = {
        
        let productProfileViewModel = ProductProfileViewModel.make(
            with: .emptyMock,
            fastPaymentsFactory: .legacy,
            makeUtilitiesViewModel: { _ in },
            navigationStateManager: .preview,
            sberQRServices: .empty(),
            qrViewModelFactory: .preview(),
            cvvPINServicesClient: HappyCVVPINServicesClient()
        )
        return .init(
            makeUtilitiesViewModel: { _ in },
            makeProductProfileViewModel: productProfileViewModel,
            makeTemplatesListViewModel: { _ in .sampleComplete }
        )
    }()
}
