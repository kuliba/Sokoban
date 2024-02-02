//
//  PaymentsTransfersFactory.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 29.01.2024.
//

import Foundation

struct PaymentsTransfersFactory {
    
    let makeProductProfileViewModel: MakeProductProfileViewModel
    let makeTemplatesListViewModel: MakeTemplatesListViewModel
    
    typealias MakeProductProfileViewModel = (ProductData, String, @escaping () -> Void) -> ProductProfileViewModel?
    
    typealias DismissAction = () -> Void
    typealias MakeTemplatesListViewModel = (@escaping DismissAction) -> TemplatesListViewModel
}

extension PaymentsTransfersFactory {
    
    static let preview: Self = {
        
        let productProfileViewModel = ProductProfileViewModel.make(
            with: .emptyMock,
            fastPaymentsFactory: .legacy,
            navigationStateManager: .preview,
            sberQRServices: .empty(),
            qrViewModelFactory: .preview(),
            cvvPINServicesClient: HappyCVVPINServicesClient()
        )
        return .init(
            makeProductProfileViewModel: productProfileViewModel,
            makeTemplatesListViewModel: { _ in .sampleComplete }
        )
    }()
}
