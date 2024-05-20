//
//  MyProductsViewModel+sample.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.10.2023.
//

import SberQR

extension MyProductsViewModel {
    
    static let sample = MyProductsViewModel(
        navigationBar: .init(
            title: "Мои продукты",
            leftItems: [NavigationBarView.ViewModel.BackButtonItemViewModel(icon: .ic24ChevronLeft, action: {})],
            rightItems: [NavigationBarView.ViewModel.ButtonItemViewModel(icon: .ic24BarInOrder, action: {})],
            background: .mainColorsWhite),
        totalMoney: .sampleBalance,
        productSections: [.sample2, .sample3],
        openProductVM: .previewSample,
        cardAction: { _ in },
        makeProductProfileViewModel: ProductProfileViewModel.make(
            with: .emptyMock,
            fastPaymentsFactory: .legacy,
            makeUtilitiesViewModel: { _,_ in },
            paymentsTransfersFlowManager: .preview,
            userAccountNavigationStateManager: .preview,
            sberQRServices: .empty(),
            qrViewModelFactory: .preview(),
            cvvPINServicesClient: HappyCVVPINServicesClient()
        ),
        refreshingIndicator: .init(isActive: true),
        openOrderSticker: {}
    )
    
    static let sampleOpenProduct = MyProductsViewModel(
        navigationBar: .init(
            title: "Мои продукты",
            leftItems: [NavigationBarView.ViewModel.BackButtonItemViewModel(icon: .ic24ChevronLeft, action: {})],
            rightItems: [NavigationBarView.ViewModel.ButtonItemViewModel(icon: .ic24Edit, action: { })],
            background: .mainColorsWhite),
        totalMoney: .sampleBalance,
        productSections: [.sample2, .sample3],
        openProductVM: .previewSample,
        cardAction: { _ in },
        makeProductProfileViewModel: ProductProfileViewModel.make(
            with: .emptyMock,
            fastPaymentsFactory: .legacy,
            makeUtilitiesViewModel: { _,_ in },
            paymentsTransfersFlowManager: .preview,
            userAccountNavigationStateManager: .preview,
            sberQRServices: .empty(),
            qrViewModelFactory: .preview(),
            cvvPINServicesClient: HappyCVVPINServicesClient()
        ),
        refreshingIndicator: .init(isActive: true),
        showOnboarding: [.hide: true, .ordered: false],
        openOrderSticker: {}
    )
}
