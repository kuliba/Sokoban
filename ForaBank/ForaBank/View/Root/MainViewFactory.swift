//
//  MainViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.05.2024.
//

import SwiftUI

struct MainViewFactory {
    
    let makeAnywayPaymentFactory: MakeAnywayPaymentFactory
    let makeIconView: MakeIconView
    let makeGeneralIconView: MakeIconView
    let makePaymentCompleteView: MakePaymentCompleteView
    let makeSberQRConfirmPaymentView: MakeSberQRConfirmPaymentView
    let makeInfoViews: RootViewFactory.MakeInfoViews
    let makeUserAccountView: MakeUserAccountView
    let makeAnywayFlowView: MakeAnywayFlowView
    let makeAnywayServicePickerFlowView: MakeAnywayServicePickerFlowView
    let makeComposedSegmentedPaymentProviderPickerFlowView: MakeComposedSegmentedPaymentProviderPickerFlowView
    let makeContactsView: MakeContactsView
    let makeControlPanelWrapperView: MakeControlPanelWrapperView
    let makeCurrencyWalletView: MakeCurrencyWalletView
    let makeMainSectionCurrencyMetalView: MakeMainSectionCurrencyMetalView
    let makeMainSectionProductsView: MakeMainSectionProductsView
    let makeOperationDetailView: MakeOperationDetailView
    let makePaymentsMeToMeView: MakePaymentsMeToMeView
    let makePaymentsServicesOperatorsView: MakePaymentsServicesOperatorsView
    let makePaymentsSuccessView: MakePaymentsSuccessView
    let makePaymentsView: MakePaymentsView
    let makeQRFailedView: MakeQRFailedView
    let makeQRSearchOperatorView: MakeQRSearchOperatorView
    let makeQRView: MakeQRView
    let makeTemplatesListFlowView: MakeTemplatesListFlowView
    let makeTransportPaymentsView: MakeTransportPaymentsView
}

extension MainViewFactory {
    
    func iconView(
        _ icon: String?
    ) -> IconDomain.IconView {
        
        makeIconView(icon.map { .md5Hash(.init($0)) })
    }
    
    func labelWithIcon(
        title: String,
        subtitle: String? = nil,
        icon: String?
    ) -> some View {
        
        LabelWithIcon(
            title: title,
            subtitle: subtitle,
            config: .iFora,
            iconView: iconView(icon)
        )
    }
}
