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
            makeTemplates: { _ in .sampleComplete },
            makePaymentsTransfersFlowManager: { _ in .preview },
            userAccountNavigationStateManager: .preview,
            sberQRServices: .empty(),
            productProfileServices: .preview,
            qrViewModelFactory: .preview(),
            cvvPINServicesClient: HappyCVVPINServicesClient(),
            productNavigationStateManager: .preview,
            makeCardGuardianPanel: ProductProfileViewModelFactory.makeCardGuardianPanelPreview,
            makeSubscriptionsViewModel: { _,_ in .preview },
            updateInfoStatusFlag: .init(.active),
            makePaymentProviderPickerFlowModel: PaymentProviderPickerFlowModel.preview,
            makePaymentProviderServicePickerFlowModel: AnywayServicePickerFlowModel.preview,
            makeServicePaymentBinder: ServicePaymentBinder.preview
        ),
        refreshingIndicator: .init(isActive: true),
        openOrderSticker: {},
        makeMyProductsViewFactory: .init(makeInformerDataUpdateFailure: { nil })
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
            makeTemplates: { _ in .sampleComplete },
            makePaymentsTransfersFlowManager: { _ in .preview },
            userAccountNavigationStateManager: .preview,
            sberQRServices: .empty(),
            productProfileServices: .preview,
            qrViewModelFactory: .preview(),
            cvvPINServicesClient: HappyCVVPINServicesClient(),
            productNavigationStateManager: .preview,
            makeCardGuardianPanel: ProductProfileViewModelFactory.makeCardGuardianPanelPreview,
            makeSubscriptionsViewModel: { _,_ in .preview },
            updateInfoStatusFlag: .init(.active), 
            makePaymentProviderPickerFlowModel: PaymentProviderPickerFlowModel.preview,
            makePaymentProviderServicePickerFlowModel: AnywayServicePickerFlowModel.preview,
            makeServicePaymentBinder: ServicePaymentBinder.preview
        ),
        refreshingIndicator: .init(isActive: true),
        showOnboarding: [.hide: true, .ordered: false],
        openOrderSticker: {},
        makeMyProductsViewFactory: .init(makeInformerDataUpdateFailure: { nil })
    )
}

extension AnywayServicePickerFlowModel {
    
    static func preview(
        payload: PaymentProviderServicePickerPayload
    ) -> AnywayServicePickerFlowModel {
        
        return .init(
            initialState: .init(
                content: .init(
                    initialState: .init(payload: .preview),
                    reduce: { state, _ in (state, nil) },
                    handleEffect: { _,_ in }
                )
            ),
            factory: .init(
                makeAnywayFlowModel: { _ in fatalError() },
                makePayByInstructionsViewModel: { _ in fatalError() }
            ),
            scheduler: .main
        )
    }
}
