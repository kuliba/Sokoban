//
//  MyProductsViewModel+sample.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.10.2023.
//

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
        makeProductProfileViewModel: { product, rootView, dismissAction in
            
            ProductProfileViewModel(
                .emptyMock,
                makeQRScannerModel: {
                    
                    .init(
                        closeAction: $0,
                        qrResolver: QRViewModel.ScanResult.init
                    )
                },
                getSberQRData: { _,_ in },
                makeSberQRConfirmPaymentViewModel: SberQRConfirmPaymentViewModel.init,
                cvvPINServicesClient: HappyCVVPINServicesClient(),
                product: product,
                rootView: rootView,
                dismissAction: dismissAction
            )
        },
        refreshingIndicator: .init(isActive: true)
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
        makeProductProfileViewModel: { product, rootView, dismissAction in
            
            ProductProfileViewModel(
                .emptyMock,
                makeQRScannerModel: {
                    
                    .init(
                        closeAction: $0,
                        qrResolver: QRViewModel.ScanResult.init
                    )
                },
                getSberQRData: { _,_ in },
                makeSberQRConfirmPaymentViewModel: SberQRConfirmPaymentViewModel.init,
                cvvPINServicesClient: HappyCVVPINServicesClient(),
                product: product,
                rootView: rootView,
                dismissAction: dismissAction
            )
        },
        refreshingIndicator: .init(isActive: true),
        showOnboarding: [.hide: true, .ordered: false]
    )
}
